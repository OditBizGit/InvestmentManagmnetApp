import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class UserStatusCheckboxCard extends StatelessWidget {
  const UserStatusCheckboxCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final DocumentProcessStatus selected;
  final ValueChanged<DocumentProcessStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          for (final status in DocumentProcessStatus.values) ...[
            _StatusCheckboxTile(
              label: status.label,
              checked: selected == status,
              onTap: () => onChanged(status),
            ),
            if (status != DocumentProcessStatus.values.last)
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _StatusCheckboxTile extends StatelessWidget {
  const _StatusCheckboxTile({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? AppColors.cardBg : AppColors.screenBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: checked,
                  onChanged: (_) => onTap(),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.accent;
                    }
                    return AppColors.white;
                  }),
                  checkColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(color: AppColors.border, width: 1.4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
