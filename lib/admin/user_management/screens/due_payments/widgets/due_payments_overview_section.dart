import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';

class DuePaymentsOverviewSection extends StatelessWidget {
  const DuePaymentsOverviewSection({
    super.key,
    required this.totalOutstandingDues,
    required this.usersWithPendingDues,
    required this.partiallyPaidUsers,
    required this.fullyPaidUsers,
  });

  final double totalOutstandingDues;
  final int usersWithPendingDues;
  final int partiallyPaidUsers;
  final int fullyPaidUsers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const UserManagementSectionHeader(
          title: 'Due Payments',
          subtitle: 'Track outstanding dues and follow up with payment reminders',
        ),
        const SizedBox(height: 20),
        UserManagementStatCards(
          stats: [
            UserManagementStatCardData(
              label: 'Total Outstanding Dues',
              value: CurrencyFormatter.format(totalOutstandingDues),
              icon: ImageConstants.amountRemaining,
              iconColor: const Color(0xFFE06B7A),
              iconBg: const Color(0xFFFDECEE),
            ),
            UserManagementStatCardData(
              label: 'Users with Pending Dues',
              value: '$usersWithPendingDues',
              icon: ImageConstants.totalInvestors,
              iconColor: const Color(0xFF9B7EBF),
              iconBg: const Color(0xFFF0EBF6),
            ),
            UserManagementStatCardData(
              label: 'Partially Paid Users',
              value: '$partiallyPaidUsers',
              icon: ImageConstants.amountReceivable,
              iconColor: const Color(0xFFE89A3C),
              iconBg: const Color(0xFFFFF3E8),
            ),
            UserManagementStatCardData(
              label: 'Fully Paid Users',
              value: '$fullyPaidUsers',
              icon: ImageConstants.totalCollection,
              iconColor: const Color(0xFF2CB5A8),
              iconBg: const Color(0xFFE6F7F5),
            ),
          ],
        ),
      ],
    );
  }
}
