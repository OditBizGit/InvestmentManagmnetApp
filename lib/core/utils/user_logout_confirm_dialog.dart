import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

Future<bool> showUserLogoutConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.white,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 2.5.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container(
              //   width: 14.w,
              //   height: 14.w,
              //   decoration: const BoxDecoration(
              //     color: AppColors.cardBg,
              //     shape: BoxShape.circle,
              //   ),
              //   alignment: Alignment.center,
              //   child: SvgPicture.asset(
              //     ImageConstants.logout,
              //     width: 6.5.w,
              //     height: 6.5.w,
              //     colorFilter: const ColorFilter.mode(
              //       AppColors.accent,
              //       BlendMode.srcIn,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 2.h),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 5.5.h,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: SizedBox(
                      height: 5.5.h,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}
