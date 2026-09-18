import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum WorkProgressStageStatus { completed, inProgress, pending }

class WorkProgressTimelineRow {
  const WorkProgressTimelineRow({
    required this.stage,
    required this.assignedTeam,
    required this.startDate,
    required this.dueDate,
    required this.progress,
    required this.status,
  });

  final String stage;
  final String assignedTeam;
  final String startDate;
  final String dueDate;
  final int progress;
  final WorkProgressStageStatus status;
}

class WorkProgressTimelineTable extends StatefulWidget {
  const WorkProgressTimelineTable({
    super.key,
    this.rows = const [
      WorkProgressTimelineRow(
        stage: 'Foundation',
        assignedTeam: 'Corey Heriwitz',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 100,
        status: WorkProgressStageStatus.completed,
      ),
      WorkProgressTimelineRow(
        stage: 'Structure',
        assignedTeam: 'ABC Constructions',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 85,
        status: WorkProgressStageStatus.inProgress,
      ),
      WorkProgressTimelineRow(
        stage: 'Electrical',
        assignedTeam: 'Alferdo Curtise',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 60,
        status: WorkProgressStageStatus.inProgress,
      ),
      WorkProgressTimelineRow(
        stage: 'Plumbing',
        assignedTeam: 'Design Studio',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 45,
        status: WorkProgressStageStatus.inProgress,
      ),
      WorkProgressTimelineRow(
        stage: 'Interior',
        assignedTeam: 'Talan Baqtista',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 20,
        status: WorkProgressStageStatus.pending,
      ),
      WorkProgressTimelineRow(
        stage: 'External Work',
        assignedTeam: 'Talan Baqtista',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 0,
        status: WorkProgressStageStatus.pending,
      ),
      WorkProgressTimelineRow(
        stage: 'Final Inception',
        assignedTeam: 'Talan Baqtista',
        startDate: '01 Jan, 2026',
        dueDate: '01 Jan, 2026',
        progress: 0,
        status: WorkProgressStageStatus.pending,
      ),
    ],
  });

  final List<WorkProgressTimelineRow> rows;

  @override
  State<WorkProgressTimelineTable> createState() =>
      _WorkProgressTimelineTableState();
}

class _WorkProgressTimelineTableState extends State<WorkProgressTimelineTable> {
  static const double _minTableWidth = 1040;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TimelineToolbar(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < _minTableWidth
                  ? _minTableWidth
                  : constraints.maxWidth;

              return Scrollbar(
                controller: _horizontalController,
                thumbVisibility: tableWidth > constraints.maxWidth,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        const _TableHeader(),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.screenBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBg),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 420,
                            child: Scrollbar(
                              controller: _verticalController,
                              thumbVisibility: true,
                              child: ListView.separated(
                                controller: _verticalController,
                                padding: EdgeInsets.zero,
                                itemCount: widget.rows.length,
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.cardBg,
                                ),
                                itemBuilder: (context, index) {
                                  return _TimelineRow(
                                    index: index,
                                    row: widget.rows[index],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineToolbar extends StatelessWidget {
  const _TimelineToolbar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final title = Text(
          'Work Progress Timeline',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        );

        final dateRange = Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    ImageConstants.calender,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '01 Jan, 2026–30 Jun, 2026',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textMuted,
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
              title,
              const SizedBox(height: 12),
              dateRange,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            dateRange,
          ],
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          _HeaderCell('#', flex: 1),
          _HeaderCell('Stage', flex: 3),
          _HeaderCell('Assigned Team', flex: 3),
          _HeaderCell('Start Date', flex: 2),
          _HeaderCell('Due Date', flex: 2),
          _HeaderCell('Progress', flex: 4),
          _HeaderCell('Status', flex: 2),
          _HeaderCell('Action', flex: 1, align: TextAlign.center),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.title, {
    required this.flex,
    this.align = TextAlign.left,
  });

  final String title;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.index,
    required this.row,
  });

  final int index;
  final WorkProgressTimelineRow row;

  Color get _progressColor {
    if (row.progress >= 80) return AppColors.green;
    if (row.progress >= 50) return const Color(0xFFF2C94C);
    if (row.progress > 0) return const Color(0xFFE57373);
    return const Color(0xFFD9D9D9);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.stage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.assignedTeam,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.startDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.dueDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: row.progress / 100,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFEDEDED),
                      color: _progressColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${row.progress}%',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: row.status),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WorkProgressStageStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bgColor) = switch (status) {
      WorkProgressStageStatus.completed => (
          'Completed',
          const Color(0xFF1BA752),
          const Color(0xFFE8F8EF),
        ),
      WorkProgressStageStatus.inProgress => (
          'In Progress',
          const Color(0xFF5B8DEF),
          const Color(0xFFEAF1FC),
        ),
      WorkProgressStageStatus.pending => (
          'Pending',
          const Color(0xFFE06B7A),
          const Color(0xFFFDECEE),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
