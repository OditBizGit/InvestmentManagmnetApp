import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:sizer/sizer.dart';

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key, this.details});

  final InvestorDetailsModel? details;

  static String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not Provided';
    return value.trim();
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not Provided';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  static String _formatAllowance(double? amount) {
    if (amount == null) return 'Not Provided';
    return CurrencyFormatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _PersonalInfoItem(
        label: 'Name',
        value: _displayValue(details?.fullName),
      ),
      _PersonalInfoItem(
        label: 'Email Address',
        value: _displayValue(details?.email),
      ),
      _PersonalInfoItem(
        label: 'Phone Number',
        value: _displayValue(details?.phoneNumber),
      ),
      _PersonalInfoItem(
        label: 'Alternate Phone Number',
        value: _displayValue(details?.alternativeNumber),
      ),
      _PersonalInfoItem(
        label: 'Permanent Address',
        value: _displayValue(details?.address),
      ),
      // _PersonalInfoItem(
      //   label: 'Date of Birth',
      //   value: _formatDate(details?.dateOfBirth),
      // ),
      // _PersonalInfoItem(
      //   label: 'Investor Type',
      //   value: _displayValue(details?.investorType),
      // ),
      // _PersonalInfoItem(
      //   label: 'Organization',
      //   value: _displayValue(details?.organization),
      // ),
      _PersonalInfoItem(
        label: 'Description',
        value: _displayValue(details?.description),
      ),
      _PersonalInfoItem(
        label: 'Medical Allowance',
        value: _formatAllowance(details?.medicalAllowance),
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.disabled.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.disabled.withValues(alpha: 0.2),
                indent: 4.w,
                endIndent: 4.w,
              ),
            _InfoRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _PersonalInfoItem {
  const _PersonalInfoItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final _PersonalInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
