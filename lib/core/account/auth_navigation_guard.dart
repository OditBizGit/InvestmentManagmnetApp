import 'package:flutter/foundation.dart';

/// Blocks authenticated navigation while a forced logout is in progress.
class AuthNavigationGuard {
  AuthNavigationGuard._();

  /// Login success, splash restore, and notification taps must not open
  /// the home shell while this is true.
  static bool suppressAuthenticatedNavigation = false;

  /// Keeps the blocked overlay up after auth state is reset, until login
  /// is the only route. Avoids revealing the home shell in between.
  static final ValueNotifier<bool> holdBlockedOverlay = ValueNotifier<bool>(
    false,
  );
}
