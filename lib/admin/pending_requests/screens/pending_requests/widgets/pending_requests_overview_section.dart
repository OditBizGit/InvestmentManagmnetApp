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
  });

  final PendingRequestsOverviewStats overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(awaitingReview: overview.awaitingReview),
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
              label: 'Requested',
              value: '${overview.requested}',
              icon: ImageConstants.documents,
              iconColor: const Color(0xFFE89A3C),
              iconBg: const Color(0xFFFFF3E8),
            ),
            UserManagementStatCardData(
              label: 'Pending',
              value: '${overview.pending}',
              icon: ImageConstants.amountRemaining,
              iconColor: const Color(0xFFE06B7A),
              iconBg: const Color(0xFFFDECEE),
            ),
            UserManagementStatCardData(
              label: 'Completed',
              value: '${overview.completed}',
              icon: ImageConstants.tick,
              iconColor: const Color(0xFF2CB5A8),
              iconBg: const Color(0xFFE6F7F5),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.awaitingReview});

  final int awaitingReview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        const titleBlock = UserManagementSectionHeader(
          title: 'Pending Requests',
          subtitle: 'Review and approve investor registration requests',
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

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              queueBadge,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            queueBadge,
          ],
        );
      },
    );
  }
}
