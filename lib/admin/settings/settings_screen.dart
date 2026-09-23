import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/widgets/settings_option_cards.dart';
import 'package:maribel_wellness_centre_application/admin/settings/widgets/settings_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  void _onOptionSelected(BuildContext context, SettingsOptionType option) {
    final label = switch (option) {
      SettingsOptionType.profile => 'Profile',
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
                        onOptionSelected: (option) =>
                            _onOptionSelected(context, option),
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
