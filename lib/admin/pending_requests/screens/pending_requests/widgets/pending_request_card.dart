import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../../../model/pending_request_model.dart';


class PendingRequestCard extends StatelessWidget {
  const PendingRequestCard({
    super.key,
    required this.request,
    required this.onReview,
  });

  final PendingRequestModel request;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return _CompactLayout(request: request, onReview: onReview);
          }
          return _WideLayout(request: request, onReview: onReview);
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.request,
    required this.onReview,
  });

  final PendingRequestModel request;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(initials: request.initials),
        const SizedBox(width: 14),
        Expanded(
          flex: 4,
          child: _ApplicantBlock(request: request),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _LabeledValue(
            label: 'Allocation',
            title: request.allocation,
            value: CurrencyFormatter.format(request.amount),
            valueColor: AppColors.textPrimary,
            emphasizeValue: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _LabeledValue(
            label: 'Submitted',
            title: _formatDate(request.submittedAt),
            value: _formatTime(request.submittedAt),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 148,
          child: _StatusAndAction(request: request, onReview: onReview),
        ),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.request,
    required this.onReview,
  });

  final PendingRequestModel request;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Avatar(initials: request.initials, size: 40),
            const SizedBox(width: 12),
            Expanded(child: _ApplicantBlock(request: request)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _LabeledValue(
                label: 'Allocation',
                title: request.allocation,
                value: CurrencyFormatter.format(request.amount),
                valueColor: AppColors.textPrimary,
                emphasizeValue: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledValue(
                label: 'Submitted',
                title: _formatDate(request.submittedAt),
                value: _formatTime(request.submittedAt),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _StatusAndAction(
          request: request,
          onReview: onReview,
          expanded: true,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    this.size = 44,
  });

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _ApplicantBlock extends StatelessWidget {
  const _ApplicantBlock({required this.request});

  final PendingRequestModel request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.applicantName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          request.requestId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        _ContactLine(
          icon: ImageConstants.email,
          text: request.email,
        ),
        const SizedBox(height: 4),
        _ContactLine(
          icon: ImageConstants.phone,
          text: request.phoneNumber,
        ),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.text,
  });

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 13,
          height: 13,
          colorFilter: const ColorFilter.mode(
            AppColors.textMuted,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.label,
    required this.title,
    required this.value,
    this.valueColor = AppColors.textMuted,
    this.emphasizeValue = false,
  });

  final String label;
  final String title;
  final String value;
  final Color valueColor;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: emphasizeValue ? 12.sp : 10.sp,
            fontWeight: emphasizeValue ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StatusAndAction extends StatelessWidget {
  const _StatusAndAction({
    required this.request,
    required this.onReview,
    this.expanded = false,
  });

  final PendingRequestModel request;
  final VoidCallback onReview;
  final bool expanded;

  UserManagementBadgeTone get _tone => switch (request.status) {
        PendingRequestStatus.completed => UserManagementBadgeTone.success,
        PendingRequestStatus.rejected => UserManagementBadgeTone.danger,
        PendingRequestStatus.pending => UserManagementBadgeTone.warning,
        PendingRequestStatus.requested => UserManagementBadgeTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final action = SizedBox(
      height: 36,
      width: expanded ? null : double.infinity,
      child: OutlinedButton(
        onPressed: onReview,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: Text(
          request.isCompleted ? 'View request' : 'Review request',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (expanded) {
      return Row(
        children: [
          UserManagementStatusBadge(
            label: request.statusLabel,
            tone: _tone,
          ),
          const Spacer(),
          action,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        UserManagementStatusBadge(
          label: request.statusLabel,
          tone: _tone,
        ),
        const SizedBox(height: 10),
        action,
      ],
    );
  }
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

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
