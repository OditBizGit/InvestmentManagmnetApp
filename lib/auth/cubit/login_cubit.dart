import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/auth/model/login_response_model.dart';
import 'package:maribel_wellness_centre_application/auth/repository/login_repository.dart';
import 'package:maribel_wellness_centre_application/core/account/account_block_cubit.dart';
import 'package:maribel_wellness_centre_application/core/account/auth_navigation_guard.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/notifications/notification_service.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this._authRepository,
    required this._localStorage,
    required this._notificationService,
  }) : super(LoginInitial());

  final AuthRepository _authRepository;
  final LocalStorage _localStorage;
  final NotificationService? _notificationService;

  Future<void> login({
    required String username,
    required String password,
    String? requiredRole,
  }) async {
    AuthNavigationGuard.suppressAuthenticatedNavigation = false;
    AuthNavigationGuard.holdBlockedOverlay.value = false;
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
        isActive: data.isActive,
      );

      // Ensure block state matches login even if the Dio monitor raced
      // with [saveSession]'s clear-then-write sequence.
      if (data.userRole.toLowerCase() == 'investor' &&
          getIt.isRegistered<AccountBlockCubit>()) {
        await getIt<AccountBlockCubit>().applyIsActive(data.isActive);
      }

      if (data.userRole.toLowerCase() == 'investor') {
        await _notificationService?.registerDeviceToken();
      }

      emit(LoginSuccess(response));
    } catch (e) {
      emit(
        LoginFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Clears SharedPreferences first, then resets auth state.
  ///
  /// Sets [AuthNavigationGuard.suppressAuthenticatedNavigation] before the
  /// first await so in-flight listeners cannot open the home shell.
  Future<void> logout() async {
    AuthNavigationGuard.suppressAuthenticatedNavigation = true;
    await _localStorage.clearSession();
    if (getIt.isRegistered<AccountBlockCubit>()) {
      getIt<AccountBlockCubit>().reset();
    }
    emit(LoginInitial());
  }
}
