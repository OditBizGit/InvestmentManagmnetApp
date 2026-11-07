import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/repository/pending_request_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

part 'pending_requests_state.dart';

class PendingRequestsCubit extends Cubit<PendingRequestsState> {
  PendingRequestsCubit({
    required this._repository,
    required this._paymentRepository,
  })  : super(const PendingRequestsInitial());

  final PaymentRequestRepository _repository;
  final InvestorPaymentRepository _paymentRepository;

  PendingRequestsListFilter _statusFilter = PendingRequestsListFilter.all;
  CancelToken? _cancelToken;
  CancelToken? _investorDetailsCancelToken;

  Future<void> loadRequests({
    PendingRequestsListFilter? statusFilter,
    bool silent = false,
  }) async {
    if (statusFilter != null) {
      _statusFilter = statusFilter;
    }

    _cancelToken?.cancel('Superseded by a new request');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    final previous = state;

    if (!_statusFilter.usesPaymentRequestApi) {
      emit(
        PendingRequestsSuccess(
          requests: const [],
          overview: _overviewFromState(previous),
          statusFilter: _statusFilter,
        ),
      );
      return;
    }

    if (!silent) {
      _emitLoading(previous);
    }

    try {
      final response = await _repository.getPaymentRequests(
        status: _statusFilter.apiStatus,
      );
      if (isClosed || cancelToken.isCancelled) return;

      final requests = response.data
          .map(PendingRequestModel.fromPaymentRequest)
          .toList(growable: false);

      final overview = _buildOverview(
        requests,
        previous: previous,
      );

      emit(
        PendingRequestsSuccess(
          requests: List<PendingRequestModel>.unmodifiable(requests),
          overview: overview,
          statusFilter: _statusFilter,
        ),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || isClosed) return;
      if (silent && previous is PendingRequestsSuccess) return;
      emit(
        PendingRequestsFailure(
          message: ApiErrorMessage.from(
            error,
            fallback: 'Failed to load payment requests',
          ),
          statusFilter: _statusFilter,
          overview: _overviewFromState(previous),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      if (silent && previous is PendingRequestsSuccess) return;
      emit(
        PendingRequestsFailure(
          message: ApiErrorMessage.from(
            error,
            fallback: 'Failed to load payment requests',
          ),
          statusFilter: _statusFilter,
          overview: _overviewFromState(previous),
        ),
      );
    }
  }

  Future<void> fetchInvestorDetails(int userId) async {
    final current = state;
    if (current is! PendingRequestsSuccess || userId <= 0) return;

    _investorDetailsCancelToken?.cancel('Superseded by a new request');
    final cancelToken = CancelToken();
    _investorDetailsCancelToken = cancelToken;

    emit(
      current.copyWith(
        isInvestorDetailsLoading: true,
        clearInvestorDetails: true,
        clearInvestorDetailsError: true,
      ),
    );

    try {
      final response = await _paymentRepository.getInvestorDetails(
        userId: userId,
      );
      if (isClosed || cancelToken.isCancelled) return;

      final latest = state;
      if (latest is! PendingRequestsSuccess) return;

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!looksSuccessful || response.data == null) {
        emit(
          latest.copyWith(
            isInvestorDetailsLoading: false,
            clearInvestorDetails: true,
            investorDetailsError: response.message.isNotEmpty
                ? response.message
                : 'Failed to load investor details',
          ),
        );
        return;
      }

      emit(
        latest.copyWith(
          investorDetails: response.data,
          isInvestorDetailsLoading: false,
          clearInvestorDetailsError: true,
        ),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || isClosed) return;
      final latest = state;
      if (latest is! PendingRequestsSuccess) return;
      emit(
        latest.copyWith(
          isInvestorDetailsLoading: false,
          clearInvestorDetails: true,
          investorDetailsError: ApiErrorMessage.from(
            error,
            fallback: 'Failed to load investor details',
          ),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      final latest = state;
      if (latest is! PendingRequestsSuccess) return;
      emit(
        latest.copyWith(
          isInvestorDetailsLoading: false,
          clearInvestorDetails: true,
          investorDetailsError: ApiErrorMessage.from(
            error,
            fallback: 'Failed to load investor details',
          ),
        ),
      );
    }
  }

  void clearInvestorDetails() {
    _investorDetailsCancelToken?.cancel('Cleared investor details');
    final current = state;
    if (current is! PendingRequestsSuccess) return;
    emit(
      current.copyWith(
        clearInvestorDetails: true,
        clearInvestorDetailsError: true,
        isInvestorDetailsLoading: false,
      ),
    );
  }

  void clearReviewFeedback() {
    final current = state;
    if (current is! PendingRequestsSuccess) return;
    if (current.reviewFeedback == null) return;
    emit(current.copyWith(clearReviewFeedback: true));
  }

  /// Approves or rejects a payment request via API.
  ///
  /// [status] must be `Approved` or `Rejected`. Remarks are required by the
  /// UI for rejections; approvals may pass an empty string.
  Future<void> reviewPaymentRequest({
    required int requestId,
    required String status,
    String remarks = '',
  }) async {
    final current = state;
    if (current is! PendingRequestsSuccess) return;
    if (current.isReviewSubmitting) return;

    final normalizedStatus = status.trim();
    final nextStatus = PendingRequestStatusX.fromApi(normalizedStatus);

    emit(
      current.copyWith(
        isReviewSubmitting: true,
        clearReviewFeedback: true,
      ),
    );

    try {
      final response = await _repository.acceptOrRejectPaymentRequest(
        requestId: requestId,
        status: normalizedStatus,
        remarks: remarks.trim(),
      );
      if (isClosed) return;

      final latest = state;
      if (latest is! PendingRequestsSuccess) return;

      final updatedRequests = [
        for (final request in latest.requests)
          if (request.id == requestId.toString())
            request.copyWith(status: nextStatus)
          else
            request,
      ];

      emit(
        latest.copyWith(
          isReviewSubmitting: false,
          requests: List<PendingRequestModel>.unmodifiable(updatedRequests),
          overview: _statusFilter == PendingRequestsListFilter.all
              ? PendingRequestsOverviewStats.from(updatedRequests)
              : latest.overview,
          reviewFeedback: PendingRequestReviewFeedback(
            isSuccess: true,
            message: response.message.trim().isNotEmpty
                ? response.message.trim()
                : nextStatus == PendingRequestStatus.approved
                    ? 'Payment request approved successfully'
                    : 'Payment request rejected successfully',
            status: nextStatus,
          ),
        ),
      );
    } on DioException catch (error) {
      if (isClosed) return;
      final latest = state;
      if (latest is! PendingRequestsSuccess) return;
      emit(
        latest.copyWith(
          isReviewSubmitting: false,
          reviewFeedback: PendingRequestReviewFeedback(
            isSuccess: false,
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to update payment request',
            ),
          ),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      final latest = state;
      if (latest is! PendingRequestsSuccess) return;
      emit(
        latest.copyWith(
          isReviewSubmitting: false,
          reviewFeedback: PendingRequestReviewFeedback(
            isSuccess: false,
            message: ApiErrorMessage.from(
              error,
              fallback: 'Failed to update payment request',
            ),
          ),
        ),
      );
    }
  }

  void _emitLoading(PendingRequestsState previous) {
    switch (previous) {
      case PendingRequestsSuccess():
        emit(
          previous.copyWith(
            isListLoading: true,
            statusFilter: _statusFilter,
          ),
        );
      case PendingRequestsFailure():
        emit(PendingRequestsLoading(statusFilter: _statusFilter));
      default:
        emit(PendingRequestsLoading(statusFilter: _statusFilter));
    }
  }

  PendingRequestsOverviewStats _overviewFromState(PendingRequestsState state) {
    return switch (state) {
      PendingRequestsSuccess(:final overview) => overview,
      PendingRequestsFailure(:final overview) => overview,
      _ => PendingRequestsOverviewStats.empty,
    };
  }

  PendingRequestsOverviewStats _buildOverview(
    List<PendingRequestModel> requests, {
    required PendingRequestsState previous,
  }) {
    if (_statusFilter == PendingRequestsListFilter.all) {
      return PendingRequestsOverviewStats.from(requests);
    }
    final previousOverview = _overviewFromState(previous);
    if (previousOverview != PendingRequestsOverviewStats.empty) {
      return previousOverview;
    }
    return PendingRequestsOverviewStats.from(requests);
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('Cubit closed');
    _investorDetailsCancelToken?.cancel('Cubit closed');
    return super.close();
  }
}
