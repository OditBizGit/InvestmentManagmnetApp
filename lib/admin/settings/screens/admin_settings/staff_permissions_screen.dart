import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/admin_settings/model/admin_staff_permission_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/widgets/staff_allocation_header.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class StaffPermissionsScreen extends StatefulWidget {
  const StaffPermissionsScreen({
    super.key,
    required this.staff,
    required this.onBack,
    required this.onSave,
  });

  final AdminStaffPermissionModel staff;
  final VoidCallback onBack;
  final ValueChanged<AdminStaffPermissionModel> onSave;

  @override
  State<StaffPermissionsScreen> createState() => _StaffPermissionsScreenState();
}

class _StaffPermissionsScreenState extends State<StaffPermissionsScreen> {
  late Set<String> _allowedScreenIds;

  @override
  void initState() {
    super.initState();
    _allowedScreenIds = Set<String>.from(widget.staff.allowedScreenIds);
  }

  @override
  void didUpdateWidget(covariant StaffPermissionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staff.id != widget.staff.id) {
      _allowedScreenIds = Set<String>.from(widget.staff.allowedScreenIds);
    }
  }

  void _toggleScreen(String screenId, bool enabled) {
    setState(() {
      if (enabled) {
        _allowedScreenIds.add(screenId);
      } else {
        _allowedScreenIds.remove(screenId);
      }
    });
  }

  void _save() {
    widget.onSave(
      widget.staff.copyWith(
        allowedScreenIds: Set<String>.from(_allowedScreenIds),
      ),
    );
    AppToast.success('Screen access updated for ${widget.staff.fullName}');
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final allowedCount = _allowedScreenIds.length;
    final totalScreens = adminPermissionScreens.length;

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
                child: StaffAllocationHeader(
                  breadcrumbLeaf: widget.staff.fullName,
                  title: 'Screen Permissions',
                  subtitle:
                      'Choose which screens ${widget.staff.fullName} can use',
                  backLabel: 'Back to Staff',
                  onBack: widget.onBack,
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
                      _StaffSummaryCard(
                        staff: widget.staff,
                        initials: _initials(widget.staff.fullName),
                        allowedCount: allowedCount,
                        totalScreens: totalScreens,
                      ),
                      const SizedBox(height: 16),
                      _PermissionsCard(
                        allowedScreenIds: _allowedScreenIds,
                        onToggle: _toggleScreen,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 180),
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
  }
}

class _StaffSummaryCard extends StatelessWidget {
  const _StaffSummaryCard({
    required this.staff,
    required this.initials,
    required this.allowedCount,
    required this.totalScreens,
  });

  final AdminStaffPermissionModel staff;
  final String initials;
  final int allowedCount;
  final int totalScreens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final avatar = Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff.fullName,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                staff.designation,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                staff.email,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.hint,
                ),
              ),
            ],
          );
          final badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$allowedCount / $totalScreens allowed',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 14),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 12),
                badge,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 14),
              Expanded(child: details),
              badge,
            ],
          );
        },
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({
    required this.allowedScreenIds,
    required this.onToggle,
  });

  final Set<String> allowedScreenIds;
  final void Function(String screenId, bool enabled) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < adminPermissionScreens.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              ),
            _PermissionTile(
              screen: adminPermissionScreens[i],
              enabled: allowedScreenIds.contains(adminPermissionScreens[i].id),
              onChanged: (value) =>
                  onToggle(adminPermissionScreens[i].id, value),
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.screen,
    required this.enabled,
    required this.onChanged,
  });

  final AdminScreenAccess screen;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: enabled,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      activeThumbColor: AppColors.white,
      activeTrackColor: AppColors.accent,
      inactiveThumbColor: AppColors.white,
      inactiveTrackColor: AppColors.border,
      title: Text(
        screen.title,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        screen.description,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
