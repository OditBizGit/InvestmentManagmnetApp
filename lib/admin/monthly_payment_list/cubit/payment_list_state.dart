part of 'payment_list_cubit.dart';

@immutable
sealed class PaymentListState {}

final class PaymentListInitial extends PaymentListState {}

final class PaymentListLoading extends PaymentListState {}

final class PaymentListLoaded extends PaymentListState {
  final MonthlyPaymentListDataModel? data;

  PaymentListLoaded({
    required this.data,
  });
}

final class PaymentListError extends PaymentListState {
  final String message;

  PaymentListError({
    required this.message,
  });
}