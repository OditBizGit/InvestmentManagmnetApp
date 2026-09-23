import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum SettingsOptionType {
  createProject,
  addAdmin,
  userComplaints,
}

class SettingsOptionCards extends StatelessWidget {
  const SettingsOptionCards({
    super.key,
    required this.onOptionSelected,
  });

  final ValueChanged<SettingsOptionType> onOptionSelected;

  static const List<_OptionData> _options = [
    _OptionData(
      type: SettingsOptionType.createProject,
      title: 'Create Project',
      description: 'Add or update project details',
      icon: ImageConstants.profile,
      iconColor: Color(0xFF9B7EBF),
      iconBg: Color(0xFFF0EBF6),
    ),
    _OptionData(
      type: SettingsOptionType.addAdmin,
      title: 'Add New Admin',
      description: 'Invite a new admin with role-based access',
      icon: ImageConstants.username,
      iconColor: Color(0xFF2CB5A8),
      iconBg: Color(0xFFE6F7F5),
      usePersonAddIcon: true,
    ),
    _OptionData(
      type: SettingsOptionType.userComplaints,
      title: 'User Complaints',
      description: 'Review and respond to user feedback',
      icon: ImageConstants.notification,
      iconColor: Color(0xFF5B8DEF),
      iconBg: Color(0xFFEAF1FC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < _options.length; i++) ...[
            _OptionTile(
              data: _options[i],
              onTap: () => onOptionSelected(_options[i].type),
              isFirst: i == 0,
              isLast: i == _options.length - 1,
            ),
            if (i < _options.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 78),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OptionData {
  const _OptionData({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.usePersonAddIcon = false,
  });

  final SettingsOptionType type;
  final String title;
  final String description;
  final String icon;
  final Color iconColor;
  final Color iconBg;
  final bool usePersonAddIcon;
}

class _OptionTile extends StatefulWidget {
  const _OptionTile({
    required this.data,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final _OptionData data;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final radius = BorderRadius.vertical(
      top: widget.isFirst ? const Radius.circular(16) : Radius.zero,
      bottom: widget.isLast ? const Radius.circular(16) : Radius.zero,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered
            ? AppColors.accent.withValues(alpha: 0.04)
            : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: data.iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: data.usePersonAddIcon
                      ? Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 22,
                          color: data.iconColor,
                        )
                      : SvgPicture.asset(
                          data.icon,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            data.iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.description,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
