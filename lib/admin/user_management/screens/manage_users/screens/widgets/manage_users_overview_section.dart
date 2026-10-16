import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';

class ManageUsersOverviewSection extends StatelessWidget {
  const ManageUsersOverviewSection({
    super.key,
    required this.totalUsers,
    required this.activeUsers,
    required this.blockedUsers,
    // required this.usersWithPendingDues,
  });

  final int totalUsers;
  final int activeUsers;
  final int blockedUsers;
  // final int usersWithPendingDues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const UserManagementSectionHeader(
          title: 'Manage Users',
          subtitle: 'Review accounts, payment status, and access for all users',
        ),
        const SizedBox(height: 20),
        UserManagementStatCards(
          stats: [
            UserManagementStatCardData(
              label: 'Total Users',
              value: '$totalUsers',
              icon: ImageConstants.totalInvestors,
              iconColor: const Color(0xFF9B7EBF),
              iconBg: const Color(0xFFF0EBF6),
            ),
            UserManagementStatCardData(
              label: 'Active Users',
              value: '$activeUsers',
              icon: ImageConstants.activeInvestors,
              iconColor: const Color(0xFF2CB5A8),
              iconBg: const Color(0xFFE6F7F5),
            ),
            UserManagementStatCardData(
              label: 'Blocked Users',
              value: '$blockedUsers',
              icon: ImageConstants.complaints,
              iconColor: const Color(0xFFE06B7A),
              iconBg: const Color(0xFFFDECEE),
            ),
            // UserManagementStatCardData(
            //   label: 'Users with Pending Dues',
            //   value: '$usersWithPendingDues',
            //   icon: ImageConstants.amountRemaining,
            //   iconColor: const Color(0xFFE89A3C),
            //   iconBg: const Color(0xFFFFF3E8),
            // ),
          ],
        ),
      ],
    );
  }
}
