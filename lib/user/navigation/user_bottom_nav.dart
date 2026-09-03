import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class UserBottomNav extends StatelessWidget {
  const UserBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const int homeIndex = 0;
  static const int investmentIndex = 1;
  static const int statusIndex = 2;
  static const int updatesIndex = 3;
  static const int profileIndex = 4;

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _activeColor = AppColors.accent;
  static const Color _inactiveColor = AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: 1.h),
        child: SizedBox(
          height: 8.h,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              _NavItem(
                iconPath: ImageConstants.home,
                label: 'Home',
                isSelected: currentIndex == homeIndex,
                onTap: () => onTap(homeIndex),
              ),
              _NavItem(
                iconPath: ImageConstants.investment,
                label: 'Investment',
                isSelected: currentIndex == investmentIndex,
                onTap: () => onTap(investmentIndex),
              ),
              _NavItem(
                iconPath: ImageConstants.status,
                label: 'Status',
                isSelected: currentIndex == statusIndex,
                onTap: () => onTap(statusIndex),
                isCenter: true,
              ),
              _NavItem(
                iconPath: ImageConstants.updates,
                label: 'Updates',
                isSelected: currentIndex == updatesIndex,
                onTap: () => onTap(updatesIndex),
              ),
              _NavItem(
                iconPath: ImageConstants.profile,
                label: 'Profile',
                isSelected: currentIndex == profileIndex,
                onTap: () => onTap(profileIndex),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCenter = false,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? UserBottomNav._activeColor
        : UserBottomNav._inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCenter)
              SvgPicture.asset(
                iconPath,
                width: 9.w,
                height: 9.w,
              )
            else
              SvgPicture.asset(
                iconPath,
                width: 5.5.w,
                height: 5.5.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
