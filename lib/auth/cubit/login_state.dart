part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  LoginSuccess(this.response);

  final LoginResponseModel response;
}

final class LoginFailure extends LoginState {
  LoginFailure(this.message);

  final String message;
}
