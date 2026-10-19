import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/admin_settings/data/dummy_admin_staff.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/admin_settings/model/admin_staff_permission_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/admin_settings/staff_permissions_screen.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/widgets/staff_allocation_header.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class StaffAccessSettingsScreen extends StatefulWidget {
  const StaffAccessSettingsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<StaffAccessSettingsScreen> createState() =>
      _StaffAccessSettingsScreenState();
}

class _StaffAccessSettingsScreenState extends State<StaffAccessSettingsScreen> {
  late List<AdminStaffPermissionModel> _staff;
  AdminStaffPermissionModel? _selectedStaff;

  @override
  void initState() {
    super.initState();
    _staff = dummyAdminStaff
        .map(
          (member) => member.copyWith(
            allowedScreenIds: Set<String>.from(member.allowedScreenIds),
          ),
        )
        .toList();
  }

  void _handleBackToSettings() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _openPermissions(AdminStaffPermissionModel staff) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedStaff = staff);
  }

  void _backToStaffList() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedStaff = null);
  }

  void _savePermissions(AdminStaffPermissionModel updated) {
    setState(() {
      _staff = [
        for (final member in _staff)
          if (member.id == updated.id) updated else member,
      ];
      _selectedStaff = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedStaff;
    if (selected != null) {
      return StaffPermissionsScreen(
        staff: selected,
        onBack: _backToStaffList,
        onSave: _savePermissions,
      );
    }

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
                  breadcrumbLeaf: 'Admin Settings',
                  title: 'Admin Settings',
                  subtitle: 'Tap a staff member to manage screen access',
                  backLabel: 'Back to Settings',
                  onBack: _handleBackToSettings,
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
                  child: _StaffAccessList(
                    staffMembers: _staff,
                    onStaffTap: _openPermissions,
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

class _StaffAccessList extends StatelessWidget {
  const _StaffAccessList({
    required this.staffMembers,
    required this.onStaffTap,
  });

  final List<AdminStaffPermissionModel> staffMembers;
  final ValueChanged<AdminStaffPermissionModel> onStaffTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff Members',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a staff member to view and edit screen access.',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < staffMembers.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _StaffAccessTile(
              staff: staffMembers[i],
              onTap: () => onStaffTap(staffMembers[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaffAccessTile extends StatefulWidget {
  const _StaffAccessTile({
    required this.staff,
    required this.onTap,
  });

  final AdminStaffPermissionModel staff;
  final VoidCallback onTap;

  @override
  State<_StaffAccessTile> createState() => _StaffAccessTileState();
}

class _StaffAccessTileState extends State<_StaffAccessTile> {
  bool _hovered = false;

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
    final staff = widget.staff;
    final totalScreens = adminPermissionScreens.length;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered
            ? AppColors.accent.withValues(alpha: 0.04)
            : AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(staff.fullName),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        staff.designation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${staff.allowedCount}/$totalScreens screens',
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: _hovered ? AppColors.accent : AppColors.hint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
