import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

import '../cubit/work_progress_cubit.dart';

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

  factory WorkProgressTimelineRow.fromPhase(WorkPhaseListModel phase) {
    return WorkProgressTimelineRow(
      stage: phase.stageName.isEmpty ? 'Untitled stage' : phase.stageName,
      assignedTeam: phase.constructionTeam.isEmpty
          ? '-'
          : phase.constructionTeam,
      startDate: _formatDate(phase.startDate),
      dueDate: phase.dueDate == null ? '-' : _formatDate(phase.dueDate!),
      progress: phase.progress.clamp(0, 100),
      status: _mapStatus(phase.status),
    );
  }

  static WorkProgressStageStatus _mapStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.contains('complete')) {
      return WorkProgressStageStatus.completed;
    }
    if (normalized.contains('progress')) {
      return WorkProgressStageStatus.inProgress;
    }
    return WorkProgressStageStatus.pending;
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }
}

class WorkProgressTimelineTable extends StatefulWidget {
  const WorkProgressTimelineTable({super.key});

  @override
  State<WorkProgressTimelineTable> createState() =>
      _WorkProgressTimelineTableState();
}

class _WorkProgressTimelineTableState extends State<WorkProgressTimelineTable> {
  static const double _minTableWidth = 1040;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<WorkProgressTimelineRow> _filterRows(
    List<WorkProgressTimelineRow> rows,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return rows;

    return rows.where((row) {
      final haystack = [
        row.stage,
        row.assignedTeam,
        row.startDate,
        row.dueDate,
        '${row.progress}',
        row.status.name,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkProgressCubit, WorkProgressState>(
      builder: (context, state) {
        final cubit = context.read<WorkProgressCubit>();
        final phases = state is WorkProgressSuccess
            ? state.phases
            : cubit.phases;
        final allRows = phases
            .map(WorkProgressTimelineRow.fromPhase)
            .toList(growable: false);
        final rows = _filterRows(allRows);
        final isLoading =
            state is WorkProgressLoading ||
            (state is WorkProgressInitial && phases.isEmpty);
        final errorMessage =
            state is WorkProgressFailure ? state.message : null;
        final hasError = errorMessage != null && phases.isEmpty;

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
              _TimelineToolbar(
                searchController: _searchController,
                searchQuery: _searchQuery,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                onClearSearch: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
              const SizedBox(height: 14),
              if (isLoading)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
              else if (hasError)
                _TableMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Failed to load timeline',
                  message: errorMessage,
                  actionLabel: 'Retry',
                  onAction: () =>
                      context.read<WorkProgressCubit>().fetchWorkPhaseList(),
                )
              else if (allRows.isEmpty)
                const _TableMessage(
                  icon: Icons.inbox_outlined,
                  title: 'No work phases yet',
                  message:
                      'Add a project phase update to see it in the timeline',
                )
              else if (rows.isEmpty)
                const _TableMessage(
                  icon: Icons.search_off_rounded,
                  title: 'No matching phases',
                  message: 'Try a different search term',
                )
              else
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
                                      itemCount: rows.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.cardBg,
                                      ),
                                      itemBuilder: (context, index) {
                                        return _TimelineRow(
                                          index: index,
                                          row: rows[index],
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
      },
    );
  }
}

class _TableMessage extends StatelessWidget {
  const _TableMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineToolbar extends StatelessWidget {
  const _TimelineToolbar({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

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

        final searchField = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isCompact ? double.infinity : 280,
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search stage, team, status...',
              hintStyle: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.hint,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  ImageConstants.search,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.hint,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.accent),
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
              searchField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            searchField,
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
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.title, {
    required this.flex,
  });

  final String title;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
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
