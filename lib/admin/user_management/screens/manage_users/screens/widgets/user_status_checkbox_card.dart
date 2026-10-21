import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class UserStatusCheckboxCard extends StatelessWidget {
  const UserStatusCheckboxCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.documentLabel,
    required this.selected,
    required this.onChanged,
    this.issuedAt,
    this.completedAt,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final String documentLabel;
  final DocumentProcessStatus selected;
  final ValueChanged<DocumentProcessStatus> onChanged;
  final DateTime? issuedAt;
  final DateTime? completedAt;
  final bool isLoading;

  bool _canSelect(DocumentProcessStatus status) {
    if (selected == DocumentProcessStatus.completed) {
      return status == DocumentProcessStatus.completed;
    }
    if (status == DocumentProcessStatus.pending &&
        selected == DocumentProcessStatus.issued) {
      return false;
    }
    return true;
  }

  String? _timestampLabel(DocumentProcessStatus status) {
    switch (status) {
      case DocumentProcessStatus.issued:
        final formatted = _formatUpdatedAt(issuedAt);
        return formatted == null ? null : 'Issued on: $formatted';
      case DocumentProcessStatus.completed:
        final formatted = _formatUpdatedAt(completedAt);
        return formatted == null ? null : 'Completed on: $formatted';
      case DocumentProcessStatus.pending:
        return null;
    }
  }

  Future<void> _handleTap(
    BuildContext context,
    DocumentProcessStatus status,
  ) async {
    if (isLoading || selected == status) return;

    if (!_canSelect(status)) {
      final message = selected == DocumentProcessStatus.completed
          ? 'Once marked as Completed, status cannot be changed.'
          : 'Once marked as Issued, status cannot be set back to Pending.';
      AppToast.error(
        message,
        title: '$documentLabel Status Locked',
        context: context,
      );
      return;
    }

    if (status == DocumentProcessStatus.completed) {
      final confirmed = await showUserManagementConfirmDialog(
        context: context,
        title: 'Mark $documentLabel as Completed?',
        message:
            'Are you sure you want to mark this $documentLabel status as Completed? This action confirms the process is finished.',
        confirmLabel: 'Confirm',
        confirmColor: AppColors.accent,
      );
      if (!confirmed) return;
    }

    onChanged(status);
  }

  @override
  Widget build(BuildContext context) {
    return AddInvestorSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          if (isLoading) ...[
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.accent,
              backgroundColor: AppColors.border,
            ),
            const SizedBox(height: 10),
          ],
          for (final status in DocumentProcessStatus.values) ...[
            _StatusCheckboxTile(
              label: status.label,
              checked: selected == status,
              updatedAt: _timestampLabel(status),
              enabled: !isLoading,
              locked: !_canSelect(status),
              onTap: () => _handleTap(context, status),
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
    required this.enabled,
    this.locked = false,
    this.updatedAt,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final bool enabled;
  final bool locked;
  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled;
    final labelColor =
        locked && !checked ? AppColors.hint : AppColors.textPrimary;

    return Material(
      color: checked ? AppColors.cardBg : AppColors.screenBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: interactive ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: locked && !checked ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: checked,
                    onChanged: interactive ? (_) => onTap() : null,
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
                      color: labelColor,
                    ),
                  ),
                ),
                if (updatedAt != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      updatedAt!,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _formatUpdatedAt(DateTime? value) {
  if (value == null) return null;

  final local = value.toLocal();
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

  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';

  return '${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour:$minute $period';
}
