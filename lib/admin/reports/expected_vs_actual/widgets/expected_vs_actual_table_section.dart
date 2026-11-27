import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/month_range_picker.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../model/expected_vs_actual_model.dart';
import 'expected_vs_actual_status_views.dart';

/// Month table of the Expected vs Actual report.
class ExpectedVsActualTableSection extends StatelessWidget {
  const ExpectedVsActualTableSection({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.months,
    required this.onViewMonth,
  });

  static const double _minTableWidth = 1100;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final List<ExpectedVsActualRow> months;
  final ValueChanged<ExpectedVsActualRow> onViewMonth;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Monthly Collection',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Expected installments versus actual collections per month',
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
                  UserManagementHeaderCell('Month', flex: 2),
                  UserManagementHeaderCell('Expected', flex: 3),
                  UserManagementHeaderCell('Installments', flex: 2),
                  UserManagementHeaderCell('Payments', flex: 3),
                  UserManagementHeaderCell('Refunds', flex: 3),
                  UserManagementHeaderCell('Actual', flex: 3),
                  UserManagementHeaderCell('Rate %', flex: 2),
                  UserManagementHeaderCell(
                    'View',
                    flex: 2,
                    align: TextAlign.center,
                  ),
                ],
              ),
              rowCount: months.length,
              emptyMessage: 'No records found',
              rowBuilder: (context, index) => _MonthRow(
                index: index,
                item: months[index],
                onView: () => onViewMonth(months[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({
    required this.index,
    required this.item,
    required this.onView,
  });

  final int index;
  final ExpectedVsActualRow item;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final month = item.month;

    return ColoredBox(
      color: index.isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  month == null ? '—' : MonthRangePicker.formatMonth(month),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(item.expectedAmount),
                flex: 3,
              ),
              UserManagementDataCell('${item.expectedInstallments}', flex: 2),
              UserManagementDataCell(
                CurrencyFormatter.format(item.actualPayments),
                flex: 3,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(item.refunds),
                flex: 3,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(item.actualAmount),
                flex: 3,
              ),
              UserManagementDataCell(
                formatCollectionRate(item.collectionRate),
                flex: 2,
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
