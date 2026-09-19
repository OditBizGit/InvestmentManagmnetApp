import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/transaction_receipt_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.projectName,
    required this.transactions,
  });

  final String projectName;
  final List<InvestorTransactionItemModel> transactions;

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _green = Color(0xFF1BA752);
  static const Color _red = Color(0xFFE05A4F);
  static const Color _border = Color(0xFFE8E4EE);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  /// Shimmer matching section title + [_TransactionCard] layout/size.
  static const int shimmerCardCount = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions (${transactions.length})',
          style: TextStyle(
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        if (transactions.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
            ),
          )
        else
          for (var i = 0; i < transactions.length; i++) ...[
            _TransactionCard(
              title: projectName.trim().isNotEmpty
                  ? projectName
                  : 'Investment',
              entryNo: transactions[i].entryNo,
              subtitle: _subtitleFor(transactions[i]),
              date: UserInvestmentsScreen.formatDate(transactions[i].date),
              time: UserInvestmentsScreen.formatTransactionTime(
                transactions[i].date,
              ),
              amount: UserInvestmentsScreen.formatCurrency(
                transactions[i].paidAmount > 0
                    ? transactions[i].paidAmount
                    : transactions[i].receivedAmount,
              ),
              closingBalance: UserInvestmentsScreen.formatCurrency(
                transactions[i].pendingAmount,
              ),
              onDownload: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TransactionReceiptScreen(
                      projectName: projectName,
                      transaction: transactions[i],
                    ),
                  ),
                );
              },
            ),
            if (i != transactions.length - 1) SizedBox(height: 1.4.h),
          ],
      ],
    );
  }

  static String _subtitleFor(InvestorTransactionItemModel item) {
    if (item.paymentMethod.trim().isNotEmpty) {
      return item.paymentMethod;
    }
    if (item.status.trim().isNotEmpty) {
      return item.status;
    }
    if (item.narration.trim().isNotEmpty) {
      return item.narration;
    }
    return '';
  }
}

/// Loading placeholder for [RecentTransactionsSection] with matching sizes.
class RecentTransactionsSectionShimmer extends StatelessWidget {
  const RecentTransactionsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: RecentTransactionsSection._shimmerBase,
          highlightColor: RecentTransactionsSection._shimmerHighlight,
          direction: ShimmerDirection.ltr,
          period: const Duration(milliseconds: 1400),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.55,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        for (var i = 0;
            i < RecentTransactionsSection.shimmerCardCount;
            i++) ...[
          const _TransactionCardShimmer(),
          if (i != RecentTransactionsSection.shimmerCardCount - 1)
            SizedBox(height: 1.4.h),
        ],
      ],
    );
  }
}

class _TransactionCardShimmer extends StatelessWidget {
  const _TransactionCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: RecentTransactionsSection._shimmerBase,
      highlightColor: RecentTransactionsSection._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RecentTransactionsSection._border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TxLine(
                        sample: 'Project Name Placeholder',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        widthFactor: 0.7,
                      ),
                      SizedBox(height: 0.2.h),
                      _TxLine(
                        sample: 'Entry No: 000 · UPI',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        widthFactor: 0.55,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 5.5.w,
                  height: 5.5.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.6.h),
            Row(
              children: [
                Expanded(
                  child: _TxLine(
                    sample: '18-SEP-2026  ·  2:30 PM',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    widthFactor: 0.55,
                  ),
                ),
                _TxLine(
                  sample: '₹00,000',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.4.h),
            Align(
              alignment: Alignment.centerRight,
              child: _TxLine(
                sample: 'Balance: ₹00,000',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxLine extends StatelessWidget {
  const _TxLine({
    required this.sample,
    required this.style,
    this.widthFactor,
  });

  final String sample;
  final TextStyle style;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        sample,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style.copyWith(color: Colors.transparent),
      ),
    );

    if (widthFactor == null) return line;

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor!.clamp(0.0, 1.0),
        child: line,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.title,
    required this.entryNo,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.closingBalance,
    required this.onDownload,
  });

  final String title;
  final int entryNo;
  final String subtitle;
  final String date;
  final String time;
  final String amount;
  final String closingBalance;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecentTransactionsSection._border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: RecentTransactionsSection._textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      subtitle.isNotEmpty
                          ? 'Entry No: $entryNo · ${subtitle.toUpperCase()}'
                          : 'Entry No: $entryNo',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: RecentTransactionsSection._textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onDownload,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(0.5.w),
                  child: SvgPicture.asset(
                    ImageConstants.download,
                    width: 5.w,
                    height: 5.w,
                    colorFilter: ColorFilter.mode(
                      RecentTransactionsSection._textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.6.h),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: RecentTransactionsSection._textPrimary,
                    ),
                    children: [
                      TextSpan(text: date),
                      if (time.isNotEmpty) ...[
                        TextSpan(
                          text: '  ·  ',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: RecentTransactionsSection._textSecondary,
                          ),
                        ),
                        TextSpan(text: time),
                      ],
                    ],
                  ),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: RecentTransactionsSection._green,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.4.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Balance: $closingBalance',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w500,
                color: RecentTransactionsSection._red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
