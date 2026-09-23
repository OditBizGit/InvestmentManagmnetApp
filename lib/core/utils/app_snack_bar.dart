import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
    EdgeInsetsGeometry? margin,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: margin,
          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
          content: _AppSnackBarContent(
            message: message,
            icon: icon,
          ),
        ),
      );
  }
}

class _AppSnackBarContent extends StatelessWidget {
  const _AppSnackBarContent({
    required this.message,
    this.icon,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 5.w,
              color: AppColors.accent,
            ),
            SizedBox(width: 2.5.w),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
