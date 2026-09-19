part of 'investments_cubit.dart';

sealed class InvestmentsState {
  const InvestmentsState();
}

final class InvestmentsInitial extends InvestmentsState {
  const InvestmentsInitial();
}

final class InvestmentsLoading extends InvestmentsState {
  const InvestmentsLoading();
}

final class InvestmentsSuccess extends InvestmentsState {
  const InvestmentsSuccess(this.data);

  final InvestorTransactionHistoryDataModel data;
}

final class InvestmentsFailure extends InvestmentsState {
  const InvestmentsFailure(this.message);

  final String message;
}
