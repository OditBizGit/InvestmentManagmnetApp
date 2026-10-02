import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:sizer/sizer.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

  String _displayName(LocalStorage storage) {
    final fullName = storage.getFullName()?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final username = storage.getUsername()?.trim();
    if (username != null && username.isNotEmpty) return username;

    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    final storage = getIt<LocalStorage>();
    final username = _displayName(storage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        return Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container(
              //   width: 42,
              //   height: 42,
              //   decoration: const BoxDecoration(
              //     color: AppColors.cardBg,
              //     shape: BoxShape.circle,
              //   ),
              //   alignment: Alignment.center,
              //   child: SvgPicture.asset(
              //     ImageConstants.notificationBell,
              //     width: 20,
              //     height: 20,
              //     colorFilter: const ColorFilter.mode(
              //       AppColors.accent,
              //       BlendMode.srcIn,
              //     ),
              //   ),
              // ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accent,
                              ),
                            ),
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        // const Icon(
                        //   Icons.keyboard_arrow_down_rounded,
                        //   color: AppColors.textMuted,
                        //   size: 20,
                        // ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
