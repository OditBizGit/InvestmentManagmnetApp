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

final class TransactionHistoryLoading extends FundingPaymentsState {}

final class TransactionHistorySuccess extends FundingPaymentsState {
  TransactionHistorySuccess(this.investors);

  final List<FundingInvestorModel> investors;
}

final class TransactionHistoryEmpty extends FundingPaymentsState {
  TransactionHistoryEmpty({
    this.message = 'No investors found',
  });

  final String message;
}

final class TransactionHistoryFailure extends FundingPaymentsState {
  TransactionHistoryFailure(this.message);

  final String message;
}

final class InvestorDetailsLoading extends FundingPaymentsState {}

final class InvestorDetailsSuccess extends FundingPaymentsState {
  InvestorDetailsSuccess(this.details);

  final InvestorDetailsModel details;
}

final class InvestorDetailsFailure extends FundingPaymentsState {
  InvestorDetailsFailure(this.message);

  final String message;
}
