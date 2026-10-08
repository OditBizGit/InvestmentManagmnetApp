import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

enum FundingLimitAlertKind { reached, exceeded }

enum FundingLimitDialogMode {
  /// Single dismiss action — used when opening Funding / Investors screens.
  acknowledge,

  /// Cancel / Save anyway — used when updating project amount.
  confirmSave,
}

/// Shared warning dialog when investor investment reaches or exceeds project fund.
class FundingLimitWarningDialog {
  FundingLimitWarningDialog._();

  static FundingLimitAlertKind? resolveKind({
    required double? projectAmount,
    required double totalInvestment,
  }) {
    final limit = projectAmount;
    if (limit == null || limit <= 0) return null;

    if (totalInvestment > limit + 0.01) {
      return FundingLimitAlertKind.exceeded;
    }
    if (totalInvestment + 0.01 >= limit) {
      return FundingLimitAlertKind.reached;
    }
    return null;
  }

  static String formatCurrency(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw =
        isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final withCommas = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }

  /// Shows the dialog when the limit is reached/exceeded.
  ///
  /// Returns `true` to continue (acknowledge / save anyway), `false` to cancel.
  /// Returns `true` when no dialog is needed.
  static Future<bool> showIfNeeded(
    BuildContext context, {
    required double? projectAmount,
    required double totalInvestment,
    FundingLimitDialogMode mode = FundingLimitDialogMode.acknowledge,
  }) async {
    final kind = resolveKind(
      projectAmount: projectAmount,
      totalInvestment: totalInvestment,
    );
    if (kind == null) return true;
    if (!context.mounted) return true;

    final limit = projectAmount!;
    final exceeded = kind == FundingLimitAlertKind.exceeded;
    final accent = exceeded ? AppColors.error : const Color(0xFFB86E00);
    final title = exceeded
        ? 'Project Funding Exceeded'
        : 'Project Funding Limit Reached';

    final bodyChildren = <Widget>[
      Text(
        exceeded
            ? 'Investor investments have exceeded the project funding amount.'
            : 'The total investor investment has reached the project funding amount of ${formatCurrency(limit)}.',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
      if (exceeded) ...[
        SizedBox(height: 1.2.h),
        _AmountRow(
          label: 'Project Amount',
          value: formatCurrency(limit),
        ),
        SizedBox(height: 0.6.h),
        _AmountRow(
          label: 'Total Investor Investment',
          value: formatCurrency(totalInvestment),
        ),
        SizedBox(height: 0.6.h),
        _AmountRow(
          label: 'Exceeded Amount',
          value: formatCurrency(totalInvestment - limit),
          emphasize: true,
          emphasizeColor: accent,
        ),
      ],
      SizedBox(height: 1.2.h),
      Text(
        'Please stop adding new investors or increase the project funding amount.',
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.35,
        ),
      ),
    ];

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: mode == FundingLimitDialogMode.acknowledge,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Icon(
                exceeded
                    ? Icons.error_outline_rounded
                    : Icons.warning_amber_rounded,
                color: accent,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bodyChildren,
            ),
          ),
          actions: mode == FundingLimitDialogMode.acknowledge
              ? [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      'Got it',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      'Save anyway',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ],
        );
      },
    );

    if (mode == FundingLimitDialogMode.acknowledge) return true;
    return result == true;
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.emphasizeColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? emphasizeColor;

  @override
  Widget build(BuildContext context) {
    final valueColor = emphasize
        ? (emphasizeColor ?? AppColors.error)
        : AppColors.textPrimary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
