import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_main_screen.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/account/account_block_cubit.dart';
import 'package:maribel_wellness_centre_application/core/account/account_block_routes.dart';
import 'package:maribel_wellness_centre_application/core/account/auth_navigation_guard.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart' show isPublicAuthRequest;
import 'package:maribel_wellness_centre_application/core/notifications/notification_service.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/main.dart' show isAdmin;
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';

/// Logs the user out and shows the login screen after an expired / invalid
/// session. Runs only after the token refresh failed (the refresh token was
/// rejected) or when a 401 cannot be recovered; see `TokenRefreshService`.
class SessionExpiryHandler {
  SessionExpiryHandler._();

  static bool _handling = false;

  /// Test seam: replaces the logout + navigation step.
  @visibleForTesting
  static Future<void> Function()? sessionEndedOverride;

  /// Entry point for the Dio interceptor. Expires the session only for a 401
  /// on an authenticated request that carried the currently stored token.
  static Future<void> handleDioError(DioException error) async {
    if (error.response?.statusCode != 401) return;
    if (isPublicAuthRequest(error.requestOptions)) return;
    if (!GetIt.instance.isRegistered<LocalStorage>()) return;
    final current = GetIt.instance<LocalStorage>().getAuthToken();
    if (current == null || current.isEmpty) return;
    if (error.requestOptions.headers['Authorization'] != 'Bearer $current') {
      return;
    }
    await onUnauthorized();
  }

  static Future<void> onUnauthorized() async {
    if (_handling) return;
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<LocalStorage>()) return;
    final storage = getIt<LocalStorage>();
    // Nothing to expire: already logged out (avoids navigation loops).
    final token = storage.getAuthToken();
    if (token == null || token.isEmpty) return;

    _handling = true;
    try {
      final override = sessionEndedOverride;
      if (override != null) {
        await override();
        return;
      }
      final navigator = notificationNavigatorKey.currentState;
      final context = notificationNavigatorKey.currentContext;
      if (context != null) {
        try {
          // The token is already rejected, so skip the server logout call.
          await context.read<LoginCubit>().logout(revokeServerSession: false);
        } catch (_) {
          await _clearManually(storage);
        }
      } else {
        await _clearManually(storage);
      }

      navigator?.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AccountBlockRoutes.login),
          builder: (_) => LoginScreen(
            home: isAdmin ? const AdminMainScreen() : const UserMainScreen(),
            snackBarMessage: 'Your session has expired. Please log in again.',
          ),
        ),
        (route) => false,
      );
    } finally {
      _handling = false;
    }
  }

  static Future<void> _clearManually(LocalStorage storage) async {
    AuthNavigationGuard.suppressAuthenticatedNavigation = true;
    await storage.clearSession();
    if (GetIt.instance.isRegistered<AccountBlockCubit>()) {
      GetIt.instance<AccountBlockCubit>().reset();
    }
  }
}
