part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeSuccess extends HomeState {
  HomeSuccess({
    required this.profile,
    required this.topInvestors,
  });

  final HomeProfileModel profile;
  final List<TopInvestorModel> topInvestors;
}

final class HomeFailure extends HomeState {
  HomeFailure(this.message);

  final String message;
}
