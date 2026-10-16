import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/account/account_block_cubit.dart';
import 'package:maribel_wellness_centre_application/core/account/auth_navigation_guard.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';

/// Safely inspects Dio responses for investor `isActive` and updates
/// [AccountBlockCubit]. Never throws — must not break the network pipeline.
class AccountStatusMonitor {
  AccountStatusMonitor._();

  static bool _refreshing = false;

  /// Reloads the logged-in investor so [onResponse] can apply `isActive`.
  ///
  /// Profile already does this on refresh. Investments, status, and updates
  /// do not return `isActive`, so those screens call this on refresh too.
  static Future<void> refresh() async {
    if (AuthNavigationGuard.suppressAuthenticatedNavigation) return;
    if (_refreshing) return;
    _refreshing = true;
    try {
      if (!getIt.isRegistered<LocalStorage>() ||
          !getIt.isRegistered<ProfileRepository>() ||
          !getIt.isRegistered<AccountBlockCubit>()) {
        return;
      }

      final storage = getIt<LocalStorage>();
      final role = storage.getUserRole()?.trim().toLowerCase() ?? '';
      if (role != 'investor' || !storage.hasValidSession()) return;
      if (getIt<AccountBlockCubit>().state is AccountBlocked) return;

      final userId = storage.getUserId();
      if (userId == null || userId.isEmpty) return;

      await getIt<ProfileRepository>().getInvestorDetails(userId);
    } catch (_) {
      // Status checks must not surface as screen errors.
    } finally {
      _refreshing = false;
    }
  }

  static void onResponse(Response<dynamic> response) {
    try {
      if (AuthNavigationGuard.suppressAuthenticatedNavigation) return;

      final path = response.requestOptions.path;
      final fullPath = response.requestOptions.uri.path;
      final isLogin = path.contains(ApiEndpoints.login) ||
          fullPath.contains(ApiEndpoints.login);
      final isInvestorDetails =
          path.contains(ApiEndpoints.investorDetails) ||
              fullPath.contains(ApiEndpoints.investorDetails);

      if (!isLogin && !isInvestorDetails) return;

      // Investor-details responses that arrive after the session is wiped
      // must not write `isActive` back into SharedPreferences.
      if (!isLogin &&
          getIt.isRegistered<LocalStorage>() &&
          !getIt<LocalStorage>().hasValidSession()) {
        return;
      }

      final body = response.data;
      if (body is! Map) return;

      final payload = body['data'];
      if (payload is! Map) return;

      if (!_isInvestorAccount(Map<String, dynamic>.from(payload))) return;

      if (!_hasIsActiveField(Map<String, dynamic>.from(payload))) return;

      final isActive = _readBool(
        payload['isActive'] ?? payload['IsActive'],
      );

      if (!getIt.isRegistered<AccountBlockCubit>()) return;
      getIt<AccountBlockCubit>().applyIsActive(isActive);
    } catch (_) {
      // Swallow all parsing / DI errors so API consumers are unaffected.
    }
  }

  static bool _isInvestorAccount(Map<String, dynamic> payload) {
    final fromPayload =
        (payload['userRole'] ?? payload['UserRole'] ?? '').toString().trim();
    if (fromPayload.toLowerCase() == 'investor') return true;

    final stored =
        getIt<LocalStorage>().getUserRole()?.trim().toLowerCase() ?? '';
    return stored == 'investor';
  }

  static bool _hasIsActiveField(Map<String, dynamic> payload) {
    return payload.containsKey('isActive') || payload.containsKey('IsActive');
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
