import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../model/investor_statement_model.dart';
import 'investor_statement_status_views.dart';

/// Investor identity plus opening and closing balance.
///
/// "Closing balance" (ledger) and "Pending" (schedule rules, shown in the
/// stat cards) are different figures and are labelled separately.
class InvestorStatementHeaderCard extends StatelessWidget {
  const InvestorStatementHeaderCard({super.key, required this.header});

  final InvestorStatementHeader header;

  String get _period {
    final from = header.fromDate;
    final to = header.toDate;
    if (from != null && to != null) {
      return '${formatStatementDate(from)} – ${formatStatementDate(to)}';
    }
    if (from != null) return 'From ${formatStatementDate(from)}';
    if (to != null) return 'Up to ${formatStatementDate(to)}';
    return 'All dates';
  }

  @override
  Widget build(BuildContext context) {
    final code = header.investorCode;

    return UserManagementTableCard(
      child: Wrap(
        spacing: 32,
        runSpacing: 14,
        children: [
          _InfoItem(
            label: 'Investor',
            value: code.isEmpty ? header.name : '$code - ${header.name}',
          ),
          _InfoItem(
            label: 'Status',
            child: UserManagementStatusBadge(
              label: header.isActive ? 'Active' : 'Inactive',
              tone: header.isActive
                  ? UserManagementBadgeTone.success
                  : UserManagementBadgeTone.danger,
            ),
          ),
          _InfoItem(label: 'Period', value: _period),
          _InfoItem(
            label: 'Opening balance',
            value: CurrencyFormatter.format(header.openingBalance),
          ),
          _InfoItem(
            label: 'Closing balance',
            value: CurrencyFormatter.format(header.closingBalance),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        child ??
            Text(
              value ?? '—',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
      ],
    );
  }
}
