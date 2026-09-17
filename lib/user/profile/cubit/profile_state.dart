part of 'profile_cubit.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.details);

  final InvestorDetailsModel details;
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;
}
