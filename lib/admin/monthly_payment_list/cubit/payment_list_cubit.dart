

import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../model/monthly_payment_list_model.dart';
import '../model/payment_verification_history_model.dart';
import '../repository/monthly_payment_list_repository.dart';

part 'payment_list_state.dart';

class PaymentListCubit extends Cubit<PaymentListState> {
  PaymentListCubit({
    required MonthlyPaymentListRepository repository,
  })  : _repository = repository,
        super(PaymentListInitial());

  final MonthlyPaymentListRepository _repository;

  DateTime? _lastFromDate;
  DateTime? _lastToDate;

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchMonthlyPaymentList({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    _lastFromDate = fromDate;
    _lastToDate = toDate;

    final hadData = state is PaymentListLoaded &&
        (state as PaymentListLoaded).data != null;

    PaymentListLoaded? previousLoaded;
    if (hadData) {
      previousLoaded = state as PaymentListLoaded;
      emit(previousLoaded.copyWith(isListRefreshing: true, clearActionMessage: true));
    } else {
      emit(PaymentListLoading());
    }

    try {
      final response = await _repository.getMonthlyPaymentList(
        fromDate: _formatDate(fromDate),
        toDate: _formatDate(toDate),
      );

      final preserved = previousLoaded;
      emit(
        PaymentListLoaded(
          data: response.data,
          isListRefreshing: false,
          historyData: preserved?.historyData,
          isHistoryRefreshing: preserved?.isHistoryRefreshing ?? false,
          historyErrorMessage: preserved?.historyErrorMessage,
          historyActionMessage: preserved?.historyActionMessage,
        ),
      );
    } catch (error, stackTrace) {
      appLog(
        'Fetch monthly payment list failed: $error',
        name: 'PaymentListCubit',
        error: error,
        stackTrace: stackTrace,
      );

      if (hadData && previousLoaded != null) {
        emit(
          previousLoaded.copyWith(
            isListRefreshing: false,
            actionMessage: error.toString().replaceFirst('Exception: ', ''),
            actionIsSuccess: false,
          ),
        );
        return;
      }

      emit(
        PaymentListError(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearActionFeedback() {
    final current = state;
    if (current is! PaymentListLoaded) return;
    if (current.actionMessage == null) return;
    emit(current.copyWith(clearActionMessage: true));
  }

  void clearHistoryActionFeedback() {
    final current = state;
    if (current is! PaymentListLoaded) return;
    if (current.historyActionMessage == null) return;
    emit(current.copyWith(clearHistoryActionMessage: true));
  }

  Future<void> fetchPaymentVerificationHistory({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final current = state;

    PaymentListLoaded base;
    if (current is PaymentListLoaded) {
      base = current;
    } else {
      base = PaymentListLoaded();
    }

    final hadHistory = base.historyData != null;

    emit(
      base.copyWith(
        isHistoryRefreshing: true,
        clearHistoryError: true,
        clearHistoryActionMessage: true,
      ),
    );

    try {
      final response = await _repository.getPaymentVerificationHistory(
        fromDate: _formatDate(fromDate),
        toDate: _formatDate(toDate),
      );

      if (isClosed) return;

      final latest = state;
      if (latest is! PaymentListLoaded) return;

      emit(
        latest.copyWith(
          historyData: response.data,
          isHistoryRefreshing: false,
          clearHistoryError: true,
          clearHistoryActionMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      appLog(
        'Fetch payment verification history failed: $error',
        name: 'PaymentListCubit',
        error: error,
        stackTrace: stackTrace,
      );

      if (isClosed) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      final latest = state;

      if (latest is PaymentListLoaded) {
        emit(
          latest.copyWith(
            isHistoryRefreshing: false,
            historyErrorMessage: hadHistory ? null : message,
            historyActionMessage: hadHistory ? message : null,
          ),
        );
        return;
      }

      emit(
        PaymentListLoaded(
          historyErrorMessage: message,
          isHistoryRefreshing: false,
        ),
      );
    }
  }

  /// Approves or rejects one payment verification (`Approved` / `Rejected`).
  Future<void> reviewPaymentVerification({
    required int transactionId,
    required String status,
    String remarks = '',
  }) async {
    final current = state;
    if (current is! PaymentListLoaded) return;
    if (current.isReviewSubmitting) return;

    emit(
      current.copyWith(
        isReviewSubmitting: true,
        clearActionMessage: true,
      ),
    );

    try {
      final response = await _repository.reviewPaymentVerification(
        transactionId: transactionId,
        status: status,
        remarks: remarks,
      );

      if (isClosed) return;

      await _refreshAfterReview();

      if (isClosed) return;

      final latest = state;
      if (latest is PaymentListLoaded) {
        emit(
          latest.copyWith(
            isReviewSubmitting: false,
            actionMessage: response.message.isNotEmpty
                ? response.message
                : 'Payment review submitted successfully.',
            actionIsSuccess: true,
          ),
        );
      }
    } catch (error, stackTrace) {
      appLog(
        'Review payment verification failed: $error',
        name: 'PaymentListCubit',
        error: error,
        stackTrace: stackTrace,
      );

      if (isClosed) return;

      final latest = state;
      if (latest is PaymentListLoaded) {
        emit(
          latest.copyWith(
            isReviewSubmitting: false,
            actionMessage: error.toString().replaceFirst('Exception: ', ''),
            actionIsSuccess: false,
          ),
        );
      }
    }
  }

  /// Approves multiple transactions sequentially (Approve All).
  Future<void> approvePaymentsBatch({
    required List<int> transactionIds,
  }) async {
    if (transactionIds.isEmpty) return;

    final current = state;
    if (current is! PaymentListLoaded) return;
    if (current.isReviewSubmitting) return;

    emit(
      current.copyWith(
        isReviewSubmitting: true,
        clearActionMessage: true,
      ),
    );

    try {
      var lastMessage = '';
      for (final transactionId in transactionIds) {
        final response = await _repository.reviewPaymentVerification(
          transactionId: transactionId,
          status: 'Approved',
          remarks: '',
        );
        lastMessage = response.message.isNotEmpty
            ? response.message
            : 'Payment transaction approved successfully.';
      }

      if (isClosed) return;

      await _refreshAfterReview();

      if (isClosed) return;

      final latest = state;
      if (latest is PaymentListLoaded) {
        final count = transactionIds.length;
        emit(
          latest.copyWith(
            isReviewSubmitting: false,
            actionMessage: count == 1
                ? lastMessage
                : '$count payments approved successfully.',
            actionIsSuccess: true,
          ),
        );
      }
    } catch (error, stackTrace) {
      appLog(
        'Batch approve payments failed: $error',
        name: 'PaymentListCubit',
        error: error,
        stackTrace: stackTrace,
      );

      if (isClosed) return;

      final latest = state;
      if (latest is PaymentListLoaded) {
        emit(
          latest.copyWith(
            isReviewSubmitting: false,
            actionMessage: error.toString().replaceFirst('Exception: ', ''),
            actionIsSuccess: false,
          ),
        );
      }
    }
  }

  Future<void> _refreshAfterReview() async {
    final from = _lastFromDate;
    final to = _lastToDate;
    if (from == null || to == null) return;

    final response = await _repository.getMonthlyPaymentList(
      fromDate: _formatDate(from),
      toDate: _formatDate(to),
    );

    if (isClosed) return;

    final latest = state;
    if (latest is PaymentListLoaded) {
      emit(
        latest.copyWith(
          data: response.data,
          isListRefreshing: false,
        ),
      );
    }
  }
}
