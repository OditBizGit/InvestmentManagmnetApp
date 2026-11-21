import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/team_overview_screen/team_overview_data.dart';
import 'package:sizer/sizer.dart';

/// Person card: lavender arch + cropped photo, then name and role.
///
/// The card has no fixed width; it fills what its parent gives it. All photo
/// geometry is a fraction of the photo block (Figma crop of a 171 x 158.1 block).
class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({super.key, required this.member});

  final TeamMember member;

  static const ValueKey<String> photoBlockKey = ValueKey('teamCardPhotoBlock');
  static const ValueKey<String> archKey = ValueKey('teamCardArch');
  static const ValueKey<String> photoBoxKey = ValueKey('teamCardPhotoBox');

  // Figma block 171 x 158.1 (width / height).
  static const double _blockAspect = 171 / 158.1;
  // Photo box (square-ish image crop) as fractions of the block.
  static const double _photoLeft = -0.2463;
  static const double _photoTop = -0.2331;
  static const double _photoWidth = 1.4925;
  static const double _photoHeight = 1.6073;
  // Arch as fractions of the block.
  static const double _archLeft = 0.027;
  static const double _archTop = 0.181;
  static const double _archWidth = 0.946;
  static const double _archHeight = 0.819;
  static const int _sourcePhotoPx = 1080;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          key: photoBlockKey,
          aspectRatio: _blockAspect,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final dpr = MediaQuery.devicePixelRatioOf(context);
              final cacheWidth = math.max(
                1,
                math.min(_sourcePhotoPx, (_photoWidth * w * dpr).round()),
              );
              return ClipRect(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      key: archKey,
                      left: _archLeft * w,
                      top: _archTop * h,
                      width: _archWidth * w,
                      height: _archHeight * h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      key: photoBoxKey,
                      left: _photoLeft * w,
                      top: _photoTop * h,
                      width: _photoWidth * w,
                      height: _photoHeight * h,
                      child: Image.asset(
                        member.photoAsset,
                        fit: BoxFit.cover,
                        cacheWidth: cacheWidth,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 2.5.w),
        // Sizer .sp is quadratic: 14.sp = ~12 px, 12.7.sp = ~10 px at 402 wide.
        // Name line height 1.35 already includes the Figma -2 name/role overlap.
        Text(
          member.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          member.role,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.7.sp,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
