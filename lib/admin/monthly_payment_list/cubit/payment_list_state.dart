part of 'payment_list_cubit.dart';

@immutable
sealed class PaymentListState {}

final class PaymentListInitial extends PaymentListState {}

final class PaymentListLoading extends PaymentListState {}

final class PaymentListLoaded extends PaymentListState {
  PaymentListLoaded({
    this.data,
    this.isListRefreshing = false,
    this.isReviewSubmitting = false,
    this.actionMessage,
    this.actionIsSuccess = false,
    this.historyData,
    this.isHistoryRefreshing = false,
    this.historyErrorMessage,
    this.historyActionMessage,
  });

  final MonthlyPaymentListDataModel? data;
  final bool isListRefreshing;
  final bool isReviewSubmitting;
  final String? actionMessage;
  final bool actionIsSuccess;
  final PaymentVerificationHistoryDataModel? historyData;
  final bool isHistoryRefreshing;
  final String? historyErrorMessage;
  final String? historyActionMessage;

  PaymentListLoaded copyWith({
    MonthlyPaymentListDataModel? data,
    bool? isListRefreshing,
    bool? isReviewSubmitting,
    String? actionMessage,
    bool? actionIsSuccess,
    PaymentVerificationHistoryDataModel? historyData,
    bool? isHistoryRefreshing,
    String? historyErrorMessage,
    String? historyActionMessage,
    bool clearActionMessage = false,
    bool clearHistoryError = false,
    bool clearHistoryActionMessage = false,
  }) {
    return PaymentListLoaded(
      data: data ?? this.data,
      isListRefreshing: isListRefreshing ?? this.isListRefreshing,
      isReviewSubmitting: isReviewSubmitting ?? this.isReviewSubmitting,
      actionMessage:
          clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionIsSuccess: actionIsSuccess ?? this.actionIsSuccess,
      historyData: historyData ?? this.historyData,
      isHistoryRefreshing: isHistoryRefreshing ?? this.isHistoryRefreshing,
      historyErrorMessage: clearHistoryError
          ? null
          : (historyErrorMessage ?? this.historyErrorMessage),
      historyActionMessage: clearHistoryActionMessage
          ? null
          : (historyActionMessage ?? this.historyActionMessage),
    );
  }
}

final class PaymentListError extends PaymentListState {
  final String message;

  PaymentListError({
    required this.message,
  });
}
