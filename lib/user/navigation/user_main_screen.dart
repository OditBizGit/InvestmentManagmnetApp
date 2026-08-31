import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/home/home_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_bottom_nav.dart';
import 'package:maribel_wellness_centre_application/user/profile/profile_screen.dart';
import 'package:maribel_wellness_centre_application/user/status/status_screen.dart';
import 'package:maribel_wellness_centre_application/user/updates/updates_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = UserBottomNav.homeIndex;

  static const List<Widget> _screens = [
    UserHomeScreen(),
    UserInvestmentsScreen(),
    UserStatusScreen(),
    UserUpdatesScreen(),
    UserProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
