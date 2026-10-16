import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/account/account_block_cubit.dart';
import 'package:maribel_wellness_centre_application/core/account/account_status_monitor.dart';
import 'package:maribel_wellness_centre_application/core/account/auth_navigation_guard.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/user/home/home_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_bottom_nav.dart';
import 'package:maribel_wellness_centre_application/user/profile/profile_screen.dart';
import 'package:maribel_wellness_centre_application/user/status/status_screen.dart';
import 'package:maribel_wellness_centre_application/user/updates/updates_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  static void goToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_UserMainScreenState>()?.selectTab(index);
  }

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  static const Duration _exitConfirmWindow = Duration(seconds: 2);

  static const Duration _accountStatusInterval = Duration(seconds: 5);

  int _currentIndex = UserBottomNav.homeIndex;
  DateTime? _lastBackPressedAt;
  Timer? _accountStatusTimer;

  @override
  void initState() {
    super.initState();
    // Reflect login-time / previously persisted isActive immediately.
    getIt<AccountBlockCubit>().syncFromStorage();
    _accountStatusTimer = Timer.periodic(
      _accountStatusInterval,
      (_) => _refreshAccountStatus(),
    );
    _refreshAccountStatus();
  }

  @override
  void dispose() {
    _accountStatusTimer?.cancel();
    super.dispose();
  }

  /// Same investor-details check profile uses, for every user tab.
  void _refreshAccountStatus() {
    if (AuthNavigationGuard.suppressAuthenticatedNavigation) {
      _accountStatusTimer?.cancel();
      return;
    }
    AccountStatusMonitor.refresh();
  }

  void selectTab(int index) {
    if (getIt<AccountBlockCubit>().state is AccountBlocked) {
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() => _currentIndex = index);
    _refreshAccountStatus();
  }

  List<Widget> get _screens => [
        UserHomeScreen(isActive: _currentIndex == UserBottomNav.homeIndex),
        const UserInvestmentsScreen(),
        UserStatusScreen(
          isActive: _currentIndex == UserBottomNav.statusIndex,
        ),
        UserUpdatesScreen(
          isActive: _currentIndex == UserBottomNav.updatesIndex,
        ),
        const UserProfileScreen(),
      ];

  void _handleBackPress({required bool isBlocked}) {
    if (isBlocked) {
      // Overlay is non-bypassable; back must not dismiss it or exit into the app.
      return;
    }

    final now = DateTime.now();
    final lastPressed = _lastBackPressedAt;

    if (lastPressed != null &&
        now.difference(lastPressed) <= _exitConfirmWindow) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    AppSnackBar.show(
      context,
      message: 'Press back again to exit',
      duration: _exitConfirmWindow,
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBlockCubit, AccountBlockState>(
      builder: (context, blockState) {
        final isBlocked = blockState is AccountBlocked;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackPress(isBlocked: isBlocked);
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: isBlocked
                ? null
                : UserBottomNav(
                    currentIndex: _currentIndex,
                    onTap: selectTab,
                  ),
          ),
        );
      },
    );
  }
}
