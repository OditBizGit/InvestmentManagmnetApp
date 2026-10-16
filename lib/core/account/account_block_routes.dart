import 'package:flutter/material.dart';

/// Route names that must not show the account-blocked overlay.
abstract final class AccountBlockRoutes {
  static const String login = '/login';

  /// Splash uses [Navigator.defaultRouteName]. Login is named explicitly.
  /// Every other route, including unnamed user screens, can show the overlay.
  static bool isAuthRouteName(String? name) {
    return name == Navigator.defaultRouteName || name == login;
  }
}

/// Tracks whether the top route is an authentication screen.
class AccountBlockNavigatorObserver extends NavigatorObserver {
  final ValueNotifier<bool> onAuthRoute = ValueNotifier<bool>(true);

  final List<Route<dynamic>> _stack = <Route<dynamic>>[];

  void _emit() {
    final String? name = _stack.isEmpty
        ? Navigator.defaultRouteName
        : _stack.last.settings.name;
    final bool next = AccountBlockRoutes.isAuthRouteName(name);
    if (onAuthRoute.value != next) {
      onAuthRoute.value = next;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _emit();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _emit();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _emit();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      final int index = _stack.indexOf(oldRoute);
      if (index >= 0 && newRoute != null) {
        _stack[index] = newRoute;
      } else {
        _stack.remove(oldRoute);
        if (newRoute != null) _stack.add(newRoute);
      }
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
    _emit();
  }
}

/// User-app only. Not attached when the admin shell is active.
final AccountBlockNavigatorObserver accountBlockNavigatorObserver =
    AccountBlockNavigatorObserver();
