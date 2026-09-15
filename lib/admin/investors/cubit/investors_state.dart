part of 'investors_cubit.dart';

sealed class InvestorsState {}

final class InvestorsInitial extends InvestorsState {}

final class InvestorsLoading extends InvestorsState {}

final class InvestorsSuccess extends InvestorsState {
  InvestorsSuccess(this.investors);

  final List<InvestorModel> investors;
}

final class InvestorsFailure extends InvestorsState {
  InvestorsFailure(this.message);

  final String message;
}
