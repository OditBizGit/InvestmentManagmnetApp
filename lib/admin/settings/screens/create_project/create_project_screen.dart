import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/repository/settings_repository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/cubit/create_project_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/model/projcet_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/widgets/create_project_form_card.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/widgets/projects_list_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

enum _ProjectScreenMode { add, view }

/// Create / update project page shown from Settings.
/// Keeps the admin side drawer visible (in-shell navigation).
class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({
    super.key,
    this.onBack,
    this.onCreateSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onCreateSuccess;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ProjectRepository>(
      create: (_) => ProjectRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => CreateProjectCubit(
          repository: context.read<ProjectRepository>(),
        )..getProjects(),
        child: _CreateProjectView(
          onBack: onBack,
          onCreateSuccess: onCreateSuccess,
        ),
      ),
    );
  }
}

class _CreateProjectView extends StatefulWidget {
  const _CreateProjectView({
    this.onBack,
    this.onCreateSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onCreateSuccess;

  @override
  State<_CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<_CreateProjectView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalFundController = TextEditingController();

  PickedPhoto? _projectImage;
  ProjectModel? _editingProject;
  _ProjectScreenMode _mode = _ProjectScreenMode.add;

  bool get _isEditing => _editingProject != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _totalFundController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _pickProjectImage() async {
    final photo = await PhotoPickerHelper.pickProfilePhoto();
    if (photo == null || !mounted) return;
    setState(() => _projectImage = photo);
  }

  void _clearProjectImage() {
    setState(() => _projectImage = null);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _totalFundController.clear();
    _projectImage = null;
    _editingProject = null;
  }

  void _loadProjectForEdit(ProjectModel project) {
    _editingProject = project;
    _projectImage = null;
    _nameController.text = project.name;
    _descriptionController.text = project.description;
    final amount = project.totalFund;
    _totalFundController.text = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  void _setMode(_ProjectScreenMode mode) {
    setState(() {
      _mode = mode;
      if (mode == _ProjectScreenMode.view) {
        _resetForm();
        return;
      }

      // Only one live project is allowed — open it for update.
      final projects = context.read<CreateProjectCubit>().projects;
      if (projects.isNotEmpty) {
        _loadProjectForEdit(projects.first);
      }
    });
  }

  void _onProjectTap(ProjectModel project) {
    setState(() {
      _mode = _ProjectScreenMode.add;
      _loadProjectForEdit(project);
    });
  }

  void _handleClearEditing() {
    final projects = context.read<CreateProjectCubit>().projects;
    if (projects.isNotEmpty) {
      setState(() => _loadProjectForEdit(projects.first));
      AppToast.info(
        'A project is already live. You can only update the existing project.',
        title: 'Create Project',
        context: context,
      );
      return;
    }
    setState(_resetForm);
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();

    final projects = context.read<CreateProjectCubit>().projects;

    // Block creating a second project when one is already live.
    if (!_isEditing && projects.isNotEmpty) {
      AppToast.error(
        'A project is already live. You cannot add another project — please update the existing one.',
        title: 'Create Project',
        context: context,
      );
      setState(() {
        _mode = _ProjectScreenMode.add;
        _loadProjectForEdit(projects.first);
      });
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final hasExistingImage = _editingProject?.imageUrl != null &&
        _editingProject!.imageUrl!.trim().isNotEmpty;
    if (_projectImage == null && !_isEditing) {
      AppToast.error('Please upload a project image', context: context);
      return;
    }
    if (_projectImage == null && _isEditing && !hasExistingImage) {
      AppToast.error('Please upload a project image', context: context);
      return;
    }

    final rawFund =
        _totalFundController.text.trim().replaceAll(',', '');
    final totalFund = double.tryParse(rawFund);
    if (totalFund == null || totalFund <= 0) {
      AppToast.error('Enter a valid fund amount', context: context);
      return;
    }

    final request = ProjectRequestModel(
      projectId: _editingProject?.projectId ?? 0,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      totalFund: totalFund,
      image: _projectImage != null
          ? MultipartFile.fromBytes(
              _projectImage!.bytes,
              filename: _projectImage!.name,
            )
          : null,
    );

    final cubit = context.read<CreateProjectCubit>();
    if (_isEditing) {
      cubit.updateProject(request);
    } else {
      cubit.createProject(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateProjectCubit, CreateProjectState>(
      listener: (context, state) {
        if (state is CreateProjectSuccess || state is UpdateProjectSuccess) {
          final message = state is CreateProjectSuccess
              ? state.message
              : (state as UpdateProjectSuccess).message;
          AppToast.success(message, context: context);
          setState(() {
            _resetForm();
            _mode = _ProjectScreenMode.view;
          });
        } else if (state is CreateProjectFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is UpdateProjectFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is ProjectsFailure &&
            context.read<CreateProjectCubit>().projects.isEmpty) {
          AppToast.error(state.message, context: context);
        } else if (state is ProjectsSuccess &&
            state.projects.isNotEmpty &&
            _mode == _ProjectScreenMode.add &&
            !_isEditing) {
          // One live project only — open it for update instead of create.
          setState(() => _loadProjectForEdit(state.projects.first));
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateProjectCubit>();
        final projects = cubit.projects;
        final isLoadingProjects =
            state is ProjectsLoading && projects.isEmpty;
        final projectsError = state is ProjectsFailure && projects.isEmpty
            ? state.message
            : null;
        final isSubmitting =
            state is CreateProjectLoading || state is UpdateProjectLoading;

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 16.0 : 24.0;
              final isNarrow = constraints.maxWidth < 980;

              final formCard = CreateProjectFormCard(
                formKey: _formKey,
                nameController: _nameController,
                descriptionController: _descriptionController,
                totalFundController: _totalFundController,
                projectImage: _projectImage,
                existingImageUrl: _editingProject?.imageUrl,
                isEditing: _isEditing,
                hasExistingProject: projects.isNotEmpty,
                onPickImage: _pickProjectImage,
                onClearImage: _clearProjectImage,
              );

              final sidePanel = _CreateProjectSidePanel(
                onCancel: _isEditing ? _handleClearEditing : _handleBack,
                onCreate: _handleSubmit,
                isLoading: isSubmitting,
                isEditing: _isEditing,
                cancelLabel: _isEditing ? 'Clear' : 'Cancel',
              );

              final viewSection = ProjectsListSection(
                projects: projects,
                isLoading: isLoadingProjects,
                errorMessage: projectsError,
                onRetry: () => cubit.getProjects(),
                onProjectTap: _onProjectTap,
              );

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
                    child: _BreadcrumbHeader(
                      onBack: _handleBack,
                      isEditing: _isEditing,
                    ),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: _ProjectModeToggle(
                              mode: _mode,
                              projectCount: projects.length,
                              onChanged: _setMode,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_mode == _ProjectScreenMode.view)
                            viewSection
                          else if (isNarrow) ...[
                            formCard,
                            const SizedBox(height: 16),
                            SizedBox(
                              height: constraints.maxHeight * 0.42,
                              child: sidePanel,
                            ),
                          ] else
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 7, child: formCard),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 4, child: sidePanel),
                                ],
                              ),
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
      },
    );
  }
}

class _ProjectModeToggle extends StatelessWidget {
  const _ProjectModeToggle({
    required this.mode,
    required this.onChanged,
    required this.projectCount,
  });

  final _ProjectScreenMode mode;
  final ValueChanged<_ProjectScreenMode> onChanged;
  final int projectCount;

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
            selected: mode == _ProjectScreenMode.add,
            onTap: () => onChanged(_ProjectScreenMode.add),
          ),
          _ToggleChip(
            label: projectCount > 0 ? 'View ($projectCount)' : 'View',
            selected: mode == _ProjectScreenMode.view,
            onTap: () => onChanged(_ProjectScreenMode.view),
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

/// Notes fill remaining height; Cancel / Create sit flush with the
/// bottom of the Project Details card.
class _CreateProjectSidePanel extends StatelessWidget {
  const _CreateProjectSidePanel({
    required this.onCancel,
    required this.onCreate,
    this.isLoading = false,
    this.isEditing = false,
    this.cancelLabel = 'Cancel',
  });

  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final bool isLoading;
  final bool isEditing;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _ProjectNotesCard(isEditing: isEditing)),
        const SizedBox(height: 16),
        _CreateProjectActionButtons(
          onCancel: onCancel,
          onCreate: onCreate,
          isLoading: isLoading,
          isEditing: isEditing,
          cancelLabel: cancelLabel,
        ),
      ],
    );
  }
}

