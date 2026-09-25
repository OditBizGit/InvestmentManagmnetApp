part of 'add_banner_cubit.dart';

@immutable
sealed class AddBannerState {
  const AddBannerState();
}

final class AddBannerInitial extends AddBannerState {
  const AddBannerInitial();
}

final class AddBannerLoading extends AddBannerState {
  const AddBannerLoading();
}

final class AddBannerSuccess extends AddBannerState {
  const AddBannerSuccess({
    required this.banner,
    required this.message,
    this.uploadedCount = 1,
  });

  final AddBannerModel banner;
  final String message;
  final int uploadedCount;
}

final class AddBannerFailure extends AddBannerState {
  const AddBannerFailure({
    required this.message,
  });

  final String message;
}

final class GetBannersLoading extends AddBannerState {
  const GetBannersLoading();
}

final class GetBannersSuccess extends AddBannerState {
  const GetBannersSuccess(this.banners);

  final List<BannerModel> banners;
}

final class GetBannersFailure extends AddBannerState {
  const GetBannersFailure(this.message);

  final String message;
}

final class DeleteBannerLoading extends AddBannerState {
  const DeleteBannerLoading({required this.bannerId});

  final int bannerId;
}

final class DeleteBannerSuccess extends AddBannerState {
  const DeleteBannerSuccess({
    required this.bannerId,
    required this.message,
  });

  final int bannerId;
  final String message;
}

final class DeleteBannerFailure extends AddBannerState {
  const DeleteBannerFailure({required this.message});

  final String message;
}
