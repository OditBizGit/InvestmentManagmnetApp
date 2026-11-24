import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../model/investor_statement_model.dart';
import 'investor_statement_status_views.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

Widget _stripe(int index, Widget row) => ColoredBox(
  color: index.isEven ? AppColors.white : const Color(0xFFFBF9FC),
  child: SizedBox(
    height: 54,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: row,
    ),
  ),
);

Widget _badgeCell(String label, UserManagementBadgeTone tone, int flex) =>
    Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: label.isEmpty
            ? const Text('—')
            : UserManagementStatusBadge(label: label, tone: tone),
      ),
    );

/// Ledger with running balance.
class InvestorStatementLedgerSection extends StatelessWidget {
  const InvestorStatementLedgerSection({super.key, required this.entries});

  final List<InvestorStatementLedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Ledger',
            subtitle: 'Charges and payments with running balance',
          ),
          UserManagementTableFrame(
            minTableWidth: 1500,
            header: const UserManagementHeaderRow(
              children: [
                UserManagementHeaderCell('Date', flex: 3),
                UserManagementHeaderCell('Type', flex: 2),
                UserManagementHeaderCell('Reference', flex: 3),
                UserManagementHeaderCell('Description', flex: 4),
                UserManagementHeaderCell('Method', flex: 2),
                UserManagementHeaderCell('Status', flex: 2),
                UserManagementHeaderCell('Charge', flex: 3),
                UserManagementHeaderCell('Payment', flex: 3),
                UserManagementHeaderCell('Balance', flex: 3),
              ],
            ),
            rowCount: entries.length,
            emptyMessage: 'No records found',
            rowBuilder: (context, index) {
              final e = entries[index];
              return _stripe(
                index,
                Row(
                  children: [
                    UserManagementDataCell(
                      formatStatementDate(e.entryDate),
                      flex: 3,
                    ),
                    UserManagementDataCell(e.entryType, flex: 2),
                    UserManagementDataCell(e.reference, flex: 3),
                    UserManagementDataCell(e.description, flex: 4),
                    UserManagementDataCell(e.paymentMethod, flex: 2),
                    _badgeCell(
                      e.verificationStatus,
                      e.verificationStatus.toLowerCase() == 'approved'
                          ? UserManagementBadgeTone.success
                          : UserManagementBadgeTone.warning,
                      2,
                    ),
                    UserManagementDataCell(
                      CurrencyFormatter.format(e.chargeAmount),
                      flex: 3,
                    ),
                    UserManagementDataCell(
                      CurrencyFormatter.format(e.paymentAmount),
                      flex: 3,
                    ),
                    UserManagementDataCell(
                      CurrencyFormatter.format(e.runningBalance),
                      flex: 3,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Installment schedule.
class InvestorStatementScheduleSection extends StatelessWidget {
  const InvestorStatementScheduleSection({super.key, required this.items});

  final List<InvestorStatementScheduleItem> items;

  static UserManagementBadgeTone _tone(InvestorStatementScheduleItem item) {
    if (item.status.toLowerCase() == 'completed') {
      return UserManagementBadgeTone.success;
    }
    if (item.daysOverdue > 0) return UserManagementBadgeTone.danger;
    if (item.status.toLowerCase().startsWith('partially')) {
      return UserManagementBadgeTone.warning;
    }
    return UserManagementBadgeTone.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Installment Schedule',
            subtitle: 'Due dates, amounts paid and pending',
          ),
          UserManagementTableFrame(
            minTableWidth: 1000,
            header: const UserManagementHeaderRow(
              children: [
                UserManagementHeaderCell('No', flex: 1),
                UserManagementHeaderCell('Due Date', flex: 3),
                UserManagementHeaderCell('Amount', flex: 3),
                UserManagementHeaderCell('Paid', flex: 3),
                UserManagementHeaderCell('Pending', flex: 3),
                UserManagementHeaderCell('Status', flex: 3),
                UserManagementHeaderCell('Days Overdue', flex: 2),
              ],
            ),
            rowCount: items.length,
            emptyMessage: 'No records found',
            rowBuilder: (context, index) {
              final item = items[index];
              return _stripe(
                index,
                Row(
                  children: [
                    UserManagementDataCell('${item.installmentNo}', flex: 1),
                    UserManagementDataCell(
                      formatStatementDate(item.dueDate),
                      flex: 3,
                    ),
                    UserManagementDataCell(
                      CurrencyFormatter.format(item.amount),
                      flex: 3,
                    ),
                    UserManagementDataCell(
                      CurrencyFormatter.format(item.paidAmount),
                      flex: 3,
                    ),
                    UserManagementDataCell(
                      CurrencyFormatter.format(item.pendingAmount),
                      flex: 3,
                    ),
                    _badgeCell(item.status, _tone(item), 3),
                    UserManagementDataCell('${item.daysOverdue}', flex: 2),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
