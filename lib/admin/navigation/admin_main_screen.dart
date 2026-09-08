import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/home/home_screen.dart';
import 'package:maribel_wellness_centre_application/admin/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_bottom_nav.dart';
import 'package:maribel_wellness_centre_application/admin/reports/reports_screen.dart';
import 'package:maribel_wellness_centre_application/admin/settings/settings_screen.dart';
import 'package:maribel_wellness_centre_application/admin/users/users_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    AdminHomeScreen(),
    AdminUsersScreen(),
    AdminInvestmentsScreen(),
    AdminReportsScreen(),
    AdminSettingsScreen(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
