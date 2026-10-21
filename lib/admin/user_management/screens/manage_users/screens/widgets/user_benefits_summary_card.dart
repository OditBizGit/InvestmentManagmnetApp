import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class UserBenefitsSummaryCard extends StatelessWidget {
  const UserBenefitsSummaryCard({
    super.key,
    required this.committedAmount,
    this.depositDiscountAmount = 0,
    this.medicalAllowanceNote = '',
  });

  final double committedAmount;
  final double depositDiscountAmount;
  final String medicalAllowanceNote;

  @override
  Widget build(BuildContext context) {
    final note = medicalAllowanceNote.trim();
    final displayNote = note.isEmpty ? 'No medical allowance recorded' : note;

    return AddInvestorSectionCard(
      title: 'Deposit & company benefits',
      subtitle:
          'Discount applied on this customer\'s deposit and medical allowance given by the company',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 640;
              final tiles = [
                _BenefitTile(
                  label: 'Committed amount',
                  value: CurrencyFormatter.format(committedAmount),
                  icon: ImageConstants.addPayment,
                  iconColor: const Color(0xFF9B7EBF),
                  iconBg: const Color(0xFFF0EBF6),
                ),
                _BenefitTile(
                  label: 'Discount on deposit',
                  value: CurrencyFormatter.format(depositDiscountAmount),
                  icon: ImageConstants.amountRemaining,
                  iconColor: const Color(0xFFE89A3C),
                  iconBg: const Color(0xFFFFF3E8),
                ),
                // _BenefitTile(
                //   label: 'Medical allowance',
                //   value: CurrencyFormatter.format(user.medicalAllowanceAmount),
                //   icon: ImageConstants.totalCollection,
                //   iconColor: const Color(0xFF2CB5A8),
                //   iconBg: const Color(0xFFE6F7F5),
                // ),
              ];

              if (stacked) {
                return Column(
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      tiles[i],
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: tiles[i]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Medical allowance',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            maxLines: 3,
            initialValue: displayNote,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: note.isEmpty ? AppColors.hint : AppColors.textPrimary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Medical allowance details from funding records',
              filled: true,
              fillColor: const Color(0xFFF8F7FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final String icon;
  final Color iconColor;
  final Color iconBg;

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
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              icon,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
