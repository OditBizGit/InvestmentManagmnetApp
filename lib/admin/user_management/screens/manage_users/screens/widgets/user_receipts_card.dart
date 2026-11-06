import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

/// Dummy receipts list for investor status screen (API later).
class UserReceiptsCard extends StatelessWidget {
  const UserReceiptsCard({super.key});

  static final List<_DummyReceipt> _dummyReceipts = [
    _DummyReceipt(
      receiptNo: 'RCPT-000145',
      date: DateTime(2026, 10, 29),
      amount: 25000,
      purpose: 'Investment – First Payment',
    ),
    _DummyReceipt(
      receiptNo: 'RCPT-000144',
      date: DateTime(2026, 10, 15),
      amount: 10000,
      purpose: 'Advance Payment',
    ),
    _DummyReceipt(
      receiptNo: 'RCPT-000138',
      date: DateTime(2026, 10, 1),
      amount: 20000,
      purpose: 'Monthly Investment',
    ),
    _DummyReceipt(
      receiptNo: 'RCPT-000132',
      date: DateTime(2026, 9, 17),
      amount: 25000,
      purpose: 'Investment – Second Payment',
    ),
    _DummyReceipt(
      receiptNo: 'RCPT-000128',
      date: DateTime(2026, 9, 1),
      amount: 25000,
      purpose: 'Initial Investment',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final receipts = _dummyReceipts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipts',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All receipts given to this user',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total Receipts: ${receipts.length}',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              if (compact) {
                return Column(
                  children: [
                    for (var i = 0; i < receipts.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _ReceiptCompactTile(
                        index: i + 1,
                        receipt: receipts[i],
                      ),
                    ],
                  ],
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    const _ReceiptTableHeader(),
                    for (var i = 0; i < receipts.length; i++)
                      _ReceiptTableRow(
                        index: i + 1,
                        receipt: receipts[i],
                        showDivider: i < receipts.length - 1,
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

class _DummyReceipt {
  const _DummyReceipt({
    required this.receiptNo,
    required this.date,
    required this.amount,
    required this.purpose,
  });

  final String receiptNo;
  final DateTime date;
  final double amount;
  final String purpose;
}

class _ReceiptTableHeader extends StatelessWidget {
  const _ReceiptTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text('#', style: _headerStyle),
          ),
          Expanded(
            flex: 3,
            child: Text('Receipt No.', style: _headerStyle),
          ),
          Expanded(
            flex: 3,
            child: Text('Receipt Date', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('Amount', style: _headerStyle),
          ),
          Expanded(
            flex: 4,
            child: Text('Purpose / Remarks', style: _headerStyle),
          ),
           SizedBox(
            width: 118,
            child: Text(
              'Action',
              textAlign: TextAlign.center,
              style: _headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  static final _headerStyle = TextStyle(
    fontSize: 9.5.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}

class _ReceiptTableRow extends StatelessWidget {
  const _ReceiptTableRow({
    required this.index,
    required this.receipt,
    required this.showDivider,
  });

  final int index;
  final _DummyReceipt receipt;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.border),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _IndexBadge(index: index),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              receipt.receiptNo,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.accentDark,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _DateLabel(date: receipt.date),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.format(receipt.amount),
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              receipt.purpose,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 118,
            child: Align(
              alignment: Alignment.centerRight,
              child: _DownloadButton(receiptNo: receipt.receiptNo),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCompactTile extends StatelessWidget {
  const _ReceiptCompactTile({
    required this.index,
    required this.receipt,
  });

  final int index;
  final _DummyReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IndexBadge(index: index),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  receipt.receiptNo,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(receipt.amount),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DateLabel(date: receipt.date),
          const SizedBox(height: 6),
          Text(
            receipt.purpose,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _DownloadButton(receiptNo: receipt.receiptNo),
          ),
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$index',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 13.sp,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _formatReceiptDate(date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.receiptNo});

  final String receiptNo;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        AppToast.success(
          'Download for $receiptNo will be available after API integration.',
          title: 'Receipt',
          context: context,
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentDark,
        side: const BorderSide(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(Icons.download_rounded, size: 15.sp),
      label: Text(
        'Download',
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatReceiptDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${value.day.toString().padLeft(2, '0')} '
      '${months[value.month - 1]} ${value.year}';
}
