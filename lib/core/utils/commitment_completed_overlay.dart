import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

/// Shows a full-screen overlay when the investor's total collection
/// plus discount has reached their total commitment.
Future<void> showCommitmentCompletedOverlay(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final size = MediaQuery.sizeOf(dialogContext);

      return Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.disabled.withValues(alpha: 0.94),
                      AppColors.disabled.withValues(alpha: 0.86),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: -size.height * 0.08,
                right: -size.width * 0.28,
                child: _DecorCircle(
                  size: size.width * 0.7,
                  color: AppColors.accent.withValues(alpha: 0.1),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.06,
                left: -size.width * 0.3,
                child: _DecorCircle(
                  size: size.width * 0.55,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              SafeArea(
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
                            side: const BorderSide(
                              color: AppColors.white,
                              width: 1.5,
                            ),
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
            ],
          ),
        ),
      );
    },
  );
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Returns true when collection + discount has caught up with a positive commitment.
bool isCommitmentFullyCollected({
  required double totalCollection,
  required double totalCommitment,
  double discountAmount = 0,
}) {
  if (totalCommitment <= 0) return false;
  return (totalCollection + discountAmount) >= totalCommitment;
}
