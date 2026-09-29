part of 'create_admin_cubit.dart';

@immutable
sealed class CreateAdminState {}

final class CreateAdminInitial extends CreateAdminState {}

final class CreateAdminLoading extends CreateAdminState {}

final class CreateAdminSuccess extends CreateAdminState {
  CreateAdminSuccess({
    required this.message,
    this.data,
  });

  final String message;
  final CreateAdminModel? data;
}

final class CreateAdminFailure extends CreateAdminState {
  CreateAdminFailure(this.message);

  final String message;
}
