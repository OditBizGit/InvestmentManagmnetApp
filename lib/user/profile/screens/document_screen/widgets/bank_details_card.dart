import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class BankDetailsCard extends StatelessWidget {
  const BankDetailsCard({
    super.key,
    this.details,
    this.isLoading = false,
  });

  final InvestorDetailsModel? details;
  final bool isLoading;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.4.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  ImageConstants.bankDetails,
                  width: 5.w,
                  height: 5.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 2.5.w),
                Text(
                  'Bank Details',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
            indent: 4.w,
            endIndent: 4.w,
          ),
          if (isLoading)
            const _BankDetailsShimmer(
              baseColor: _shimmerBase,
              highlightColor: _shimmerHighlight,
            )
          else ...[
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.4.h),
              child: Text(
                _displayValue(details?.bankName),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _VerifiedField(
              label: 'Account No',
              value: _displayValue(details?.accountNumber),
              isVerified: _hasValue(details?.accountNumber),
            ),
            _VerifiedField(
              label: 'IFSC Code',
              value: _displayValue(details?.ifscCode),
              isVerified: _hasValue(details?.ifscCode),
            ),
            SizedBox(height: 0.6.h),
          ],
        ],
      ),
    );
  }
}

class _BankDetailsShimmer extends StatelessWidget {
  const _BankDetailsShimmer({
    required this.baseColor,
    required this.highlightColor,
  });

  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 0.4.h),
            child: _ShimmerTextBar(
              text: 'Not Provided',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: baseColor,
            ),
          ),
          _ShimmerVerifiedField(
            label: 'Account No',
            value: 'Not Provided',
            color: baseColor,
          ),
          _ShimmerVerifiedField(
            label: 'IFSC Code',
            value: 'Not Provided',
            color: baseColor,
          ),
          SizedBox(height: 0.6.h),
        ],
      ),
    );
  }
}

class _ShimmerVerifiedField extends StatelessWidget {
  const _ShimmerVerifiedField({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerTextBar(
                  text: label,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
                SizedBox(height: 0.3.h),
                _ShimmerTextBar(
                  text: value,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.8.h),
            child: Container(
              width: 5.5.w,
              height: 5.5.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerTextBar extends StatelessWidget {
  const _ShimmerTextBar({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

String _displayValue(String? value) =>
    _hasValue(value) ? value!.trim() : 'Not Provided';

class _VerifiedField extends StatelessWidget {
  const _VerifiedField({
    required this.label,
    required this.value,
    required this.isVerified,
  });

  final String label;
  final String value;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.8.h),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.cancel,
              size: 5.5.w,
              color: isVerified ? AppColors.green : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
