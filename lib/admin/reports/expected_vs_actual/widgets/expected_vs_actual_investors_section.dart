import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../model/expected_vs_actual_model.dart';
import 'expected_vs_actual_status_views.dart';

/// Investor table of one month, ending with a totals row.
class ExpectedVsActualInvestorsSection extends StatelessWidget {
  const ExpectedVsActualInvestorsSection({
    super.key,
    required this.monthLabel,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.details,
  });

  static const double _minTableWidth = 1250;

  final String monthLabel;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ExpectedVsActualDetails details;

  @override
  Widget build(BuildContext context) {
    final rows = details.rows;

    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Investors ($monthLabel)',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Expected and collected amounts per investor',
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const ExpectedVsActualLoadingBox()
          else if (errorMessage != null)
            ExpectedVsActualErrorBox(message: errorMessage!, onRetry: onRetry)
          else
            UserManagementTableFrame(
              minTableWidth: _minTableWidth,
              header: const UserManagementHeaderRow(
                children: [
                  UserManagementHeaderCell('Investor Code', flex: 2),
                  UserManagementHeaderCell('Investor Name', flex: 3),
                  UserManagementHeaderCell('Expected', flex: 3),
                  UserManagementHeaderCell('Installments', flex: 2),
                  UserManagementHeaderCell('Payments', flex: 3),
                  UserManagementHeaderCell('Refunds', flex: 3),
                  UserManagementHeaderCell('Actual', flex: 3),
                  UserManagementHeaderCell('Rate %', flex: 2),
                ],
              ),
              rowCount: rows.isEmpty ? 0 : rows.length + 1,
              emptyMessage: 'No records found',
              rowBuilder: (context, index) {
                if (index == rows.length) {
                  return _InvestorRow(
                    index: index,
                    isTotal: true,
                    code: 'Total',
                    name: '${details.totals.investorCount} investors',
                    expected: details.totals.expectedAmount,
                    installments: details.totals.expectedInstallments,
                    payments: details.totals.actualPayments,
                    refunds: details.totals.refunds,
                    actual: details.totals.actualAmount,
                    rate: details.totals.collectionRate,
                  );
                }
                final item = rows[index];
                return _InvestorRow(
                  index: index,
                  code: item.investorCode,
                  name: item.name,
                  expected: item.expectedAmount,
                  installments: item.expectedInstallments,
                  payments: item.actualPayments,
                  refunds: item.refunds,
                  actual: item.actualAmount,
                  rate: item.collectionRate,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InvestorRow extends StatelessWidget {
  const _InvestorRow({
    required this.index,
    required this.code,
    required this.name,
    required this.expected,
    required this.installments,
    required this.payments,
    required this.refunds,
    required this.actual,
    required this.rate,
    this.isTotal = false,
  });

  final int index;
  final bool isTotal;
  final String code;
  final String name;
  final double expected;
  final int installments;
  final double payments;
  final double refunds;
  final double actual;
  final double? rate;

  @override
  Widget build(BuildContext context) {
    final weight = isTotal ? FontWeight.w700 : FontWeight.w400;

    Widget cell(String text, int flex) => Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: weight,
          color: AppColors.textPrimary,
        ),
      ),
    );

    return ColoredBox(
      color: isTotal
          ? AppColors.cardBg
          : (index.isEven ? AppColors.white : const Color(0xFFFBF9FC)),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                    color: isTotal ? AppColors.textPrimary : AppColors.accent,
                  ),
                ),
              ),
              cell(name, 3),
              cell(CurrencyFormatter.format(expected), 3),
              cell('$installments', 2),
              cell(CurrencyFormatter.format(payments), 3),
              cell(CurrencyFormatter.format(refunds), 3),
              cell(CurrencyFormatter.format(actual), 3),
              cell(formatCollectionRate(rate), 2),
            ],
          ),
        ),
      ),
    );
  }
}
