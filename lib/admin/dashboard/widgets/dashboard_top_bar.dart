import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/image_constants.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    this.username = 'Username',
    this.role = 'Admin',
  });

  final String username;
  final String role;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        // final searchField = ConstrainedBox(
        //   constraints: BoxConstraints(
        //     maxWidth: isCompact ? double.infinity : 360,
        //   ),
        //   child: TextField(
        //     decoration: InputDecoration(
        //       hintText: 'Search Investors...',
        //       hintStyle: TextStyle(
        //         fontSize: 11.sp,
        //         color: AppColors.hint,
        //         fontWeight: FontWeight.w400,
        //       ),
        //       prefixIcon: const Icon(
        //         Icons.search,
        //         color: AppColors.hint,
        //         size: 20,
        //       ),
        //       filled: true,
        //       fillColor: AppColors.white,
        //       contentPadding: const EdgeInsets.symmetric(
        //         horizontal: 16,
        //         vertical: 12,
        //       ),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(12),
        //         borderSide: const BorderSide(color: AppColors.border),
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(12),
        //         borderSide: const BorderSide(color: AppColors.border),
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(12),
        //         borderSide: const BorderSide(color: AppColors.accent),
        //       ),
        //     ),
        //   ),
        // );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 2.w,
              height: 2.w,
              decoration: const BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: SvgPicture.asset(
                    ImageConstants.notificationBell,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.cardBg,
                      child: Icon(
                        Icons.person,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            role,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );

        // if (isCompact) {
        //   return Column(
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //       searchField,
        //       const SizedBox(height: 12),
        //       Align(alignment: Alignment.centerRight, child: actions),
        //     ],
        //   );
        // }

        // return Row(
        //   children: [
        //     Expanded(
        //       child: Align(
        //         alignment: Alignment.centerLeft,
        //         child: searchField,
        //       ),
        //     ),
        //     const SizedBox(width: 16),
        //     actions,
        //   ],
        // );

        return Align(
          alignment: Alignment.centerRight,
          child: actions,
        );
      },
    );
  }
}
