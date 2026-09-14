import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

/// Right column: notes and action buttons.
class AddInvestorSidePanel extends StatelessWidget {
  const AddInvestorSidePanel({
    super.key,
    required this.onCancel,
    required this.onAdd,
    this.fillHeight = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onAdd;

  /// When true, stretches Notes so the panel matches the form cards height.
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final notesCard = _NotesCard(expand: fillHeight);

    final actionButtons = Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F0F3),
                foregroundColor: AppColors.textPrimary,
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
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
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

    if (!fillHeight) {
      return Column(
        children: [
          notesCard,
          const SizedBox(height: 16),
          actionButtons,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SizedBox.expand(child: notesCard),
        ),
        const SizedBox(height: 16),
        actionButtons,
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({this.expand = false});

  final bool expand;

  static const _notes = [
    'All mandatory fields are marked with *',
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
      height: expand ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
      ),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
