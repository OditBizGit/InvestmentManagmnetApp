import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/cubit/work_progress_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/work_progress/widgets/work_progress_timeline_table.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class WorkProgressOverviewSection extends StatelessWidget {
  const WorkProgressOverviewSection({
    super.key,
    this.onAddUpdate,
  });

  final VoidCallback? onAddUpdate;

  List<_StatCardData> _buildStats(List<WorkPhaseListModel> phases) {
    final rows = phases
        .map(WorkProgressTimelineRow.fromPhase)
        .toList(growable: false);
    final total = rows.length;
    final completed = rows
        .where((row) => row.status == WorkProgressStageStatus.completed)
        .length;
    final inProgress = rows
        .where((row) => row.status == WorkProgressStageStatus.inProgress)
        .length;
    final pending = rows
        .where((row) => row.status == WorkProgressStageStatus.pending)
        .length;
    final overallProgress = total == 0
        ? 0
        : (rows.fold<int>(0, (sum, row) => sum + row.progress) / total)
            .round()
            .clamp(0, 100);

    return [
      _StatCardData(
        label: 'Overall Progress',
        value: '$overallProgress%',
        icon: ImageConstants.workProgress,
        iconColor: const Color(0xFF9B7EBF),
        iconBg: const Color(0xFFF0EBF6),
      ),
      _StatCardData(
        label: 'Completed Tasks',
        value: '$completed/$total',
        icon: ImageConstants.active,
        iconColor: const Color(0xFF2CB5A8),
        iconBg: const Color(0xFFE6F7F5),
      ),
      _StatCardData(
        label: 'In Progress',
        value: '$inProgress',
        icon: ImageConstants.amountRemaining,
        iconColor: const Color(0xFFE06B7A),
        iconBg: const Color(0xFFFDECEE),
      ),
      _StatCardData(
        label: 'Pending Task',
        value: '$pending',
        icon: ImageConstants.documents,
        iconColor: const Color(0xFF5B8DEF),
        iconBg: const Color(0xFFEAF1FC),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkProgressCubit, WorkProgressState>(
      builder: (context, state) {
        final cubit = context.read<WorkProgressCubit>();
        final phases = state is WorkProgressSuccess
            ? state.phases
            : cubit.phases;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkProgressTitleRow(onAddUpdate: onAddUpdate),
            const SizedBox(height: 20),
            _StatsGrid(stats: _buildStats(phases)),
          ],
        );
      },
    );
  }
}

class _WorkProgressTitleRow extends StatelessWidget {
  const _WorkProgressTitleRow({this.onAddUpdate});

  final VoidCallback? onAddUpdate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work Progress',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track and manage hospital construction progress and project updates',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final addUpdateButton = Material(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onAddUpdate,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add Update',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              addUpdateButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            addUpdateButton,
          ],
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 4
            : width >= 560
                ? 2
                : 1;

        if (columns == 4) {
          return Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                Expanded(child: _SummaryCard(data: stats[i])),
              ],
            ],
          );
        }

        final cardWidth =
            ((width - (spacing * (columns - 1))) / columns).clamp(140.0, width);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: cardWidth,
                child: _SummaryCard(data: stat),
              ),
          ],
        );
      },
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final String icon;
  final Color iconColor;
  final Color iconBg;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              data.icon,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(data.iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
