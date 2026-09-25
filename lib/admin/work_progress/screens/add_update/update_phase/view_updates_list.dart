import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/cubit/update_phase_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class ViewUpdatesList extends StatefulWidget {
  const ViewUpdatesList({
    super.key,
    required this.onPhaseTap,
    this.title = 'View Updates',
    this.subtitle =
        'Review previously added updates. Tap an item to edit and upload again.',
  });

  final ValueChanged<WorkPhaseListModel> onPhaseTap;
  final String title;
  final String subtitle;

  @override
  State<ViewUpdatesList> createState() => _ViewUpdatesListState();
}

class _ViewUpdatesListState extends State<ViewUpdatesList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UpdatePhaseCubit>().fetchWorkPhaseListIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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

  List<WorkPhaseListModel> _filterPhases(List<WorkPhaseListModel> phases) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return phases;

    return phases.where((phase) {
      final haystack = [
        phase.stageName,
        phase.constructionTeam,
        phase.status,
        phase.description,
        phase.projectName,
        '${phase.progress}',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatePhaseCubit, UpdatePhaseState>(
      listenWhen: (previous, current) => current is WorkPhaseListFailure,
      listener: (context, state) {
        if (state is WorkPhaseListFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is WorkPhaseListLoading ||
          current is WorkPhaseListSuccess ||
          current is WorkPhaseListFailure ||
          current is UpdatePhaseInitial,
      builder: (context, state) {
        final cubit = context.read<UpdatePhaseCubit>();
        final phases = state is WorkPhaseListSuccess
            ? state.phases
            : cubit.workPhases;
        final filteredPhases = _filterPhases(phases);
        final isLoading =
            state is WorkPhaseListLoading && !cubit.hasFetchedWorkPhaseList;
        final errorMessage =
            state is WorkPhaseListFailure ? state.message : null;
        final hasError = errorMessage != null && phases.isEmpty;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by stage, team, status...',
                  hintStyle: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.hint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
              else if (hasError)
                _EmptyOrErrorBox(
                  icon: Icons.error_outline_rounded,
                  title: 'Failed to load phases',
                  message: errorMessage,
                  actionLabel: 'Retry',
                  onAction: () =>
                      context.read<UpdatePhaseCubit>().fetchWorkPhaseList(),
                )
              else if (phases.isEmpty)
                const _EmptyOrErrorBox(
                  icon: Icons.inbox_outlined,
                  title: 'No updates added yet',
                  message:
                      'Add a project phase or media update to see it here',
                )
              else if (filteredPhases.isEmpty)
                const _EmptyOrErrorBox(
                  icon: Icons.search_off_rounded,
                  title: 'No matching phases',
                  message: 'Try a different search term',
                )
              else
                for (var i = 0; i < filteredPhases.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _UpdateListTile(
                    phase: filteredPhases[i],
                    dateLabel: _formatDate(filteredPhases[i].progressDate),
                    onTap: () => widget.onPhaseTap(filteredPhases[i]),
                  ),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyOrErrorBox extends StatelessWidget {
  const _EmptyOrErrorBox({
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            title,
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
            const SizedBox(height: 14),
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
    );
  }
}

class _UpdateListTile extends StatelessWidget {
  const _UpdateListTile({
    required this.phase,
    required this.dateLabel,
    required this.onTap,
  });

  final WorkPhaseListModel phase;
  final String dateLabel;
  final VoidCallback onTap;

  static const _typeColor = Color(0xFF9B7EBF);

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${phase.constructionTeam} • ${phase.progress}% • ${phase.status}';

    return Material(
      color: AppColors.screenBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: _typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.stageName.isEmpty
                          ? 'Untitled phase'
                          : phase.stageName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Project Phase',
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w600,
                              color: _typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Maps API work phase to the form's edit model.
ProjectPhaseUpdate workPhaseToProjectPhaseUpdate(WorkPhaseListModel phase) {
  return ProjectPhaseUpdate(
    id: phase.phaseId.toString(),
    stageId: phase.stageId,
    stage: phase.stageName,
    assignedTeam: phase.constructionTeam,
    startDate: phase.startDate,
    dueDate: phase.dueDate,
    progress: phase.progress,
    status: phase.status,
    description: phase.description,
    updatedAt: phase.progressDate,
  );
}
