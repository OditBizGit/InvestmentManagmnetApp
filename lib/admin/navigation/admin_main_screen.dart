import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:maribel_wellness_centre_application/core/utils/logout_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/work_progress_screen.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../dashboard/dashboard_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  /// Collapse only when width falls clearly below this.
  static const double collapseBelow = 1050;

  /// Expand only when width rises clearly above this.
  /// Gap vs [collapseBelow] prevents Chrome scrollbar width flicker.
  static const double expandAbove = 1180;

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  AdminDrawerItem _selectedItem = AdminDrawerItem.dashboard;
  bool _isCollapsed = false;

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

  Future<void> _onLogout() async {
    final confirmed = await showLogoutConfirmDialog(context);
    if (!confirmed || !mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(home: AdminMainScreen()),
      ),
      (_) => false,
    );
  }

  void _syncCollapsedForWidth(double width) {
    final shouldCollapse = _isCollapsed
        ? width < AdminMainScreen.expandAbove
        : width < AdminMainScreen.collapseBelow;

    if (shouldCollapse == _isCollapsed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || shouldCollapse == _isCollapsed) return;
      setState(() => _isCollapsed = shouldCollapse);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _syncCollapsedForWidth(constraints.maxWidth);

        return Scaffold(
          backgroundColor: AppColors.screenBg,
          body: NotificationListener<AdminNavigateNotification>(
            onNotification: (notification) {
              _onSelect(notification.item);
              return true;
            },
            child: ScrollConfiguration(
              // Keep scrollbar gutter stable on web so width doesn't jump.
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: true,
              ),
              child: Row(
                children: [
                  AdminSideDrawer(
                    selectedItem: _selectedItem,
                    onItemSelected: _onSelect,
                    onLogout: _onLogout,
                    collapsed: _isCollapsed,
                    animate: !kIsWeb,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_selectedItem != AdminDrawerItem.dashboard &&
                            _selectedItem != AdminDrawerItem.investors)
                          Container(
                            height: 56,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
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
            ),
          ),
        );
      },
    );
  }
}
