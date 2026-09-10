import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/funding/funding_payments_screen.dart';
import 'package:maribel_wellness_centre_application/admin/investors/investors_screen.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';
import 'package:maribel_wellness_centre_application/admin/photos_videos/photos_videos_screen.dart';
import 'package:maribel_wellness_centre_application/admin/reports/reports_screen.dart';
import 'package:maribel_wellness_centre_application/admin/settings/settings_screen.dart';
import 'package:maribel_wellness_centre_application/admin/updates/updates_status_screen.dart';
import 'package:maribel_wellness_centre_application/admin/users/users_screen.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_footer.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/work_progress_screen.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../dashboard/dashboard_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  AdminDrawerItem _selectedItem = AdminDrawerItem.dashboard;

  static const Map<AdminDrawerItem, String> _titles = {
    AdminDrawerItem.dashboard: 'Dashboard',
    AdminDrawerItem.investors: 'Investors',
    AdminDrawerItem.fundingPayments: 'Funding & Payments',
    AdminDrawerItem.workProgress: 'Work Progress',
    AdminDrawerItem.photosVideos: 'Photos & Videos',
    AdminDrawerItem.updatesStatus: 'Updates / Status',
    AdminDrawerItem.reports: 'Reports',
    AdminDrawerItem.settings: 'Settings',
    AdminDrawerItem.adminUsers: 'Admin Users',
  };

  static const Map<AdminDrawerItem, Widget> _screens = {
    AdminDrawerItem.dashboard: AdminHomeScreen(),
    AdminDrawerItem.investors: AdminInvestorsScreen(),
    AdminDrawerItem.fundingPayments: AdminFundingPaymentsScreen(),
    AdminDrawerItem.workProgress: AdminWorkProgressScreen(),
    AdminDrawerItem.photosVideos: AdminPhotosVideosScreen(),
    AdminDrawerItem.updatesStatus: AdminUpdatesStatusScreen(),
    AdminDrawerItem.reports: AdminReportsScreen(),
    AdminDrawerItem.settings: AdminSettingsScreen(),
    AdminDrawerItem.adminUsers: AdminUsersScreen(),
  };

  void _onSelect(AdminDrawerItem item) {
    if (_selectedItem == item) return;
    setState(() => _selectedItem = item);
  }

  void _onLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(home: AdminMainScreen()),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Row(
        children: [
          AdminSideDrawer(
            selectedItem: _selectedItem,
            onItemSelected: _onSelect,
            onLogout: _onLogout,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 56,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Text(
                    _titles[_selectedItem]!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedItem.index,
                    children: AdminDrawerItem.values
                        .map((item) => _screens[item]!)
                        .toList(growable: false),
                  ),
                ),
                const AdminFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
