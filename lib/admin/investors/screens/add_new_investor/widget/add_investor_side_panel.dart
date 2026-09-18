import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

/// Fixed right column: Notes + Cancel / Add Investor actions.
class AddInvestorSidePanel extends StatelessWidget {
  const AddInvestorSidePanel({
    super.key,
    required this.onCancel,
    required this.onAdd,
    this.isLoading = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: _NotesCard()),
        const SizedBox(height: 16),
        AddInvestorActionButtons(
          onCancel: onCancel,
          onAdd: onAdd,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

/// Cancel / Add Investor button row used in the fixed side panel.
class AddInvestorActionButtons extends StatelessWidget {
  const AddInvestorActionButtons({
    super.key,
    required this.onCancel,
    required this.onAdd,
    this.isLoading = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              onPressed: isLoading ? null : onAdd,
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
                      'Add Investor',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  static const _notes = [
    'All mandatory fields are marked with *',
    'Set Due Date / Split Payment is required for every new investor',
    'Choose Month, Week, or Day frequency for the payment schedule',
    'Week/Day gap is the gap between payments, not the total duration',
    'Advance payment is optional and is deducted before installment split',
    'Bank, KYC, and nominee details are optional additional information',
    'You can update investor details later from the Investors list',
    'Investment amount can be updated in the Funding & Payments section',
    'An email notification can be sent to the investor after adding',
    'Choose the correct investor type to keep reports and filters accurate',
    'Profile photo is optional; JPEG or PNG up to 2MB is supported',
    'Use the organization field for companies, funds, or institutions',
    'Double-check mobile number and email before saving contact details',
    'Investment date should match the actual funding agreement date',
    'Cancel discards unsaved changes and returns to the Investors list',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
