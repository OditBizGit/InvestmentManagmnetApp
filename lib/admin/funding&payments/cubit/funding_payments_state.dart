part of 'funding_payments_cubit.dart';

sealed class FundingPaymentsState {}

final class FundingPaymentsInitial extends FundingPaymentsState {}

final class FundingInvestorsLoading extends FundingPaymentsState {}

final class FundingInvestorsSuccess extends FundingPaymentsState {
  FundingInvestorsSuccess(this.investors);

  final List<InvestorModel> investors;
}

final class FundingInvestorsFailure extends FundingPaymentsState {
  FundingInvestorsFailure(this.message);

  final String message;
}

final class AddPaymentLoading extends FundingPaymentsState {}

final class AddPaymentSuccess extends FundingPaymentsState {
  AddPaymentSuccess({
    required this.message,
    this.data,
  });

  final String message;
  final InvestorPaymentDataModel? data;
}

final class AddPaymentFailure extends FundingPaymentsState {
  AddPaymentFailure(this.message);

  final String message;
}
