import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class InvestmentSummarySection extends StatelessWidget {
  const InvestmentSummarySection({
    super.key,
    required this.fullName,
    required this.investorCode,
    required this.profileImageUrl,
    required this.commitment,
    required this.isFullyPaid,
    required this.pendingAmount,
    required this.discountAmount,
    required this.lastPaymentAmount,
    required this.lastPaymentDate,
    required this.installmentCount,
    required this.paymentFrequency,
    required this.durationInterval,
  });

  final String fullName;
  final String investorCode;
  final String? profileImageUrl;
  final double commitment;
  final bool isFullyPaid;
  final double pendingAmount;
  final double discountAmount;
  final double lastPaymentAmount;
  final DateTime? lastPaymentDate;
  final int installmentCount;
  final String paymentFrequency;
  final int durationInterval;

  String get _durationLabel {
    switch (paymentFrequency) {
      case 'Week':
        return durationInterval == 1 ? 'Weekly' : 'Every $durationInterval Weeks';
      case 'Day':
        return durationInterval == 1 ? 'Daily' : 'Every $durationInterval Days';
      case 'Month':
      default:
        return durationInterval == 1
            ? 'Monthly'
            : 'Every $durationInterval Months';
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dd = date.day.toString().padLeft(2, '0');
    return '$dd-${months[date.month - 1]}-${date.year}';
  }

  String _lastPaymentLabel() {
    final amountText =
        lastPaymentAmount > 0 ? CurrencyFormatter.format(lastPaymentAmount) : '';
    if (lastPaymentDate == null) return 'Last Payment: $amountText';
    final dateText = _formatDate(lastPaymentDate!);
    if (amountText.isEmpty) return 'Last Payment: $dateText';
    return 'Last Payment: $amountText · $dateText';
  }

  @override
  Widget build(BuildContext context) {
    final commitmentCompleted = pendingAmount <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileHeader(
          fullName: fullName,
          investorCode: investorCode,
          profileImageUrl: profileImageUrl,
        ),
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(right: isFullyPaid ? 3.w : 0),
              child: Text(
                CurrencyFormatter.format(commitment),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isFullyPaid)
              Positioned(
                top: 0.2.h,
                right: 0,
                child: SizedBox(
                  width: 3.2.w,
                  height: 3.2.w,
                  child: SvgPicture.asset(
                    ImageConstants.tick,
                    width: 2.2.w,
                    height: 2.2.w,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      AppColors.green,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          commitmentCompleted
              ? 'Commitment completed'
              : 'Balance: ${CurrencyFormatter.format(pendingAmount)}',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: commitmentCompleted ? AppColors.green : AppColors.error,
          ),
        ),
        if (discountAmount > 0) ...[
          SizedBox(height: 0.4.h),
          Text(
            'Discount: ${CurrencyFormatter.format(discountAmount)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
        if (lastPaymentAmount > 0 || lastPaymentDate != null) ...[
          SizedBox(height: 0.3.h),
          Text(
            _lastPaymentLabel(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
        SizedBox(height: 0.1.h),
        _InvestmentMetaRow(
          installmentCount: installmentCount,
          durationLabel: _durationLabel,
        ),
      ],
    );
  }
}

class _InvestmentMetaRow extends StatelessWidget {
  const _InvestmentMetaRow({
    required this.installmentCount,
    required this.durationLabel,
  });

  final int installmentCount;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetaItem(
            label: 'No. of Installments',
            value: '$installmentCount',
            alignEnd: false,
          ),
        ),
        Expanded(
          child: _MetaItem(
            label: 'Installment Duration',
            value: durationLabel,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final alignment =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 0.1.h),
        Text(
          value,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.investorCode,
    this.profileImageUrl,
  });

  final String fullName;
  final String investorCode;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = profileImageUrl != null && profileImageUrl!.isNotEmpty;
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
            backgroundColor: AppColors.cardBg,
            backgroundImage: hasImage ? NetworkImage(profileImageUrl!) : null,
            child: hasImage
                ? null
                : Icon(
                    Icons.person_rounded,
                    size: 8.w,
                    color: AppColors.accent,
                  ),
          ),
        ),
        SizedBox(width: 3.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
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
                  investorCode,
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
