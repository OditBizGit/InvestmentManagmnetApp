import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class RegisterComplaintSection extends StatelessWidget {
  const RegisterComplaintSection({
    super.key,
    required this.controller,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onRegister,
  });

  final TextEditingController controller;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Submit your complaint by providing the required details below. We'll review your request and keep you updated on its progress.",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
            height: 1.45,
          ),
        ),
        SizedBox(height: 2.5.h),
        TextField(
          controller: controller,
          maxLines: 10,
          minLines: 8,
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Text here...',
            hintStyle: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.hint,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.8.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit && !isSubmitting ? onRegister : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor:
                  isSubmitting ? AppColors.accent : AppColors.border,
              foregroundColor: AppColors.white,
              disabledForegroundColor:
                  isSubmitting ? AppColors.white : AppColors.hint,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    height: 2.2.h,
                    width: 2.2.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    'Register Complaint',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
