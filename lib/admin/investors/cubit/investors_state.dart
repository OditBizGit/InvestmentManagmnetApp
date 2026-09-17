part of 'investors_cubit.dart';

sealed class InvestorsState {}

final class InvestorsInitial extends InvestorsState {}

final class InvestorsLoading extends InvestorsState {}

final class InvestorsSuccess extends InvestorsState {
  InvestorsSuccess(
    this.investors, {
    this.total = const InvestorTotalsModel(),
  });

  final List<InvestorModel> investors;
  final InvestorTotalsModel total;
}

final class InvestorsFailure extends InvestorsState {
  InvestorsFailure(this.message);

  final String message;
}

final class InvestorTypesLoading extends InvestorsState {}

final class InvestorTypesSuccess extends InvestorsState {
  InvestorTypesSuccess(this.types);

  final List<InvestorTypeModel> types;
}

final class InvestorTypesFailure extends InvestorsState {
  InvestorTypesFailure(this.message);

  final String message;
}

final class RegisterInvestorLoading extends InvestorsState {}

final class RegisterInvestorSuccess extends InvestorsState {
  RegisterInvestorSuccess({
    required this.message,
    this.data,
  });

  final String message;
  final RegisterInvestorDataModel? data;
}

final class RegisterInvestorFailure extends InvestorsState {
  RegisterInvestorFailure(this.message);

  final String message;
}
