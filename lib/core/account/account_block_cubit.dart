import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/account/auth_navigation_guard.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

part 'account_block_state.dart';

/// Tracks whether the logged-in investor account is blocked (`isActive == false`).
class AccountBlockCubit extends Cubit<AccountBlockState> {
  AccountBlockCubit({required LocalStorage localStorage})
      : _localStorage = localStorage,
        super(const AccountActive());

  final LocalStorage _localStorage;

  /// Syncs UI state from the value already persisted in [LocalStorage].
  ///
  /// Only emits [AccountBlocked] when `isActive` was explicitly stored as
  /// `false`. Missing values stay active until an API confirms a block.
  void syncFromStorage() {
    if (!_localStorage.hasValidSession()) {
      emit(const AccountActive());
      return;
    }

    if (_localStorage.getIsActiveOrNull() == false) {
      emit(const AccountBlocked());
    } else {
      emit(const AccountActive());
    }
  }

  bool _sessionWasCleared() {
    return AuthNavigationGuard.suppressAuthenticatedNavigation ||
        !_localStorage.hasValidSession();
  }

  /// Persists [isActive] and emits blocked/active. Safe to call from network layer.
  ///
  /// Ignores late responses after logout so they cannot restore a block flag
  /// or send the user back into the authenticated shell.
  Future<void> applyIsActive(bool isActive) async {
    if (_sessionWasCleared()) return;

    try {
      await _localStorage.setIsActive(isActive);
    } catch (_) {
      // Storage failure must not crash response handling.
    }

    if (_sessionWasCleared()) return;

    if (isActive) {
      if (state is! AccountActive) emit(const AccountActive());
    } else {
      if (state is! AccountBlocked) emit(const AccountBlocked());
    }
  }

  /// Clears blocked UI state after logout / session wipe.
  void reset() {
    emit(const AccountActive());
  }
}
