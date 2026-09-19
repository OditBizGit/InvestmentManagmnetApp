import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:sizer/sizer.dart';


class TransactionReceiptScreen extends StatelessWidget {
  const TransactionReceiptScreen({
    super.key,
    required this.projectName,
    required this.transaction,
  });

  final String projectName;
  final InvestorTransactionItemModel transaction;

  static const Color _divider = Color(0xFFE8E4EE);
  static const Color _dashed = Color(0xFFD0CBD8);

  @override
  Widget build(BuildContext context) {
    final amount = transaction.paidAmount > 0
        ? transaction.paidAmount
        : transaction.receivedAmount;
    final amountLabel = UserInvestmentsScreen.formatCurrency(amount);
    final amountInWords = CurrencyFormatter.amountInWords(amount);
    final dateLabel = UserInvestmentsScreen.formatDate(transaction.date);
    final timeLabel =
        UserInvestmentsScreen.formatTransactionTime(transaction.date);
    final dateTime = timeLabel.isNotEmpty ? '$dateLabel · $timeLabel' : dateLabel;
    final paymentMethod = transaction.paymentMethod.trim().isNotEmpty
        ? transaction.paymentMethod
        : (transaction.status.trim().isNotEmpty
            ? transaction.status
            : '—');
    final displayProject = projectName.trim().isNotEmpty
        ? projectName.trim()
        : 'Investment';

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 5.5.w,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Payment Receipt',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        ImageConstants.logo,
                        height: 7.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        'TRANSACTION RECEIPT',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.accentDark,
                        ),
                      ),
                      SizedBox(height: 0.1.h),
                      Text(
                        'Acknowledgement of payment received',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // SizedBox(height: 2.h),
                      // _DashedDivider(color: _dashed),
                      SizedBox(height: 4.h),
                      Text(
                        amountLabel,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                      Text(
                        amountInWords,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.5.w),
                          border: Border.all(color: AppColors.green.withValues(alpha: 0.4), width: 0.1.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 0.8.w),
                            SvgPicture.asset(
                              ImageConstants.tick,
                              width: 2.5.w,
                              height: 2.5.w,
                              colorFilter: const ColorFilter.mode(
                                AppColors.green,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'PAID',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ), 
                            SizedBox(width: 1.w),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _DashedDivider(color: _dashed),
                      SizedBox(height: 1.5.h),
                      _ReceiptRow(label: 'Project', value: displayProject.toUpperCase()),
                      _ReceiptRow(
                        label: 'Entry No',
                        value: '${transaction.entryNo}'.toUpperCase(),
                      ),
                      _ReceiptRow(
                        label: 'Investor',
                        value: transaction.fullName.trim().isNotEmpty
                            ? transaction.fullName.toUpperCase()
                            : '—',
                      ),
                      _ReceiptRow(label: 'Date & Time', value: dateTime),
                      _ReceiptRow(
                        label: 'Payment Method',
                        value: paymentMethod.toUpperCase(),
                      ),
                      if (transaction.narration.trim().isNotEmpty)
                        _ReceiptRow(
                          label: 'Narration',
                          value: transaction.narration,
                        ),
                      _ReceiptRow(
                        label: 'Closing Balance',
                        value: UserInvestmentsScreen.formatCurrency(
                          transaction.pendingAmount,
                        ),
                        valueColor: const Color(0xFFE05A4F),
                      ),
                      SizedBox(height: 1.5.h),
                      _DashedDivider(color: _dashed),
                      SizedBox(height: 2.h),
                      Text(
                        'Thank you for your investment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 0.1.h),
                      Text(
                        'Maribel Wellness Centre',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 6.h,
                      child: OutlinedButton(
                        onPressed: () {
                          AppSnackBar.show(
                            context,
                            message: 'Share coming soon',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentDark,
                          side: const BorderSide(color: AppColors.accentDark),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              ImageConstants.share,
                              width: 4.5.w,
                              height: 4.5.w,
                              colorFilter: const ColorFilter.mode(
                                AppColors.accentDark,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: SizedBox(
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: () {
                          AppSnackBar.show(
                            context,
                            message: 'PDF download coming soon',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              ImageConstants.download,
                              width: 4.5.w,
                              height: 4.5.w,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Download',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.8.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => SizedBox(
              width: dashWidth,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}
