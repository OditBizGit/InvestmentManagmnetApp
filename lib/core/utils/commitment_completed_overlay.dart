import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

/// Shows a full-screen accent overlay when the investor's total collection
/// has reached their total commitment.
Future<void> showCommitmentCompletedOverlay(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.accentDark.withValues(alpha: 0.5),
    builder: (dialogContext) {
      return Material(
        color: AppColors.accentDark.withValues(alpha: 0.5),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              children: [
                const Spacer(),
                SvgPicture.asset(
                  ImageConstants.tick,
                  width: 28.w,
                  height: 28.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your total commitment has been completed.\nThank you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 5.5.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Returns true when collection has caught up with a positive commitment.
bool isCommitmentFullyCollected({
  required double totalCollection,
  required double totalCommitment,
}) {
  if (totalCommitment <= 0) return false;
  return totalCollection >= totalCommitment;
}