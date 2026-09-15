import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  int _currentIndex = UserBottomNav.homeIndex;
  DateTime? _lastBackPressedAt;

  static const List<Widget> _screens = [
    UserHomeScreen(),
    UserInvestmentsScreen(),
    UserStatusScreen(),
    UserUpdatesScreen(),
    UserProfileScreen(),
  ];

  void selectTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() => _currentIndex = index);
  }

  void _handleBackPress() {
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: UserBottomNav(
          currentIndex: _currentIndex,
          onTap: selectTab,
        ),
      ),
    );
  }
}
