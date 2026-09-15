import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class InvestmentDetailsScreen extends StatelessWidget {
  const InvestmentDetailsScreen({super.key});

  static const Color _greenSoft = Color(0xFFE6F6EC);
  static const Color _teal = Color(0xFF2BB8A8);
  static const Color _cardBorder = Color(0xFFE8E4EE);
  static const Color _payDisabledBg = Color(0xFFEDEDED);
  static const Color _payDisabledText = Color(0xFFB0B0B0);

  static const List<_PaymentScheduleItem> _payments = [
    _PaymentScheduleItem(
      date: 'SEP 28, 26',
      label: 'First Payment',
      amount: '₹1,00,000',
      status: _PaymentStatus.paid,
    ),
    _PaymentScheduleItem(
      date: 'OCT 28, 26',
      label: 'Second Payment',
      amount: '₹1,00,000',
      status: _PaymentStatus.due,
    ),
    _PaymentScheduleItem(
      date: 'NOV 28, 26',
      label: 'Third Payment',
      amount: '₹50,000',
      status: _PaymentStatus.upcoming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        'Investment Details',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProfileHeader(),
                    SizedBox(height: 2.5.h),
                    Text(
                      'Total Commitment',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 0.1.h),
                    Text(
                      '₹2,50,000',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    for (var i = 0; i < _payments.length; i++) ...[
                      _PaymentCard(item: _payments[i]),
                      if (i != _payments.length - 1) SizedBox(height: 1.4.h),
                    ],
                    SizedBox(height: 2.8.h),
                    Text(
                      'Recent Transaction',
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    const _RecentTransactionCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentStatus { paid, due, upcoming }

class _PaymentScheduleItem {
  const _PaymentScheduleItem({
    required this.date,
    required this.label,
    required this.amount,
    required this.status,
  });

  final String date;
  final String label;
  final String amount;
  final _PaymentStatus status;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(0.2.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 8.w,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
            ),
          ),
        ),
        SizedBox(width: 3.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Mathew',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 0.6.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.45.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  'INV - 10254',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.item});

  final _PaymentScheduleItem item;

  bool get _isPaid => item.status == _PaymentStatus.paid;
  bool get _isDue => item.status == _PaymentStatus.due;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: _isPaid
            ? InvestmentDetailsScreen._greenSoft
            : AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(
          color: _isPaid
              ? InvestmentDetailsScreen._greenSoft
              : InvestmentDetailsScreen._cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 0.6.h),
              _PaymentLabelBadge(label: item.label, isPaid: _isPaid),
            ],
          ),
          SizedBox(height: 0.6.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _isPaid
                        ? AppColors.green
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (_isPaid)
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 3.5.w,
                  ),
                )
              else
                _PayNowButton(enabled: _isDue),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentLabelBadge extends StatelessWidget {
  const _PaymentLabelBadge({
    required this.label,
    required this.isPaid,
  });

  final String label;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.45.h),
      decoration: BoxDecoration(
        color: isPaid ? InvestmentDetailsScreen._teal : Colors.transparent,
        borderRadius: BorderRadius.circular(1.w),
        border: isPaid
            ? null
            : Border.all(color: InvestmentDetailsScreen._cardBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isPaid ? AppColors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _PayNowButton extends StatelessWidget {
  const _PayNowButton({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.accent
          : InvestmentDetailsScreen._payDisabledBg,
      borderRadius: BorderRadius.circular(1.w),
      child: InkWell(
        onTap: enabled ? () {} : null,
        borderRadius: BorderRadius.circular(1.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            'Pay Now',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? AppColors.white
                  : InvestmentDetailsScreen._payDisabledText,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  const _RecentTransactionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: InvestmentDetailsScreen._cardBorder),
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
                      'Maribel Investment',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      'First Payment',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
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
                'SEP 28, 26',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '₹1,00,000',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
