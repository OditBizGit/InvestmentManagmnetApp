import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/lottie_constants.dart';
import 'package:sizer/sizer.dart';

class ComplaintSuccessScreen extends StatelessWidget {
  const ComplaintSuccessScreen({
    super.key,
    this.onDone,
    this.title = 'SUCCESS!',
    this.message =
        'Your complaint has been registered\nsuccessfully.',
    this.buttonLabel = 'Done',
  });

  final VoidCallback? onDone;
  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              const Spacer(),
              Lottie.asset(
                LottieConstants.success,
                width: 40.w,
                height: 40.w,
                repeat: false,
              ),
              SizedBox(height: 0.5.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (onDone != null) {
                      onDone!();
                      return;
                    }
                    Navigator.of(context).maybePop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
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
  }
}
