part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeSuccess extends HomeState {
  HomeSuccess({
    required this.profile,
    required this.topInvestors,
    this.workProgress = const [],
    this.banners = const [],
    this.latestUpdate,
    this.unreadNotificationCount = 0,
  });

  final HomeProfileModel profile;
  final List<TopInvestorModel> topInvestors;
  final List<WorkProgressItemModel> workProgress;
  final List<BannerItemModel> banners;
  final WorkUpdateModel? latestUpdate;
  final int unreadNotificationCount;
}

final class HomeFailure extends HomeState {
  HomeFailure(this.message);

  final String message;
}
