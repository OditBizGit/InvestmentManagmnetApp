import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/models/add_update_models.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class UpdateProjectPhaseForm extends StatefulWidget {
  const UpdateProjectPhaseForm({
    super.key,
    this.initial,
    required this.onSave,
  });

  final ProjectPhaseUpdate? initial;
  final ValueChanged<ProjectPhaseUpdate> onSave;

  @override
  State<UpdateProjectPhaseForm> createState() => _UpdateProjectPhaseFormState();
}

class _UpdateProjectPhaseFormState extends State<UpdateProjectPhaseForm> {
  static const List<String> _defaultStages = [
    'Foundation',
    'Structure',
    'Electrical',
    'Plumbing',
    'Interior',
    'External Work',
    'Final Inception',
  ];

  static const List<String> _statuses = [
    'Completed',
    'In Progress',
    'Pending',
  ];

  final _assignedTeamController = TextEditingController();
  final _progressController = TextEditingController();
  final _newStageController = TextEditingController();

  late List<String> _stages;
  String? _stage;
  String? _status;
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _showAddStage = false;

  @override
  void initState() {
    super.initState();
    _stages = List<String>.from(_defaultStages);
    final initial = widget.initial;
    if (initial != null) {
      _stage = initial.stage;
      if (!_stages.contains(initial.stage)) {
        _stages = [..._stages, initial.stage];
      }
      _assignedTeamController.text = initial.assignedTeam;
      _progressController.text = '${initial.progress}';
      _status = initial.status;
      _startDate = initial.startDate;
      _dueDate = initial.dueDate;
    }
  }

  @override
  void dispose() {
    _assignedTeamController.dispose();
    _progressController.dispose();
    _newStageController.dispose();
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

  void _addStage() {
    final name = _newStageController.text.trim();
    if (name.isEmpty) return;

    final exists = _stages.any(
      (stage) => stage.toLowerCase() == name.toLowerCase(),
    );

    setState(() {
      if (!exists) {
        _stages = [..._stages, name];
      }
      _stage = name;
      _newStageController.clear();
      _showAddStage = false;
    });
  }

  void _handleUpload() {
    final stage = _stage?.trim();
    final team = _assignedTeamController.text.trim();
    final progress =
        int.tryParse(_progressController.text.trim().replaceAll('%', '')) ?? 0;
    final status = _status?.trim();

    if (stage == null ||
        stage.isEmpty ||
        team.isEmpty ||
        status == null ||
        status.isEmpty) {
      return;
    }

    final existing = widget.initial;
    widget.onSave(
      ProjectPhaseUpdate(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        stage: stage,
        assignedTeam: team,
        startDate: _startDate,
        dueDate: _dueDate,
        progress: progress.clamp(0, 100),
        status: status,
        updatedAt: DateTime.now(),
      ),
    );

    if (existing == null) {
      setState(() {
        _stage = null;
        _status = null;
        _startDate = null;
        _dueDate = null;
        _assignedTeamController.clear();
        _progressController.clear();
        _showAddStage = false;
        _newStageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
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
                      items: _stages,
                      onChanged: (value) => setState(() => _stage = value),
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
                              onTap: _addStage,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                child: Text(
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
                  value: _startDate == null ? null : _formatDate(_startDate!),
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
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: _UploadButton(
              label: widget.initial == null ? 'Upload' : 'Update',
              onTap: _handleUpload,
            ),
          ),
        ],
      ),
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
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  State<_OverlayDropdown> createState() => _OverlayDropdownState();
}

class _OverlayDropdownState extends State<_OverlayDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool get _isOpen => _overlayEntry != null;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.newBorder),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
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
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeDropdown({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (notify && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant _OverlayDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items && _isOpen) {
      _closeDropdown();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openDropdown();
      });
    }
  }

  @override
  void dispose() {
    _closeDropdown(notify: false);
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
  });

  final VoidCallback onTap;
  final String label;

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
              Icon(
                label == 'Update'
                    ? Icons.save_outlined
                    : Icons.cloud_upload_outlined,
                color: AppColors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
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
