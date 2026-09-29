import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/screen/create_admin_screen.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/create_project_screen.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/settings/widgets/settings_option_cards.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/user_complaints_screen.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_colors.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _showCreateProject = false;
  bool _showUserComplaints = false;
  bool _showCreateAdmin = false;

  /// Defer tree swaps until after pointer/hover tracking finishes (Windows/desktop).
  void _navigate(VoidCallback action) {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        action();
      });
    });
  }

  void _openCreateProject() {
    _navigate(() {
      setState(() {
        _showCreateProject = true;
        _showUserComplaints = false;
        _showCreateAdmin = false;
      });
    });
  }

  void _openUserComplaints() {
    _navigate(() {
      setState(() {
        _showUserComplaints = true;
        _showCreateProject = false;
        _showCreateAdmin = false;
      });
    });
  }

  void _openCreateAdmin() {
    _navigate(() {
      setState(() {
        _showCreateAdmin = true;
        _showCreateProject = false;
        _showUserComplaints = false;
      });
    });
  }

  void _backToSettings() {
    _navigate(() {
      setState(() {
        _showCreateProject = false;
        _showUserComplaints = false;
        _showCreateAdmin = false;
      });
    });
  }

  void _onOptionSelected(SettingsOptionType option) {
    if (option == SettingsOptionType.createProject) {
      _openCreateProject();
      return;
    }
    if (option == SettingsOptionType.userComplaints) {
      _openUserComplaints();
      return;
    }
    if (option == SettingsOptionType.addAdmin) {
      _openCreateAdmin();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCreateProject) {
      return CreateProjectScreen(
        onBack: _backToSettings,
        onCreateSuccess: _backToSettings,
      );
    }

    if (_showUserComplaints) {
      return UserComplaintsScreen(onBack: _backToSettings);
    }

    if (_showCreateAdmin) {
      return CreateAdminScreen(onBack: _backToSettings);
    }

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  16,
                ),
                child: const AdminTopBar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Account & Access',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SettingsOptionCards(
                        onOptionSelected: _onOptionSelected,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
