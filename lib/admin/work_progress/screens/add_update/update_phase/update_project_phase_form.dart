import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/add_or_update_phase_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/add_phase_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import 'cubit/update_phase_cubit.dart';

class UpdateProjectPhaseForm extends StatelessWidget {
  const UpdateProjectPhaseForm({
    super.key,
    this.initial,
    this.onSaveSuccess,
  });

  final ProjectPhaseUpdate? initial;
  final VoidCallback? onSaveSuccess;

  @override
  Widget build(BuildContext context) {
    return _UpdateProjectPhaseFormView(
      initial: initial,
      onSaveSuccess: onSaveSuccess,
    );
  }
}

class _UpdateProjectPhaseFormView extends StatefulWidget {
  const _UpdateProjectPhaseFormView({
    this.initial,
    this.onSaveSuccess,
  });

  final ProjectPhaseUpdate? initial;
  final VoidCallback? onSaveSuccess;

  @override
  State<_UpdateProjectPhaseFormView> createState() =>
      _UpdateProjectPhaseFormViewState();
}

class _UpdateProjectPhaseFormViewState
    extends State<_UpdateProjectPhaseFormView> {
  static const List<String> _statuses = [
    'Completed',
    'In Progress',
    'Pending',
  ];

  final _assignedTeamController = TextEditingController();
  final _progressController = TextEditingController();
  final _newStageController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _stage;
  int? _stageId;
  String? _status;
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _showAddStage = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _stage = initial.stage;
      _stageId = initial.stageId;
      _assignedTeamController.text = initial.assignedTeam;
      _progressController.text = '${initial.progress}';
      _status = initial.status;
      _startDate = initial.startDate;
      _dueDate = initial.dueDate;
      _descriptionController.text = initial.description;
    }
  }

  @override
  void dispose() {
    _assignedTeamController.dispose();
    _progressController.dispose();
    _newStageController.dispose();
    _descriptionController.dispose();
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

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_dueDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _dueDate = picked;
      }
    });
  }

  Future<void> _addStage() async {
    final name = _newStageController.text.trim();
    final cubit = context.read<UpdatePhaseCubit>();

    if (name.isEmpty) {
      AppToast.error('Please enter a stage name.', context: context);
      return;
    }

    final exists = cubit.stages.any(
      (stage) => stage.stageName.toLowerCase() == name.toLowerCase(),
    );

    if (exists) {
      AppToast.error('This stage already exists.', context: context);
      return;
    }

    await cubit.addPhase(stageName: name);
  }

  Future<void> _handleUpload() async {
    final stage = _stage?.trim();
    final team = _assignedTeamController.text.trim();
    final progressRaw = _progressController.text.trim().replaceAll('%', '');
    final progress = int.tryParse(progressRaw);
    final status = _status?.trim();
    final cubit = context.read<UpdatePhaseCubit>();

    if (stage == null || stage.isEmpty) {
      AppToast.error('Please select a stage', context: context);
      return;
    }
    if (_startDate == null) {
      AppToast.error('Please select start date', context: context);
      return;
    }
    if (status == null || status.isEmpty) {
      AppToast.error('Please select status', context: context);
      return;
    }
    if (progressRaw.isNotEmpty && progress == null) {
      AppToast.error('Enter a valid progress percentage', context: context);
      return;
    }
    if (progress != null && progress > 100) {
      AppToast.error('Progress cannot exceed 100%', context: context);
      return;
    }
    if (progress != null && progress < 0) {
      AppToast.error('Progress cannot be negative', context: context);
      return;
    }

    var stageId = _stageId ?? widget.initial?.stageId;
    if (stageId == null) {
      final match = cubit.stages.cast<AddPhaseModel?>().firstWhere(
        (item) => item?.stageName == stage,
        orElse: () => null,
      );
      stageId = match?.stageId;
    }

    if (stageId == null || stageId == 0) {
      AppToast.error('Please select a valid stage', context: context);
      return;
    }

    final isUpdate = widget.initial != null;
    await cubit.addOrUpdateWorkPhase(
      request: AddOrUpdatePhaseRequestModel(
        stageId: stageId,
        startDate: _startDate!,
        dueDate: _dueDate,
        constructionTeam: team,
        progress: (progress ?? 0).clamp(0, 100),
        status: status,
        description: _descriptionController.text.trim(),
      ),
      isUpdate: isUpdate,
    );
  }

  void _resetForm() {
    setState(() {
      _stage = null;
      _stageId = null;
      _status = null;
      _startDate = null;
      _dueDate = null;
      _assignedTeamController.clear();
      _progressController.clear();
      _descriptionController.clear();
      _showAddStage = false;
      _newStageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatePhaseCubit, UpdatePhaseState>(
      listener: (context, state) {
        if (state is StageListFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is UpdatePhaseSuccess) {
          setState(() {
            _stage = state.phase.stageName;
            _stageId = state.phase.stageId;
            _newStageController.clear();
            _showAddStage = false;
          });
          AppToast.success(state.message, context: context);
          context.read<UpdatePhaseCubit>().restoreStageListState();
        } else if (state is UpdatePhaseError) {
          AppToast.error(state.message, context: context);
          context.read<UpdatePhaseCubit>().restoreStageListState();
        } else if (state is SaveWorkPhaseSuccess) {
          AppToast.success(state.message, context: context);
          if (widget.initial == null) {
            _resetForm();
          }
          widget.onSaveSuccess?.call();
        } else if (state is SaveWorkPhaseFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<UpdatePhaseCubit>();
        final stages = state is StageListSuccess ? state.stages : cubit.stages;
        final stageNames = stages
            .map((stage) => stage.stageName)
            .where((name) => name.trim().isNotEmpty)
            .toList(growable: true);
        if (_stage != null &&
            _stage!.trim().isNotEmpty &&
            !stageNames.contains(_stage)) {
          stageNames.insert(0, _stage!);
        }
        final isLoadingStages = state is StageListLoading;
        final isAddingStage = state is UpdatePhaseLoading;
        final isSaving = state is SaveWorkPhaseLoading;

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
                widget.initial == null
                    ? 'Update Project Phase'
                    : 'Edit Project Phase',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.initial == null
                    ? 'Enter stage details, progress, and status for the construction timeline'
                    : 'Update the selected project phase details and save your changes',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoCol = constraints.maxWidth >= 560;

                  final stageField = _LabeledField(
                    label: 'Stage',
                    trailing: TextButton(
                      onPressed: isAddingStage || isLoadingStages
                          ? null
                          : () {
                              setState(() {
                                _showAddStage = !_showAddStage;
                                if (!_showAddStage) {
                                  _newStageController.clear();
                                }
                              });
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.accent,
                      ),
                      child: Text(
                        _showAddStage ? 'Cancel' : '+ Add Stage',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OverlayDropdown(
                          value: _stage,
                          hint: 'Select stage',
                          items: stageNames,
                          isLoading: isLoadingStages,
                          enableSearch: true,
                          searchHint: 'Search stage...',
                          onOpen: () {
                            context
                                .read<UpdatePhaseCubit>()
                                .fetchStageListIfNeeded();
                          },
                          onChanged: (value) {
                            final match = cubit.stages.cast<AddPhaseModel?>().firstWhere(
                              (item) => item?.stageName == value,
                              orElse: () => null,
                            );
                            setState(() {
                              _stage = value;
                              _stageId = match?.stageId ??
                                  (value == widget.initial?.stage
                                      ? widget.initial?.stageId
                                      : null);
                            });
                          },
                        ),
                        if (_showAddStage) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _TextField(
                                  controller: _newStageController,
                                  hint: 'Enter new stage name',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Material(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: isAddingStage ? null : _addStage,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    child: isAddingStage
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : Text(
                                            'Add',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                  final teamField = _LabeledField(
                    label: 'Assigned Team',
                    child: _TextField(
                      controller: _assignedTeamController,
                      hint: 'Enter assigned team',
                    ),
                  );
                  final startDateField = _LabeledField(
                    label: 'Start Date',
                    child: _DateField(
                      value: _startDate == null
                          ? null
                          : _formatDate(_startDate!),
                      hint: 'Select start date',
                      onTap: () => _pickDate(isStart: true),
                    ),
                  );
                  final dueDateField = _LabeledField(
                    label: 'Due Date',
                    child: _DateField(
                      value: _dueDate == null ? null : _formatDate(_dueDate!),
                      hint: 'Select due date',
                      onTap: () => _pickDate(isStart: false),
                    ),
                  );
                  final progressField = _LabeledField(
                    label: 'Progress %',
                    child: _TextField(
                      controller: _progressController,
                      hint: 'e.g. 85',
                      keyboardType: TextInputType.number,
                      suffixText: '%',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 100) {
                          _progressController.text = '100';
                          _progressController.selection =
                              const TextSelection.collapsed(offset: 3);
                        }
                      },
                    ),
                  );
                  final statusField = _LabeledField(
                    label: 'Status',
                    child: _OverlayDropdown(
                      value: _status,
                      hint: 'Select status',
                      items: _statuses,
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  );
                  final descriptionField = _LabeledField(
                    label: 'Description',
                    child: _TextField(
                      controller: _descriptionController,
                      hint: 'Enter phase description',
                      maxLines: 3,
                    ),
                  );

                  if (!twoCol) {
                    return Column(
                      children: [
                        stageField,
                        const SizedBox(height: 14),
                        teamField,
                        const SizedBox(height: 14),
                        startDateField,
                        const SizedBox(height: 14),
                        dueDateField,
                        const SizedBox(height: 14),
                        progressField,
                        const SizedBox(height: 14),
                        statusField,
                        const SizedBox(height: 14),
                        descriptionField,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: stageField),
                          const SizedBox(width: 14),
                          Expanded(child: teamField),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: startDateField),
                          const SizedBox(width: 14),
                          Expanded(child: dueDateField),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: progressField),
                          const SizedBox(width: 14),
                          Expanded(child: statusField),
                        ],
                      ),
                      const SizedBox(height: 14),
                      descriptionField,
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: _UploadButton(
                  label: widget.initial == null ? 'Upload' : 'Update',
                  isLoading: isSaving,
                  onTap: isSaving ? null : _handleUpload,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.trailing,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.suffixText,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? suffixText;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: _inputDecoration(hint).copyWith(suffixText: suffixText),
    );
  }
}

class _OverlayDropdown extends StatefulWidget {
  const _OverlayDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.onOpen,
    this.isLoading = false,
    this.enableSearch = false,
    this.searchHint = 'Search...',
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onOpen;
  final bool isLoading;
  final bool enableSearch;
  final String searchHint;

  @override
  State<_OverlayDropdown> createState() => _OverlayDropdownState();
}

class _OverlayDropdownState extends State<_OverlayDropdown> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isOpening = false;
  String _searchQuery = '';

  bool get _isOpen => _overlayEntry != null;

  List<String> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  void _toggleDropdown() {
    if (_isOpen || _isOpening) {
      _closeDropdown();
      return;
    }
    _openDropdown();
  }

  Widget _buildMenuContent() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final items = _filteredItems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enableSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                _searchQuery = value;
                _overlayEntry?.markNeedsBuild();
              },
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.searchHint,
                hintStyle: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.hint,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _overlayEntry?.markNeedsBuild();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.screenBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.newBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.enableSearch && _searchQuery.trim().isNotEmpty
                    ? 'No matching stages'
                    : 'No stages available',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.enableSearch ? 200 : 200,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.newBorder),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == widget.value;

                return InkWell(
                  onTap: () {
                    widget.onChanged(item);
                    _closeDropdown();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _openDropdown() {
    if (_overlayEntry != null || _isOpening) return;
    _isOpening = true;
    _searchQuery = '';
    _searchController.clear();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      _isOpening = false;
      return;
    }
    final size = renderBox.size;
    final maxHeight = widget.enableSearch ? 280.0 : 220.0;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 6),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.newBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildMenuContent(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpening = false;
    if (mounted) setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen) return;
      widget.onOpen?.call();
    });
  }

  void _closeDropdown({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpening = false;
    _searchQuery = '';
    _searchController.clear();
    if (notify && mounted) {
      setState(() {});
    }
  }

  void _refreshOverlay() {
    if (!_isOpen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry == null) return;
      _overlayEntry!.markNeedsBuild();
    });
  }

  @override
  void didUpdateWidget(covariant _OverlayDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isOpen) return;

    final itemsChanged = !listEquals(oldWidget.items, widget.items);
    final loadingChanged = oldWidget.isLoading != widget.isLoading;
    final valueChanged = oldWidget.value != widget.value;
    if (itemsChanged || loadingChanged || valueChanged) {
      _refreshOverlay();
    }
  }

  @override
  void dispose() {
    _closeDropdown(notify: false);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isOpen ? AppColors.accent : AppColors.newBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value ?? widget.hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: widget.value == null
                        ? AppColors.hint
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.isLoading && _isOpen)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration(hint).copyWith(
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              ImageConstants.calender,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.textMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        child: Text(
          value ?? hint,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: value == null ? AppColors.hint : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.onTap,
    required this.label,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              else
                Icon(
                  label == 'Update'
                      ? Icons.save_outlined
                      : Icons.cloud_upload_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
              const SizedBox(width: 8),
              Text(
                isLoading ? 'Saving...' : label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.hint,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: AppColors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
    ),
  );
}
