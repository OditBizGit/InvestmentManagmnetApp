import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

import '../../../model/pending_request_model.dart';

class PendingRequestsOverviewSection extends StatelessWidget {
  const PendingRequestsOverviewSection({
    super.key,
    required this.overview,
    this.onRefresh,
    this.isRefreshing = false,
  });

  final PendingRequestsOverviewStats overview;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          awaitingReview: overview.awaitingReview,
          onRefresh: onRefresh,
          isRefreshing: isRefreshing,
        ),
        const SizedBox(height: 20),
        UserManagementStatCards(
          stats: [
            UserManagementStatCardData(
              label: 'Total',
              value: '${overview.total}',
              icon: ImageConstants.totalInvestors,
              iconColor: const Color(0xFF9B7EBF),
              iconBg: const Color(0xFFF0EBF6),
            ),
            UserManagementStatCardData(
              label: 'Pending',
              value: '${overview.pending}',
              icon: ImageConstants.amountRemaining,
              iconColor: const Color(0xFFE89A3C),
              iconBg: const Color(0xFFFFF3E8),
            ),
            UserManagementStatCardData(
              label: 'Approved',
              value: '${overview.approved}',
              icon: ImageConstants.tick,
              iconColor: const Color(0xFF2CB5A8),
              iconBg: const Color(0xFFE6F7F5),
            ),
            UserManagementStatCardData(
              label: 'Rejected',
              value: '${overview.rejected}',
              icon: ImageConstants.documents,
              iconColor: const Color(0xFFE06B7A),
              iconBg: const Color(0xFFFDECEE),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.awaitingReview,
    this.onRefresh,
    this.isRefreshing = false,
  });

  final int awaitingReview;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        const titleBlock = UserManagementSectionHeader(
          title: 'Pending Requests',
          subtitle: 'Review and approve investor payment requests',
        );

        final queueBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE89A3C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$awaitingReview awaiting review',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );

        final refreshButton = IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.accent,
                  ),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.accent,
                ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: titleBlock),
                  refreshButton,
                ],
              ),
              const SizedBox(height: 12),
              queueBadge,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: titleBlock),
            const SizedBox(width: 16),
            queueBadge,
            const SizedBox(width: 4),
            refreshButton,
          ],
        );
      },
    );
  }
}
