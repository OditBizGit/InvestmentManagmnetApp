import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/cubit/update_phase_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/update_project_phase_form.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/view_updates_list.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/add _banner/add_banner.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/widgets/add_update_option_cards.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/widgets/update_construction_media_form.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/widgets/update_status_stories_form.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

enum _ProjectPhaseMode { add, view }

class AddUpdateScreen extends StatefulWidget {
  const AddUpdateScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<AddUpdateScreen> createState() => _AddUpdateScreenState();
}

class _AddUpdateScreenState extends State<AddUpdateScreen> {
  AddUpdateOptionType? _selectedOption;
  _ProjectPhaseMode _projectPhaseMode = _ProjectPhaseMode.add;
  ProjectPhaseUpdate? _editingProjectPhase;
  MediaUpdate? _editingMedia;

  final List<MediaUpdate> _mediaUpdates = [];

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onOptionSelected(AddUpdateOptionType option) {
    setState(() {
      _selectedOption = option;
      _editingProjectPhase = null;
      _editingMedia = null;
      if (option == AddUpdateOptionType.projectPhase) {
        _projectPhaseMode = _ProjectPhaseMode.add;
      }
    });
  }

  void _setProjectPhaseMode(_ProjectPhaseMode mode) {
    setState(() {
      _projectPhaseMode = mode;
      if (mode == _ProjectPhaseMode.view) {
        _editingProjectPhase = null;
      }
    });
  }

  void _onProjectPhaseTap(WorkPhaseListModel phase) {
    setState(() {
      _projectPhaseMode = _ProjectPhaseMode.add;
      _editingProjectPhase = workPhaseToProjectPhaseUpdate(phase);
    });
  }

  void _onProjectPhaseSaveSuccess() {
    setState(() {
      _editingProjectPhase = null;
      _projectPhaseMode = _ProjectPhaseMode.view;
    });
  }

  void _saveMedia(MediaUpdate update) {
    final wasEditing = _editingMedia != null;
    setState(() {
      final index = _mediaUpdates.indexWhere((item) => item.id == update.id);
      if (index >= 0) {
        _mediaUpdates[index] = update;
      } else {
        _mediaUpdates.insert(0, update);
      }
      _editingMedia = null;
    });
    AppToast.success(
      wasEditing
          ? 'Media update saved successfully'
          : 'Media update added successfully',
      context: context,
    );
  }

  Widget _buildProjectPhaseSection() {
    return BlocProvider(
      create: (_) => UpdatePhaseCubit(
        addPhaseRepository: AddPhaseRepository(dio: getIt<Dio>()),
      ),
      child: BlocBuilder<UpdatePhaseCubit, UpdatePhaseState>(
        buildWhen: (previous, current) =>
            current is WorkPhaseListSuccess ||
            current is WorkPhaseListLoading ||
            current is WorkPhaseListFailure ||
            current is UpdatePhaseInitial,
        builder: (context, state) {
          final cubit = context.read<UpdatePhaseCubit>();
          final phaseCount = state is WorkPhaseListSuccess
              ? state.phases.length
              : cubit.workPhases.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _ProjectPhaseModeToggle(
                  mode: _projectPhaseMode,
                  onChanged: _setProjectPhaseMode,
                  updateCount: phaseCount,
                ),
              ),
              const SizedBox(height: 14),
              if (_projectPhaseMode == _ProjectPhaseMode.view)
                ViewUpdatesList(
                  onPhaseTap: _onProjectPhaseTap,
                  title: 'Project Phase Updates',
                  subtitle:
                      'Review previously added project phase updates. Tap an item to edit.',
                )
              else
                UpdateProjectPhaseForm(
                  key: ValueKey(_editingProjectPhase?.id ?? 'new-phase'),
                  initial: _editingProjectPhase,
                  onSaveSuccess: _onProjectPhaseSaveSuccess,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget? get _selectedContent {
    switch (_selectedOption) {
      case AddUpdateOptionType.projectPhase:
        return _buildProjectPhaseSection();
      case AddUpdateOptionType.statusStories:
        return UpdateStatusStoriesForm(
          key: ValueKey('status-${_editingMedia?.id ?? 'new'}'),
          initial: _editingMedia?.type == AddUpdateOptionType.statusStories
              ? _editingMedia
              : null,
          onSave: _saveMedia,
        );
      case AddUpdateOptionType.constructionMedia:
        return UpdateConstructionMediaForm(
          key: ValueKey('construction-${_editingMedia?.id ?? 'new'}'),
          initial:
              _editingMedia?.type == AddUpdateOptionType.constructionMedia
                  ? _editingMedia
                  : null,
          onSave: _saveMedia,
        );
      case AddUpdateOptionType.banner:
        return const AddBanner();
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedContent = _selectedContent;

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
                child: _BreadcrumbHeader(onBack: _handleBack),
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
                        'Choose how you want to add an update',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AddUpdateOptionCards(
                        selectedOption: _selectedOption,
                        onOptionSelected: _onOptionSelected,
                      ),
                      if (selectedContent != null) ...[
                        const SizedBox(height: 20),
                        selectedContent,
                      ],
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

class _ProjectPhaseModeToggle extends StatelessWidget {
  const _ProjectPhaseModeToggle({
    required this.mode,
    required this.onChanged,
    required this.updateCount,
  });

  final _ProjectPhaseMode mode;
  final ValueChanged<_ProjectPhaseMode> onChanged;
  final int updateCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Add',
            selected: mode == _ProjectPhaseMode.add,
            onTap: () => onChanged(_ProjectPhaseMode.add),
          ),
          _ToggleChip(
            label: updateCount > 0 ? 'View ($updateCount)' : 'View',
            selected: mode == _ProjectPhaseMode.view,
            onTap: () => onChanged(_ProjectPhaseMode.view),
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

class _BreadcrumbHeader extends StatelessWidget {
  const _BreadcrumbHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Work Progress',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  'Add Update',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Add Update',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select an update type to continue with project phase, social media, construction media, or banners',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.newBorder,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.newBorder, width: 1),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Work Progress',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndTitle,
              const SizedBox(height: 8),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: breadcrumbAndTitle),
            backButton,
          ],
        );
      },
    );
  }
}
