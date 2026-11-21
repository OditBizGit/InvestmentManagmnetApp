import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

/// Full-width accent pill: white icon + white section title.
class TeamSectionHeader extends StatelessWidget {
  const TeamSectionHeader({
    super.key,
    required this.iconPath,
    required this.title,
  });

  final String iconPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 2.w),
        child: Row(
          children: [
            // Icons are white 18x18 strokes; never tinted.
            SvgPicture.asset(iconPath, width: 4.5.w, height: 4.5.w),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
