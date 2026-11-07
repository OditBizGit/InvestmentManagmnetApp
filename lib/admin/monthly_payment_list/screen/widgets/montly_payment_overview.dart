import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class MonthlyPaymentOverview extends StatelessWidget {
  const MonthlyPaymentOverview({
    super.key,
    required this.totalPayments,
    required this.totalAmount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  final int totalPayments;
  final double totalAmount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;

            const titleBlock = UserManagementSectionHeader(
              title: 'Monthly Payment List',
              subtitle: 'View and manage monthly investor payments',
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
                    '$pendingCount awaiting approval',
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleBlock,
                  if (pendingCount > 0) ...[
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: queueBadge),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: titleBlock),
                if (pendingCount > 0) queueBadge,
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        UserManagementStatCards(
          stats: [
            UserManagementStatCardData(
              label: 'Total Payments',
              value: '$totalPayments',
              icon: ImageConstants.totalInvestors,
              iconColor: const Color(0xFF9B7EBF),
              iconBg: const Color(0xFFF0EBF6),
            ),
            UserManagementStatCardData(
              label: 'Total Amount Paid',
              value: CurrencyFormatter.format(totalAmount),
              icon: ImageConstants.totalCollection,
              iconColor: const Color(0xFF2CB5A8),
              iconBg: const Color(0xFFE6F7F5),
            ),
            UserManagementStatCardData(
              label: 'Pending Approval',
              value: '$pendingCount',
              icon: ImageConstants.amountRemaining,
              iconColor: const Color(0xFFE89A3C),
              iconBg: const Color(0xFFFFF3E8),
            ),
            UserManagementStatCardData(
              label: 'Approved',
              value: '$approvedCount',
              icon: ImageConstants.tick,
              iconColor: const Color(0xFF1BA752),
              iconBg: const Color(0xFFE8F8EE),
            ),
            UserManagementStatCardData(
              label: 'Rejected',
              value: '$rejectedCount',
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
