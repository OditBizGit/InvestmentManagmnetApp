import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/auth/model/login_response_model.dart';
import 'package:maribel_wellness_centre_application/auth/repository/login_repository.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this._authRepository,
    required this._localStorage,
  }) : super(LoginInitial());

  final AuthRepository _authRepository;
  final LocalStorage _localStorage;

  Future<void> login({
    required String username,
    required String password,
    String? requiredRole,
  }) async {
    emit(LoginLoading());
    try {
      final response = await _authRepository.login(
        username: username,
        password: password,
      );

      if (!response.status || response.data == null) {
        emit(
          LoginFailure(
            response.message.isNotEmpty ? response.message : 'Login failed',
          ),
        );
        return;
      }

      final data = response.data!;
      if (requiredRole != null &&
          data.userRole.toLowerCase() != requiredRole.toLowerCase()) {
        emit(
          LoginFailure(
            'Access denied. Only $requiredRole accounts can log in here.',
          ),
        );
        return;
      }

      final investorCode = data.investorCode?.trim();
      final profileImage = data.profileImage?.trim();

      // Replace any previous session with the newly returned token/data.
      await _localStorage.saveSession(
        authToken: data.token,
        userId: data.userId.toString(),
        username: data.username,
        fullName: data.fullName,
        userRole: data.userRole,
        userEmail: data.email,
        investorCode:
            (investorCode != null && investorCode.isNotEmpty)
                ? investorCode
                : null,
        profileImage:
            (profileImage != null && profileImage.isNotEmpty)
                ? profileImage
                : null,
      );

      emit(LoginSuccess(response));
    } catch (e) {
      emit(
        LoginFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Clears the stored auth token and all session data, then resets state.
  Future<void> logout() async {
    await _localStorage.clearSession();
    emit(LoginInitial());
  }
}
