import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/create_project_screen.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/settings/widgets/settings_option_cards.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/settings/widgets/settings_top_bar.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/user_complaints_screen.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
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

  void _openCreateProject() {
    setState(() {
      _showCreateProject = true;
      _showUserComplaints = false;
    });
  }

  void _openUserComplaints() {
    setState(() {
      _showUserComplaints = true;
      _showCreateProject = false;
    });
  }

  void _backToSettings() {
    setState(() {
      _showCreateProject = false;
      _showUserComplaints = false;
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

    final label = switch (option) {
      SettingsOptionType.createProject => 'Create Project',
      SettingsOptionType.addAdmin => 'Add New Admin',
      SettingsOptionType.userComplaints => 'User Complaints',
    };

    AppToast.info(
      '$label coming soon',
      title: 'Settings',
      context: context,
    );
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
                child: const SettingsTopBar(),
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
