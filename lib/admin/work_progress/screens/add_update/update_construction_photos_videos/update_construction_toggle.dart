import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/cubit/update_construction_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/repository/update_construction_repository.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/update_construction_media_form.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/view_delete_construction_media.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:sizer/sizer.dart';

enum ConstructionMediaScreenMode { add, view }

class UpdateConstructionMedia extends StatelessWidget {
  const UpdateConstructionMedia({
    super.key,
    this.initial,
    required this.onSave,
  });

  final MediaUpdate? initial;
  final ValueChanged<MediaUpdate> onSave;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateConstructionCubit(
        workUpdateRepository: WorkUpdateRepository(dio: getIt<Dio>()),
      ),
      child: _UpdateConstructionMediaShell(
        initial: initial,
        onSave: onSave,
      ),
    );
  }
}

class _UpdateConstructionMediaShell extends StatefulWidget {
  const _UpdateConstructionMediaShell({
    this.initial,
    required this.onSave,
  });

  final MediaUpdate? initial;
  final ValueChanged<MediaUpdate> onSave;

  @override
  State<_UpdateConstructionMediaShell> createState() =>
      _UpdateConstructionMediaShellState();
}

class _UpdateConstructionMediaShellState
    extends State<_UpdateConstructionMediaShell> {
  ConstructionMediaScreenMode _mode = ConstructionMediaScreenMode.add;

  void _setMode(ConstructionMediaScreenMode mode) {
    setState(() => _mode = mode);
    if (mode == ConstructionMediaScreenMode.view) {
      context.read<UpdateConstructionCubit>().fetchWorkUpdatesIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdd = _mode == ConstructionMediaScreenMode.add;
    final isEditing = widget.initial != null;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdd
                          ? (isEditing
                              ? 'Edit Construction Photos & Videos'
                              : 'Construction Photos & Videos')
                          : 'Uploaded Photos & Videos',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdd
                          ? (isEditing
                              ? 'Update the construction media details and save your changes'
                              : 'Upload construction site photos and videos with a short description')
                          : 'Review construction media already uploaded for this project',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ConstructionMediaModeToggle(
                mode: _mode,
                onChanged: _setMode,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isAdd)
            UpdateConstructionMediaForm(
              initial: widget.initial,
              onSave: (update) {
                widget.onSave(update);
                _setMode(ConstructionMediaScreenMode.view);
              },
            )
          else
            const ViewDeleteConstructionMedia(),
        ],
      ),
    );
  }
}

class _ConstructionMediaModeToggle extends StatelessWidget {
  const _ConstructionMediaModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final ConstructionMediaScreenMode mode;
  final ValueChanged<ConstructionMediaScreenMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Add',
            selected: mode == ConstructionMediaScreenMode.add,
            onTap: () => onChanged(ConstructionMediaScreenMode.add),
          ),
          _ToggleChip(
            label: 'View',
            selected: mode == ConstructionMediaScreenMode.view,
            onTap: () => onChanged(ConstructionMediaScreenMode.view),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
