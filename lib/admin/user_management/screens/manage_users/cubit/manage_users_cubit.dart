import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/investor_block_requests_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/review_block_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/pdf_excel_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/utils/manage_users_export_file.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

import '../../../../../user/investments/model/investor_transaction_history_response_model.dart';

part 'manage_users_state.dart';

class ManageUsersCubit extends Cubit<ManageUsersState> {
  ManageUsersCubit({required ManageUsersRepository repository})
      : _repository = repository,
        super(const ManageUsersInitial());

  final ManageUsersRepository _repository;
  bool _exportInProgress = false;
  ManageUsersStatusFilter _filter = ManageUsersStatusFilter.active;
  int _usersRequestId = 0;
  int? _activeCount;
  int? _blockedCount;

  /// Investors with a terminate request awaiting approval (local flag; the
  /// list API does not return it). Kept here so it survives chip switches.
  final Set<int> _pendingTerminateIds = <int>{};

  Future<ManageUsersExportResult> exportInvestorPaymentReport({
    required bool asPdf,
    required String section,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    if (_exportInProgress) {
      return const ManageUsersExportResult(
        success: false,
        message: 'An export is already in progress.',
      );
    }

    final normalizedSection = section.toLowerCase() == 'due' ? 'due' : 'all';
    _exportInProgress = true;
    _setExporting(true);

    try {
      final response = await _repository.getPdfExcel(
        PdfExcelRequestModel(
          fromDate: fromDate,
          toDate: toDate,
          section: normalizedSection,
        ),
      );
      if (isClosed) {
        return const ManageUsersExportResult(
          success: false,
          message: 'Export cancelled.',
        );
      }

      final exportRows = response.rowsForSection(normalizedSection);

      final saveResult = await ManageUsersExportFile.generateAndSave(
        asPdf: asPdf,
        section: normalizedSection,
        fromDate: fromDate,
        toDate: toDate,
        investors: exportRows,
      );

      final formatLabel = asPdf ? 'PDF' : 'Excel';
      return ManageUsersExportResult(
        success: true,
        message: exportRows.isEmpty
            ? '$formatLabel generated with no records for the selected range.'
            : '$formatLabel downloaded successfully.',
        savedLocation: saveResult.message,
      );
    } on DioException catch (error) {
      return ManageUsersExportResult(
        success: false,
        message: ApiErrorMessage.from(
          error,
          fallback: 'Failed to export investor report',
        ),
      );
    } catch (error) {
      appLog(
        'Export investor payment report failed: $error',
        name: 'ManageUsersCubit',
      );
      return ManageUsersExportResult(
        success: false,
        message: ApiErrorMessage.from(
          error,
          fallback: 'Failed to generate export file',
        ),
      );
    } finally {
      _exportInProgress = false;
      if (!isClosed) {
        _setExporting(false);
      }
    }
  }

  void _setExporting(bool isExporting) {
    final current = state;
    if (current is ManageUsersSuccess) {
      emit(current.copyWith(isExporting: isExporting));
      return;
    }
    if (current is ManageUsersEmpty) {
      emit(current.copyWith(isExporting: isExporting));
      return;
    }
    if (current is ManageUsersFailure) {
      emit(current.copyWith(isExporting: isExporting));
    }
  }

  /// Current list filter. Survives re-activation refetches.
  ManageUsersStatusFilter get filter => _filter;

  /// Summary card counts. They come from BOTH lists (`status=all` and
  /// `status=blocked`), so they do not depend on the selected chip. `null`
  /// means "not known yet" (shown as an em dash, never as 0).
  int? get activeCount => _activeCount;
  int? get blockedCount => _blockedCount;
  int? get totalCount => (_activeCount == null || _blockedCount == null)
      ? null
      : _activeCount! + _blockedCount!;

  /// Switches the Active / Blocked chip and loads that list. The cached card
  /// counts stay as they are; the other list is only fetched again when its
  /// count is not known (an earlier call failed).
  Future<void> setFilter(ManageUsersStatusFilter filter) async {
    if (filter == _filter) return;
    _filter = filter;
    final otherCount = filter == ManageUsersStatusFilter.active
        ? _blockedCount
        : _activeCount;
    await _loadUsers(refreshCounts: otherCount == null);
  }

  /// Keeps [_pendingTerminateIds] in line with what the server just returned:
  /// the flag only means something for investors that are still active.
  void _syncPendingTerminateIds(List<ManageUsersInvestor> users) {
    if (_filter == ManageUsersStatusFilter.active) {
      final activeIds = {
        for (final user in users)
          if (user.isActive) user.id,
      };
      _pendingTerminateIds.retainWhere(activeIds.contains);
    } else {
      _pendingTerminateIds.removeAll([for (final user in users) user.id]);
    }
  }

  /// After a local status change, keep only rows that belong to the current
  /// filter (e.g. an unblocked investor leaves the Blocked list).
  List<ManageUsersInvestor> _rowsForCurrentFilter(
    List<ManageUsersInvestor> users,
  ) {
    return [
      for (final user in users)
        if (_filter == ManageUsersStatusFilter.active
            ? user.isActive
            : user.isBlocked)
          user,
    ];
  }

  /// Full refetch (first load, tab re-activation, retry): the selected list
  /// plus the other list for the card counts, in parallel.
  Future<void> fetchUsers() => _loadUsers(refreshCounts: true);

  Future<_UsersResult> _requestUsers(ManageUsersStatusFilter filter) async {
    try {
      return _UsersResult.ok(await _repository.getInvestors(filter: filter));
    } catch (error) {
      if (error is! DioException) {
        appLog(
          'Get manage users unexpected error: $error',
          name: 'ManageUsersCubit',
        );
      }
      return _UsersResult.failed(error);
    }
  }

  /// Unblock: one investor moves from the Blocked to the Active count.
  void _moveCountToActive() {
    final blocked = _blockedCount;
    if (blocked != null && blocked > 0) _blockedCount = blocked - 1;
    final active = _activeCount;
    if (active != null) _activeCount = active + 1;
  }

  /// Approved terminate: one investor moves from the Active to the Blocked
  /// count. Unknown (null) counts stay unknown.
  void _moveCountToBlocked() {
    final active = _activeCount;
    if (active != null && active > 0) _activeCount = active - 1;
    final blocked = _blockedCount;
    if (blocked != null) _blockedCount = blocked + 1;
  }

  /// A response is usable when it looks successful or carries rows.
  bool _isUsable(ManageUsersResponse response) {
    final looksSuccessful = response.status ||
        response.code == 200 ||
        response.message.toLowerCase().contains('success');
    return looksSuccessful || response.users.isNotEmpty;
  }

  void _storeCount(ManageUsersStatusFilter filter, _UsersResult result) {
    final response = result.response;
    if (response == null || !_isUsable(response)) return;
    if (filter == ManageUsersStatusFilter.active) {
      _activeCount = response.users.length;
    } else {
      _blockedCount = response.users.length;
    }
  }

  Future<void> _loadUsers({required bool refreshCounts}) async {
    final previous = state;
    // A newer call supersedes any request still in flight (chip switched
    // quickly, tab re-activated): only the latest response may update state
    // or counts. This covers both parallel calls.
    final requestId = ++_usersRequestId;

    if (previous is ManageUsersSuccess) {
      emit(previous.copyWith(isTableLoading: true));
    } else if (previous is ManageUsersEmpty) {
      emit(previous.copyWith(isTableLoading: true));
    } else {
      emit(const ManageUsersLoading());
    }

    final selected = _filter;
    final other = selected == ManageUsersStatusFilter.active
        ? ManageUsersStatusFilter.blocked
        : ManageUsersStatusFilter.active;

    final selectedFuture = _requestUsers(selected);
    final otherFuture = refreshCounts ? _requestUsers(other) : null;
    final selectedResult = await selectedFuture;
    final otherResult = otherFuture == null ? null : await otherFuture;
    if (isClosed || requestId != _usersRequestId) return;

    // A failed call keeps the last known count.
    if (otherResult != null) _storeCount(other, otherResult);
    _storeCount(selected, selectedResult);

    final response = selectedResult.response;
    if (response == null) {
      emit(
        ManageUsersFailure(
          ApiErrorMessage.from(
            selectedResult.error!,
            fallback: 'Failed to load users',
          ),
          isExporting: _exportInProgress,
        ),
      );
      return;
    }

    if (response.skippedCount > 0) {
      appLog(
        'Get manage users skipped ${response.skippedCount} invalid rows',
        name: 'ManageUsersCubit',
      );
    }

    final hasData = response.users.isNotEmpty;
    if (!_isUsable(response)) {
      emit(
        ManageUsersFailure(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to load users',
          isExporting: _exportInProgress,
        ),
      );
      return;
    }

    _syncPendingTerminateIds(response.users);

    // Transient flags of work still running must survive the fresh state:
    // an export in progress and a status update in flight.
    if (!hasData) {
      emit(ManageUsersEmpty(isExporting: _exportInProgress));
      return;
    }

    final users = [
      for (final user in response.users)
        if (_pendingTerminateIds.contains(user.id) && user.isActive)
          user.copyWith(hasPendingTerminateRequest: true)
        else
          user,
    ];

    final current = state;
    emit(
      ManageUsersSuccess(
        users: users,
        isExporting: _exportInProgress,
        statusUpdatingUserId:
            current is ManageUsersSuccess ? current.statusUpdatingUserId : null,
      ),
    );
  }

  Future<void> toggleBlockStatus(
    ManageUsersInvestor user, {
    String? terminateRemarks,
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.statusUpdatingUserId != null) return;

    final targetIsActive = user.isBlocked;
    final isTerminating = !targetIsActive;
    if (isTerminating) {
      final remarks = terminateRemarks?.trim() ?? '';
      if (remarks.isEmpty) return;
    }

    final displayName =
        user.name.trim().isEmpty ? 'User' : user.name.trim();

    emit(
      current.copyWith(
        statusUpdatingUserId: user.id,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.blockUser(
        userId: user.id,
        isActive: targetIsActive,
        remarks: isTerminating ? terminateRemarks?.trim() : null,
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      // Terminate creates a pending approval request — do not flip local
      // status to Terminated until the request is approved elsewhere.
      if (isTerminating) {
        _pendingTerminateIds.add(user.id);
        final message = response.message.trim().isNotEmpty
            ? response.message.trim()
            : 'Termination request for $displayName has been sent for approval.';

        emit(
          latest.copyWith(
            users: [
              for (final item in latest.users)
                if (item.id == user.id)
                  item.copyWith(
                    hasPendingTerminateRequest: true,
                    terminateRemarks:
                        terminateRemarks?.trim() ?? item.terminateRemarks,
                  )
                else
                  item,
            ],
            clearStatusUpdatingUserId: true,
            statusFeedback: ManageUsersStatusFeedback(
              isSuccess: true,
              title: 'Request Sent',
              message: message,
            ),
          ),
        );
        return;
      }

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : '$displayName has been unblocked';

      _moveCountToActive();

      emit(
        latest.copyWith(
          // The row may no longer belong to the active filter (unblocked
          // investor in the Blocked list): drop it instead of refetching.
          users: _rowsForCurrentFilter([
            for (final item in latest.users)
              if (item.id == user.id)
                item.copyWith(isActive: targetIsActive)
              else
                item,
          ]),
          clearStatusUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: 'User Unblocked',
            message: message,
          ),
        ),
      );
    } catch (error) {
      appLog(
        'Update user block status failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          clearStatusUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: 'Update Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to update user status',
            ),
          ),
        ),
      );
    }
  }

  void clearStatusFeedback() {
    final current = state;
    if (current is! ManageUsersSuccess || current.statusFeedback == null) {
      return;
    }

    emit(current.copyWith(clearStatusFeedback: true));
  }

  Future<bool> refundUser({
    required ManageUsersInvestor user,
    required double refundAmount,
    required String paymentMethod,
    required String remarks,
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return false;
    if (current.refundUpdatingUserId != null) return false;

    final displayName =
        user.name.trim().isEmpty ? 'User' : user.name.trim();

    emit(
      current.copyWith(
        refundUpdatingUserId: user.id,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.refundInvestor(
        userId: user.id,
        refundAmount: refundAmount,
        paymentMethod: paymentMethod,
        remarks: remarks,
      );
      if (isClosed) return false;

      final latest = state;
      if (latest is! ManageUsersSuccess) return false;

      final refundData = response.data;
      final updatedPaid = refundData != null
          ? refundData.remainingRefundableAmount
          : (user.amountPaid - refundAmount).clamp(0.0, double.infinity);

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : 'Refund recorded for $displayName';

      emit(
        latest.copyWith(
          users: [
            for (final item in latest.users)
              if (item.id == user.id)
                item.copyWith(amountPaid: updatedPaid)
              else
                item,
          ],
          clearRefundUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: 'Refund Saved',
            message: message,
          ),
        ),
      );
      return true;
    } catch (error) {
      appLog(
        'Refund user failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return false;

      final latest = state;
      if (latest is! ManageUsersSuccess) return false;

      emit(
        latest.copyWith(
          clearRefundUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: 'Refund Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to process refund',
            ),
          ),
        ),
      );
      return false;
    }
  }

  /// Loads benefits card fields from InvestorDetails (committed, discount,
  /// extraAmount, days). Summary card uses this API only — not GetInvestors.
  Future<void> fetchInvestorBenefits(int userId) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.benefitsLoadingUserId == userId) return;

    emit(
      current.copyWith(
        benefitsLoadingUserId: userId,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.getInvestorDetails(userId);
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final details = response.data;
      final loadedIds = {...latest.benefitsLoadedUserIds, userId};

      if (details == null) {
        emit(
          latest.copyWith(
            benefitsLoadedUserIds: loadedIds,
            clearBenefitsLoadingUserId: true,
          ),
        );
        return;
      }

      final committed = details.investmentAmount > 0
          ? details.investmentAmount
          : null;

      final users = latest.users.map((user) {
        if (user.id != userId) return user;
        return user.copyWith(
          totalPayable: committed,
          depositDiscountAmount: details.discountAmount,
          extraAmount: details.extraAmount,
          days: details.days,
        );
      }).toList(growable: false);

      emit(
        latest.copyWith(
          users: users,
          benefitsLoadedUserIds: loadedIds,
          clearBenefitsLoadingUserId: true,
        ),
      );
    } catch (error) {
      appLog(
        'Fetch investor benefits failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          benefitsLoadedUserIds: {...latest.benefitsLoadedUserIds, userId},
          clearBenefitsLoadingUserId: true,
        ),
      );
    }
  }

  Future<void> fetchInvestorMouStatus(int investorId) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.mouLoadingUserId == investorId ||
        current.mouUpdatingUserId == investorId) {
      return;
    }

    emit(
      current.copyWith(
        mouLoadingUserId: investorId,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.getInvestorMOU(
        investorId: investorId,
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final data = response.latestRecord;
      final syncedStatus =
          DocumentProcessStatusX.tryParse(data?.status) ??
              DocumentProcessStatus.pending;
      final issuedAt = response.timestampForStatus('Issued');
      final completedAt = response.timestampForStatus('Completed');

      emit(
        latest.copyWith(
          mouStatus: {...latest.mouStatus, investorId: syncedStatus},
          mouIssuedAt: _mergeTimestamp(
            latest.mouIssuedAt,
            investorId,
            issuedAt,
          ),
          mouCompletedAt: _mergeTimestamp(
            latest.mouCompletedAt,
            investorId,
            completedAt,
          ),
          mouDocumentPath: _mergeDocumentPath(
            latest.mouDocumentPath,
            investorId,
            response.effectiveDocumentPath,
          ),
          mouDocumentUpdatedAt: _mergeTimestamp(
            latest.mouDocumentUpdatedAt,
            investorId,
            response.effectiveDocumentUpdatedAt,
          ),
          clearMouLoadingUserId: true,
        ),
      );
    } catch (error) {
      appLog(
        'Fetch investor MOU status failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      // No saved MOU (or transient failure): keep Pending without toast noise.
      emit(
        latest.copyWith(
          mouStatus: {
            ...latest.mouStatus,
            investorId:
                latest.mouStatus[investorId] ?? DocumentProcessStatus.pending,
          },
          clearMouLoadingUserId: true,
        ),
      );
    }
  }

  Future<void> saveInvestorMouStatus({
    required int investorId,
    required DocumentProcessStatus status,
    Uint8List? documentBytes,
    String? documentFileName,
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.mouUpdatingUserId != null ||
        current.mouLoadingUserId != null) {
      return;
    }

    final previousStatus =
        current.mouStatus[investorId] ?? DocumentProcessStatus.pending;
    final hasDocument = documentBytes != null &&
        documentBytes.isNotEmpty &&
        (documentFileName?.trim().isNotEmpty ?? false);

    if (!hasDocument) {
      if (previousStatus == status) return;
      if (!_canDowngradeDocumentStatus(previousStatus, status)) return;
    }

    emit(
      current.copyWith(
        mouUpdatingUserId: investorId,
        mouStatus: {...current.mouStatus, investorId: status},
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.saveInvestorMOU(
        investorId: investorId,
        status: status.apiValue,
        documentBytes: hasDocument ? documentBytes : null,
        documentFileName: hasDocument ? documentFileName!.trim() : null,
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final data = response.latestRecord;
      final syncedStatus =
          DocumentProcessStatusX.tryParse(data?.status) ?? status;
      final issuedAt = response.timestampForStatus('Issued') ??
          (syncedStatus == DocumentProcessStatus.issued
              ? data?.effectiveUpdatedAt
              : null);
      final completedAt = response.timestampForStatus('Completed') ??
          (syncedStatus == DocumentProcessStatus.completed
              ? data?.effectiveUpdatedAt
              : null);

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : hasDocument
              ? 'MOU document uploaded'
              : 'MOU status set to ${syncedStatus.label}';

      emit(
        latest.copyWith(
          mouStatus: {...latest.mouStatus, investorId: syncedStatus},
          mouIssuedAt: _mergeTimestamp(
            latest.mouIssuedAt,
            investorId,
            issuedAt,
          ),
          mouCompletedAt: _mergeTimestamp(
            latest.mouCompletedAt,
            investorId,
            completedAt,
          ),
          mouDocumentPath: _mergeDocumentPath(
            latest.mouDocumentPath,
            investorId,
            response.effectiveDocumentPath,
          ),
          mouDocumentUpdatedAt: _mergeTimestamp(
            latest.mouDocumentUpdatedAt,
            investorId,
            response.effectiveDocumentUpdatedAt,
          ),
          clearMouUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: hasDocument ? 'MOU Document Uploaded' : 'MOU Updated',
            message: message,
          ),
        ),
      );
    } catch (error) {
      appLog(
        'Save investor MOU status failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          mouStatus: {...latest.mouStatus, investorId: previousStatus},
          clearMouUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: hasDocument
                ? 'MOU Document Upload Failed'
                : 'MOU Update Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: hasDocument
                  ? 'Failed to upload MOU document'
                  : 'Failed to save investor MOU',
            ),
          ),
        ),
      );
    }
  }

  Future<void> uploadInvestorMouDocument({
    required int investorId,
    required Uint8List documentBytes,
    required String documentFileName,
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;

    final status =
        current.mouStatus[investorId] ?? DocumentProcessStatus.pending;

    await saveInvestorMouStatus(
      investorId: investorId,
      status: status,
      documentBytes: documentBytes,
      documentFileName: documentFileName,
    );
  }

  void clearInvestorMouDocument(int investorId) {
    final current = state;
    if (current is! ManageUsersSuccess) return;

    final paths = Map<int, String>.from(current.mouDocumentPath)
      ..remove(investorId);
    final updatedAt = Map<int, DateTime>.from(current.mouDocumentUpdatedAt)
      ..remove(investorId);

    emit(
      current.copyWith(
        mouDocumentPath: paths,
        mouDocumentUpdatedAt: updatedAt,
        clearStatusFeedback: true,
      ),
    );
  }

  Future<void> fetchInvestorLlpStatus(int investorId) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.llpLoadingUserId == investorId ||
        current.llpUpdatingUserId == investorId) {
      return;
    }

    emit(
      current.copyWith(
        llpLoadingUserId: investorId,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.getInvestorLLP(
        investorId: investorId,
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final data = response.latestRecord;
      final syncedStatus =
          DocumentProcessStatusX.tryParse(data?.status) ??
              DocumentProcessStatus.pending;
      final issuedAt = response.timestampForStatus('Issued');
      final completedAt = response.timestampForStatus('Completed');

      emit(
        latest.copyWith(
          llpStatus: {...latest.llpStatus, investorId: syncedStatus},
          llpIssuedAt: _mergeTimestamp(
            latest.llpIssuedAt,
            investorId,
            issuedAt,
          ),
          llpCompletedAt: _mergeTimestamp(
            latest.llpCompletedAt,
            investorId,
            completedAt,
          ),
          llpDocumentPath: _mergeDocumentPath(
            latest.llpDocumentPath,
            investorId,
            response.effectiveDocumentPath,
          ),
          llpDocumentUpdatedAt: _mergeTimestamp(
            latest.llpDocumentUpdatedAt,
            investorId,
            response.effectiveDocumentUpdatedAt,
          ),
          clearLlpLoadingUserId: true,
        ),
      );
    } catch (error) {
      appLog(
        'Fetch investor LLP status failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      // No saved LLP (or transient failure): keep Pending without toast noise.
      emit(
        latest.copyWith(
          llpStatus: {
            ...latest.llpStatus,
            investorId:
                latest.llpStatus[investorId] ?? DocumentProcessStatus.pending,
          },
          clearLlpLoadingUserId: true,
        ),
      );
    }
  }

  Future<void> saveInvestorLlpStatus({
    required int investorId,
    required DocumentProcessStatus status,
    Uint8List? documentBytes,
    String? documentFileName,
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.llpUpdatingUserId != null ||
        current.llpLoadingUserId != null) {
      return;
    }

    final previousStatus =
        current.llpStatus[investorId] ?? DocumentProcessStatus.pending;
    final hasDocument = documentBytes != null &&
        documentBytes.isNotEmpty &&
        (documentFileName?.trim().isNotEmpty ?? false);

    if (!hasDocument) {
      if (previousStatus == status) return;
      if (!_canDowngradeDocumentStatus(previousStatus, status)) return;
    }

    emit(
      current.copyWith(
        llpUpdatingUserId: investorId,
        llpStatus: {...current.llpStatus, investorId: status},
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.saveInvestorLLP(
        investorId: investorId,
        status: status.apiValue,
        documentBytes: hasDocument ? documentBytes : null,
        documentFileName: hasDocument ? documentFileName!.trim() : null,
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final data = response.latestRecord;
      final syncedStatus =
          DocumentProcessStatusX.tryParse(data?.status) ?? status;
      final issuedAt = response.timestampForStatus('Issued') ??
          (syncedStatus == DocumentProcessStatus.issued
              ? data?.effectiveUpdatedAt
              : null);
      final completedAt = response.timestampForStatus('Completed') ??
          (syncedStatus == DocumentProcessStatus.completed
              ? data?.effectiveUpdatedAt
              : null);

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : hasDocument
              ? 'LLP document uploaded'
              : 'LLP status set to ${syncedStatus.label}';

      emit(
        latest.copyWith(
          llpStatus: {...latest.llpStatus, investorId: syncedStatus},
          llpIssuedAt: _mergeTimestamp(
            latest.llpIssuedAt,
            investorId,
            issuedAt,
          ),
          llpCompletedAt: _mergeTimestamp(
            latest.llpCompletedAt,
            investorId,
            completedAt,
          ),
          llpDocumentPath: _mergeDocumentPath(
            latest.llpDocumentPath,
            investorId,
            response.effectiveDocumentPath,
          ),
          llpDocumentUpdatedAt: _mergeTimestamp(
            latest.llpDocumentUpdatedAt,
            investorId,
            response.effectiveDocumentUpdatedAt,
          ),
          clearLlpUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: hasDocument ? 'LLP Document Uploaded' : 'LLP Updated',
            message: message,
          ),
        ),
      );
    } catch (error) {
      appLog(
        'Save investor LLP status failed: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          llpStatus: {...latest.llpStatus, investorId: previousStatus},
          clearLlpUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: hasDocument
                ? 'LLP Document Upload Failed'
                : 'LLP Update Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: hasDocument
                  ? 'Failed to upload LLP document'
                  : 'Failed to save investor LLP',
            ),
          ),
        ),
      );
    }
  }


  Future<void> fetchInvestorTransactionHistory(String userId) async {
    final current = state;
    if (current is ManageUsersSuccess) {
      emit(InvestorTransactionHistoryLoading.fromSuccess(current));
    } else {
      emit(const InvestorTransactionHistoryLoading());
    }

    try {
      final response =
          await _repository.getInvestorTransactionHistory(userId);

      if (isClosed) return;

      final latest = state;
      if (latest is ManageUsersSuccess) {
        emit(
          InvestorTransactionHistorySuccess.fromSuccess(
            success: latest,
            response: response,
          ),
        );
      } else {
        emit(
          InvestorTransactionHistorySuccess(
            response: response,
          ),
        );
      }
    } on DioException catch (error) {
      if (isClosed) return;

      appLog(
        'Fetch Investor Transaction History Error: ${error.message}',
        name: 'ManageUsersCubit',
      );

      final message = ApiErrorMessage.from(
        error,
        fallback: 'Failed to load transaction history',
      );

      final latest = state;
      if (latest is ManageUsersSuccess) {
        emit(
          InvestorTransactionHistoryFailure.fromSuccess(
            success: latest,
            message: message,
          ),
        );
      } else {
        emit(InvestorTransactionHistoryFailure(message));
      }
    } catch (error) {
      if (isClosed) return;

      appLog(
        'Fetch Investor Transaction History Error: $error',
        name: 'ManageUsersCubit',
      );

      final message = ApiErrorMessage.from(
        error,
        fallback: 'Failed to load transaction history',
      );

      final latest = state;
      if (latest is ManageUsersSuccess) {
        emit(
          InvestorTransactionHistoryFailure.fromSuccess(
            success: latest,
            message: message,
          ),
        );
      } else {
        emit(InvestorTransactionHistoryFailure(message));
      }
    }
  }

  Future<void> fetchBlockRequests({String? status}) async {
    final normalizedStatus = status?.trim();
    final filter =
        normalizedStatus != null && normalizedStatus.isNotEmpty
            ? normalizedStatus
            : null;

    final current = state;
    if (current is ManageUsersSuccess) {
      emit(
        current.copyWith(
          isBlockRequestsLoading: true,
          clearBlockRequestsError: true,
          blockRequestsStatusFilter: filter,
        ),
      );
    } else {
      emit(
        ManageUsersSuccess(
          users: const [],
          isBlockRequestsLoading: true,
          blockRequestsStatusFilter: filter,
        ),
      );
    }

    try {
      final response = await _repository.getBlockRequests(status: filter);

      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          blockRequestsResponse: response,
          isBlockRequestsLoading: false,
          clearBlockRequestsError: true,
          blockRequestsStatusFilter: filter,
        ),
      );
    } on DioException catch (error) {
      if (isClosed) return;

      appLog(
        'Fetch block requests error: ${error.message}',
        name: 'ManageUsersCubit',
      );

      final message = ApiErrorMessage.from(
        error,
        fallback: 'Failed to load block requests',
      );

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          isBlockRequestsLoading: false,
          blockRequestsError: message,
          clearBlockRequestsResponse: true,
          blockRequestsStatusFilter: filter,
        ),
      );
    } catch (error) {
      if (isClosed) return;

      appLog(
        'Fetch block requests error: $error',
        name: 'ManageUsersCubit',
      );

      final message = ApiErrorMessage.from(
        error,
        fallback: 'Failed to load block requests',
      );

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      emit(
        latest.copyWith(
          isBlockRequestsLoading: false,
          blockRequestsError: message,
          clearBlockRequestsResponse: true,
          blockRequestsStatusFilter: filter,
        ),
      );
    }
  }

  Future<String?> reviewBlockRequest({
    required int requestId,
    required String status,
    String remarks = '',
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return null;
    if (current.blockRequestReviewingId != null) return null;

    final normalizedStatus = _normalizeBlockReviewStatus(status);
    if (normalizedStatus == null) return null;

    emit(
      current.copyWith(
        blockRequestReviewingId: requestId,
        clearStatusFeedback: true,
      ),
    );

    try {
      final response = await _repository.reviewBlockRequest(
        requestId: requestId,
        status: normalizedStatus,
        remarks: remarks,
      );

      if (isClosed) return null;

      final latest = state;
      if (latest is! ManageUsersSuccess) return null;

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : normalizedStatus == 'Approved'
              ? 'Block request approved.'
              : 'Block request rejected.';

      final updatedList = _mergeBlockRequestReview(
        latest.blockRequestsResponse,
        response.data,
        requestId: requestId,
        status: normalizedStatus,
        reviewRemarks: remarks.trim().isEmpty ? null : remarks.trim(),
      );

      int? reviewedUserId = response.data?.userId;
      if (reviewedUserId == null || reviewedUserId <= 0) {
        for (final item
            in latest.blockRequestsResponse?.requests ??
                const <InvestorBlockRequestModel>[]) {
          if (item.requestId == requestId) {
            reviewedUserId = item.userId;
            break;
          }
        }
      }

      if (reviewedUserId != null) _pendingTerminateIds.remove(reviewedUserId);

      final approvedActive = response.data?.isActive ?? false;
      if (reviewedUserId != null &&
          normalizedStatus == 'Approved' &&
          !approvedActive) {
        // Mirror of unblock: an active investor became blocked. If the row is
        // not in the loaded list, the list tells us its side: it is missing
        // from the Active list (so already blocked) or from the Blocked list
        // (so it was active).
        final row = latest.users
            .where((item) => item.id == reviewedUserId)
            .firstOrNull;
        final wasActive =
            row?.isActive ?? (_filter == ManageUsersStatusFilter.blocked);
        if (wasActive) _moveCountToBlocked();
      }

      // Drop the row if it no longer belongs to the selected list.
      final updatedUsers = reviewedUserId == null
          ? latest.users
          : _rowsForCurrentFilter([
              for (final item in latest.users)
                if (item.id == reviewedUserId)
                  item.copyWith(
                    isActive: normalizedStatus == 'Approved'
                        ? approvedActive
                        : item.isActive,
                    hasPendingTerminateRequest: false,
                  )
                else
                  item,
            ]);

      emit(
        latest.copyWith(
          users: updatedUsers,
          blockRequestsResponse: updatedList,
          clearBlockRequestReviewingId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: normalizedStatus == 'Approved' ? 'Approved' : 'Rejected',
            message: message,
          ),
        ),
      );

      return message;
    } on DioException catch (error) {
      appLog(
        'Review block request error: ${error.message}',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return null;

      final latest = state;
      if (latest is! ManageUsersSuccess) return null;

      final message = ApiErrorMessage.from(
        error,
        fallback: 'Failed to review block request',
      );

      emit(
        latest.copyWith(
          clearBlockRequestReviewingId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: 'Review failed',
            message: message,
          ),
        ),
      );

      return null;
    } catch (error) {
      appLog(
        'Review block request error: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return null;

      final latest = state;
      if (latest is! ManageUsersSuccess) return null;

      final message = ApiErrorMessage.from(
        error,
        fallback: 'Failed to review block request',
      );

      emit(
        latest.copyWith(
          clearBlockRequestReviewingId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: false,
            title: 'Review failed',
            message: message,
          ),
        ),
      );

      return null;
    }
  }

  String? _normalizeBlockReviewStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'approved') return 'Approved';
    if (normalized == 'rejected') return 'Rejected';
    return null;
  }

  InvestorBlockRequestsResponse? _mergeBlockRequestReview(
    InvestorBlockRequestsResponse? current,
    ReviewBlockRequestResult? result, {
    required int requestId,
    required String status,
    String? reviewRemarks,
  }) {
    if (current == null) return null;

    final updated = current.requests
        .map(
          (item) {
            if (item.requestId != requestId) return item;
            if (result != null) {
              return item.copyWith(
                isActive: result.isActive,
                status: result.status.trim().isNotEmpty
                    ? result.status
                    : status,
                reviewedBy: result.reviewedBy,
                reviewedDate: result.reviewedDate ?? DateTime.now(),
                reviewRemarks:
                    result.reviewRemarks ?? reviewRemarks ?? item.reviewRemarks,
              );
            }
            return item.copyWith(
              status: status,
              reviewedDate: DateTime.now(),
              reviewRemarks: reviewRemarks,
            );
          },
        )
        .toList();

    return InvestorBlockRequestsResponse(
      status: current.status,
      message: current.message,
      requests: updated,
      code: current.code,
    );
  }

  Future<void> uploadInvestorLlpDocument({
    required int investorId,
    required Uint8List documentBytes,
    required String documentFileName,
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;

    final status =
        current.llpStatus[investorId] ?? DocumentProcessStatus.pending;

    await saveInvestorLlpStatus(
      investorId: investorId,
      status: status,
      documentBytes: documentBytes,
      documentFileName: documentFileName,
    );
  }

  void clearInvestorLlpDocument(int investorId) {
    final current = state;
    if (current is! ManageUsersSuccess) return;

    final paths = Map<int, String>.from(current.llpDocumentPath)
      ..remove(investorId);
    final updatedAt = Map<int, DateTime>.from(current.llpDocumentUpdatedAt)
      ..remove(investorId);

    emit(
      current.copyWith(
        llpDocumentPath: paths,
        llpDocumentUpdatedAt: updatedAt,
        clearStatusFeedback: true,
      ),
    );
  }

  bool _canDowngradeDocumentStatus(
    DocumentProcessStatus current,
    DocumentProcessStatus next,
  ) {
    if (current == DocumentProcessStatus.completed) {
      return next == DocumentProcessStatus.completed;
    }
    if (next == DocumentProcessStatus.pending) {
      return current == DocumentProcessStatus.pending;
    }
    return true;
  }

  Map<int, DateTime> _mergeTimestamp(
    Map<int, DateTime> current,
    int investorId,
    DateTime? value,
  ) {
    if (value == null) return current;
    return {...current, investorId: value};
  }

  Map<int, String> _mergeDocumentPath(
    Map<int, String> current,
    int investorId,
    String? path,
  ) {
    final trimmed = path?.trim();
    if (trimmed == null || trimmed.isEmpty) return current;
    return {...current, investorId: trimmed};
  }
}

/// Outcome of one `GetAllInvestors` call: a response or the error thrown.
class _UsersResult {
  const _UsersResult.ok(ManageUsersResponse this.response) : error = null;
  const _UsersResult.failed(Object this.error) : response = null;

  final ManageUsersResponse? response;
  final Object? error;
}
