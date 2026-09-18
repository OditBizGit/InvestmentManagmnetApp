import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/add_update_screen.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_big_cards.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_timeline_table.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';

class AdminWorkProgressScreen extends StatefulWidget {
  const AdminWorkProgressScreen({super.key});

  @override
  State<AdminWorkProgressScreen> createState() =>
      _AdminWorkProgressScreenState();
}

class _AdminWorkProgressScreenState extends State<AdminWorkProgressScreen> {
  bool _showAddUpdate = false;

  void _openAddUpdate() {
    setState(() => _showAddUpdate = true);
  }

  void _backToWorkProgress() {
    setState(() => _showAddUpdate = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddUpdate) {
      return AddUpdateScreen(onBack: _backToWorkProgress);
    }

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;

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
                child: const WorkProgressTopBar(),
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
                      WorkProgressOverviewSection(
                        onAddUpdate: _openAddUpdate,
                      ),
                      const SizedBox(height: 20),
                      const WorkProgressBigCards(),
                      const SizedBox(height: 20),
                      const WorkProgressTimelineTable(),
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
