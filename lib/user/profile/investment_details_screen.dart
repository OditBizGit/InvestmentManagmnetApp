import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class InvestmentDetailsScreen extends StatelessWidget {
  const InvestmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 5.5.w,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Investment Details',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
