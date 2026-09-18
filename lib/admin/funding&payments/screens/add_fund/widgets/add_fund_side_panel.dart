import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class AddFundSidePanel extends StatelessWidget {
  const AddFundSidePanel({
    super.key,
    required this.investor,
    required this.fundingType,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.payingNow,
    this.isLoading = false,
    required this.onCancel,
    required this.onSave,
  });

  final String? investor;
  final String? fundingType;
  final String? totalAmount;
  final String? paidAmount;
  final String? remainingAmount;
  final String? payingNow;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SelectDetailsCard(
          investor: investor,
          fundingType: fundingType,
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          remainingAmount: remainingAmount,
          payingNow: payingNow,
        ),
        const SizedBox(height: 16),
        const _NotesCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F0F3),
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textMuted,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor:
                        AppColors.accent.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Save Fund& Send Receipt',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectDetailsCard extends StatelessWidget {
  const _SelectDetailsCard({
    required this.investor,
    required this.fundingType,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.payingNow,
  });

  final String? investor;
  final String? fundingType;
  final String? totalAmount;
  final String? paidAmount;
  final String? remainingAmount;
  final String? payingNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFE8DFF2),
            iconColor: AppColors.accent,
            label: 'Investor',
            value: investor ?? 'Not Selected',
            isPlaceholder: investor == null,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.payments_outlined,
            iconBg: const Color(0xFFEAF1FC),
            iconColor: const Color(0xFF5B8DEF),
            label: 'Funding Type',
            value: fundingType ?? 'Not Selected',
            isPlaceholder: fundingType == null,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.account_balance_wallet_outlined,
            iconBg: const Color(0xFFE6F6EC),
            iconColor: AppColors.green,
            label: 'Total Amount',
            value: totalAmount ?? 'Not Selected',
            isPlaceholder: totalAmount == null,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.payments_rounded,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF43A047),
            label: 'Paid Amount',
            value: paidAmount ?? 'Not Selected',
            isPlaceholder: paidAmount == null,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.hourglass_bottom_rounded,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFB8C00),
            label: 'Remaining Amount',
            value: remainingAmount ?? 'Not Selected',
            isPlaceholder: remainingAmount == null,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.currency_rupee_rounded,
            iconBg: const Color(0xFFFDECEE),
            iconColor: const Color(0xFFE06B7A),
            label: 'Paying Now',
            value: payingNow ?? 'Not Entered',
            isPlaceholder: payingNow == null,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isPlaceholder,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder
                      ? AppColors.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  static const _notes = [
    'Select an investor to auto-fill type, total, paid, and remaining amounts.',
    'Paying Now updates Paid and Remaining amounts in real time.',
    'You cannot pay more than the remaining balance.',
    'Funding date defaults to today and can be changed if needed.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final note in _notes) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
