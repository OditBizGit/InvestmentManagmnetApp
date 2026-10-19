import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class ReviewRequestHeader extends StatelessWidget {
  const ReviewRequestHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.statusLabel,
    this.statusTone = UserManagementBadgeTone.neutral,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final String? statusLabel;
  final UserManagementBadgeTone statusTone;

  factory ReviewRequestHeader.forRequest({
    required PendingRequestModel request,
    required VoidCallback onBack,
  }) {
    return ReviewRequestHeader(
      title: 'Request details',
      subtitle: '${request.requestId}  ·  ${request.allocation}',
      onBack: onBack,
      statusLabel: request.statusLabel,
      statusTone: switch (request.status) {
        PendingRequestStatus.completed => UserManagementBadgeTone.success,
        PendingRequestStatus.rejected => UserManagementBadgeTone.danger,
        PendingRequestStatus.pending => UserManagementBadgeTone.warning,
        PendingRequestStatus.requested => UserManagementBadgeTone.neutral,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        final titleRow = Row(
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (statusLabel != null) ...[
              const SizedBox(width: 10),
              UserManagementStatusBadge(
                label: statusLabel!,
                tone: statusTone,
              ),
            ],
          ],
        );

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pending Requests',
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
                Flexible(
                  child: Text(
                    'Request details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            titleRow,
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Material(
          color: AppColors.newBorder,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    'Back to Requests',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
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
            const SizedBox(width: 16),
            backButton,
          ],
        );
      },
    );
  }
}
