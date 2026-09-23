import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/investors_screen/investors_screen.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/settings/settings_screen.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_footer.dart';
import 'package:maribel_wellness_centre_application/core/utils/logout_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/work_progress_screen.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';

import '../dashboard/dashboard_screen.dart';
import '../funding&payments/screens/funding&payents/funding_payments_screen.dart';
import '../reports/screens/reports_screen.dart';

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

  void _onSelect(AdminDrawerItem item) {
    if (_selectedItem == item) return;
    setState(() => _selectedItem = item);
  }

  Future<void> _onLogout() async {
    final confirmed = await showLogoutConfirmDialog(context);
    if (!confirmed || !mounted) return;

    await context.read<LoginCubit>().logout();
    if (!mounted) return;

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

  Widget _screenFor(AdminDrawerItem item) {
    switch (item) {
      case AdminDrawerItem.dashboard:
        return const AdminHomeScreen();
      case AdminDrawerItem.investors:
        return const AdminInvestorsScreen();
      case AdminDrawerItem.fundingPayments:
        return const AdminFundingPaymentsScreen();
      case AdminDrawerItem.workProgress:
        return const AdminWorkProgressScreen();
      case AdminDrawerItem.reports:
        return const AdminReportsScreen();
      case AdminDrawerItem.settings:
        return const AdminSettingsScreen();
    }
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
              // Never use copyWith(scrollbars: true) — it wraps ScrollViews in a
              // Scrollbar without a controller and crashes on desktop/web reload.
              // MaterialScrollBehavior already paints scrollbars with a valid controller.
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
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
                        Expanded(
                          child: IndexedStack(
                            index: _selectedItem.index,
                            children: AdminDrawerItem.values
                                .map(_screenFor)
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
