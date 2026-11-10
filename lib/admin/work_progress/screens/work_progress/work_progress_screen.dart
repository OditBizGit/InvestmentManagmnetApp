import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/add_update_screen.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_timeline_table.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';

import 'cubit/work_progress_cubit.dart';

class AdminWorkProgressScreen extends StatefulWidget {
  const AdminWorkProgressScreen({super.key});

  @override
  State<AdminWorkProgressScreen> createState() =>
      _AdminWorkProgressScreenState();
}

class _AdminWorkProgressScreenState extends State<AdminWorkProgressScreen> {
  bool _showAddUpdate = false;
  bool _hasCachedPhases = false;

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

    return RepositoryProvider(
      create: (_) => AddPhaseRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => WorkProgressCubit(
          repository: context.read<AddPhaseRepository>(),
        )..fetchWorkPhaseList(),
        child: BlocConsumer<WorkProgressCubit, WorkProgressState>(
          listener: (context, state) {
            if (state is WorkProgressFailure) {
              AppToast.error(state.message, context: context);
            }
            if (state is WorkProgressSuccess && state.phases.isNotEmpty) {
              _hasCachedPhases = true;
            }
          },
          builder: (context, state) {
            final showRefetchProgress =
                state is WorkProgressLoading && _hasCachedPhases;

            return ColoredBox(
              color: AppColors.screenBg,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding =
                      constraints.maxWidth < 600 ? 16.0 : 24.0;

                  return AdminMainScreenLayout(
                    horizontalPadding: horizontalPadding,
                    showRefetchProgress: showRefetchProgress,
                    body: SingleChildScrollView(
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
                          const WorkProgressTimelineTable(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
