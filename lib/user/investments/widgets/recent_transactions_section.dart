import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _green = Color(0xFF1BA752);
  static const Color _border = Color(0xFFE8E4EE);

  static const List<_TransactionData> _transactions = [
    _TransactionData(
      title: 'Maribel Investment',
      subtitle: 'First Transaction',
      date: 'SEP 28, 26',
      amount: '₹50,000',
    ),
    _TransactionData(
      title: 'Maribel Investment',
      subtitle: 'Second Transaction',
      date: 'SEP 28, 26',
      amount: '₹50,000',
    ),
    _TransactionData(
      title: 'Maribel Investment',
      subtitle: 'Third Transaction',
      date: 'SEP 28, 26',
      amount: '₹50,000',
    ),
    _TransactionData(
      title: 'Maribel Investment',
      subtitle: 'Fourth Transaction',
      date: 'SEP 28, 26',
      amount: '₹50,000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transaction',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        for (var i = 0; i < _transactions.length; i++) ...[
          _TransactionCard(transaction: _transactions[i]),
          if (i != _transactions.length - 1) SizedBox(height: 1.4.h),
        ],
      ],
    );
  }
}

class _TransactionData {
  const _TransactionData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final String date;
  final String amount;
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final _TransactionData transaction;

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
                      transaction.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: RecentTransactionsSection._textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      transaction.subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: RecentTransactionsSection._textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                ImageConstants.print,
                width: 5.5.w,
                height: 5.5.w,
              ),
            ],
          ),
          SizedBox(height: 1.6.h),
          Row(
            children: [
              Text(
                transaction.date,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: RecentTransactionsSection._textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                transaction.amount,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: RecentTransactionsSection._green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