class _CreateProjectActionButtons extends StatelessWidget {
  const _CreateProjectActionButtons({
    required this.onCancel,
    required this.onCreate,
    this.isLoading = false,
    this.isEditing = false,
    this.cancelLabel = 'Cancel',
  });

  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final bool isLoading;
  final bool isEditing;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F0F3),
                foregroundColor: AppColors.textPrimary,
                disabledForegroundColor: AppColors.textMuted,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                cancelLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                disabledBackgroundColor:
                    AppColors.accent.withValues(alpha: 0.6),
                disabledForegroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'Update Project' : 'Create Project',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectNotesCard extends StatelessWidget {
  const _ProjectNotesCard({this.isEditing = false});

  final bool isEditing;

  static const _createNotes = [
    'All mandatory fields are marked with *',
    'Name and description appear on investor-facing screens',
    'Total fund is the overall funding goal for this project',
    'Upload a clear JPEG or PNG image (max 2 MB)',
    'Use a high-quality project image for better visibility on dashboards',
    'Keep the project name short and easy to recognize in reports',
    'Write a clear description so investors understand the scope',
    'Total fund amount should match the approved budget or goal',
    'Switch to View to see existing projects and edit them',
    'Cancel discards unsaved changes and returns to Settings',
    'Double-check spelling before creating the project',
    'Project image is required before you can create the project',
  ];

  static const _editNotes = [
    'You are editing an existing project',
    'All mandatory fields are marked with *',
    'Tap Clear to discard edits and start a new project',
    'Leave the image unchanged if you do not need a new photo',
    'Uploading a new image replaces the current project image',
    'Total fund should reflect the latest approved funding goal',
    'Use View to pick a different project to update',
    'Save with Update Project after reviewing your changes',
  ];

  @override
  Widget build(BuildContext context) {
    final notes = isEditing ? _editNotes : _createNotes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final note in notes) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbHeader extends StatelessWidget {
  const _BreadcrumbHeader({
    required this.onBack,
    this.isEditing = false,
  });

  final VoidCallback onBack;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final title = isEditing ? 'Update Project' : 'Create Project';

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Settings',
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
                  title,
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
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEditing
                  ? 'Review and update the selected project details'
                  : 'Add a new project or open View to edit an existing one',
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
                  'Back to Settings',
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
              const SizedBox(height: 12),
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
