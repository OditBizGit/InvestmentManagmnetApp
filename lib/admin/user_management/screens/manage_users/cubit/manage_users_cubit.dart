import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/pdf_excel_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/utils/manage_users_export_file.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

part 'manage_users_state.dart';

class ManageUsersCubit extends Cubit<ManageUsersState> {
  ManageUsersCubit({required ManageUsersRepository repository})
      : _repository = repository,
        super(const ManageUsersInitial());

  final ManageUsersRepository _repository;
  bool _exportInProgress = false;

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
      log(
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

  Future<void> fetchUsers() async {
    final previous = state;
    if (previous is ManageUsersLoading) return;

    if (previous is ManageUsersSuccess) {
      emit(previous.copyWith(isTableLoading: true));
    } else if (previous is ManageUsersEmpty) {
      emit(previous.copyWith(isTableLoading: true));
    } else {
      emit(const ManageUsersLoading());
    }

    try {
      final response = await _repository.getInvestors();
      if (isClosed) return;

      if (response.skippedCount > 0) {
        log(
          'Get manage users skipped ${response.skippedCount} invalid rows',
          name: 'ManageUsersCubit',
        );
      }

      final hasData = response.users.isNotEmpty;
      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful && !hasData) {
        emit(
          ManageUsersFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load users',
          ),
        );
        return;
      }

      if (!hasData) {
        emit(const ManageUsersEmpty());
        return;
      }

      emit(ManageUsersSuccess(users: response.users));
    } on DioException catch (error) {
      if (isClosed) return;
      emit(
        ManageUsersFailure(
          ApiErrorMessage.from(error, fallback: 'Failed to load users'),
        ),
      );
    } catch (error) {
      log(
        'Get manage users unexpected error: $error',
        name: 'ManageUsersCubit',
      );
      if (isClosed) return;
      emit(
        ManageUsersFailure(
          ApiErrorMessage.from(error, fallback: 'Failed to load users'),
        ),
      );
    }
  }

  Future<void> toggleBlockStatus(ManageUsersInvestor user) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.statusUpdatingUserId != null) return;

    final targetIsActive = user.isBlocked;
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
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! ManageUsersSuccess) return;

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : targetIsActive
              ? '$displayName has been unblocked'
              : '$displayName has been terminated';

      emit(
        latest.copyWith(
          users: [
            for (final item in latest.users)
              if (item.id == user.id)
                item.copyWith(isActive: targetIsActive)
              else
                item,
          ],
          clearStatusUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: targetIsActive ? 'User Unblocked' : 'User Terminated',
            message: message,
          ),
        ),
      );
    } catch (error) {
      log(
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
      log(
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
          clearMouLoadingUserId: true,
        ),
      );
    } catch (error) {
      log(
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
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.mouUpdatingUserId != null ||
        current.mouLoadingUserId != null) {
      return;
    }

    final previousStatus =
        current.mouStatus[investorId] ?? DocumentProcessStatus.pending;
    if (previousStatus == status) return;
    if (!_canDowngradeDocumentStatus(previousStatus, status)) return;

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
          clearMouUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: 'MOU Updated',
            message: message,
          ),
        ),
      );
    } catch (error) {
      log(
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
            title: 'MOU Update Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to save investor MOU',
            ),
          ),
        ),
      );
    }
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
          clearLlpLoadingUserId: true,
        ),
      );
    } catch (error) {
      log(
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
  }) async {
    final current = state;
    if (current is! ManageUsersSuccess) return;
    if (current.llpUpdatingUserId != null ||
        current.llpLoadingUserId != null) {
      return;
    }

    final previousStatus =
        current.llpStatus[investorId] ?? DocumentProcessStatus.pending;
    if (previousStatus == status) return;
    if (!_canDowngradeDocumentStatus(previousStatus, status)) return;

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
          clearLlpUpdatingUserId: true,
          statusFeedback: ManageUsersStatusFeedback(
            isSuccess: true,
            title: 'LLP Updated',
            message: message,
          ),
        ),
      );
    } catch (error) {
      log(
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
            title: 'LLP Update Failed',
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to save investor LLP',
            ),
          ),
        ),
      );
    }
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
}
