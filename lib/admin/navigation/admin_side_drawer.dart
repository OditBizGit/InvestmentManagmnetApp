import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';

enum AdminDrawerItem {
  dashboard,
  investors,
  fundingPayments,
  workProgress,
  photosVideos,
  updatesStatus,
  reports,
  settings,
  adminUsers,
}

/// Dispatched from dashboard quick actions to switch the admin shell tab.
class AdminNavigateNotification extends Notification {
  AdminNavigateNotification(this.item);

  final AdminDrawerItem item;
}

class AdminSideDrawer extends StatelessWidget {
  const AdminSideDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onLogout,
    this.collapsed = false,
    this.animate = true,
  });

  final AdminDrawerItem selectedItem;
  final ValueChanged<AdminDrawerItem> onItemSelected;
  final VoidCallback onLogout;
  final bool collapsed;
  final bool animate;

  static const double sidebarWidth = 248;
  static const double collapsedWidth = 72;

  /// Labels only appear once the animated width has enough room.
  static const double _labelRevealWidth = 140;

  static final List<_DrawerDestination> _destinations = [
    _DrawerDestination(
      item: AdminDrawerItem.dashboard,
      label: 'Dashboard',
      icon: ImageConstants.dashboard,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.investors,
      label: 'Investors',
      icon: ImageConstants.investors,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.fundingPayments,
      label: 'Funding & Payments',
      icon: ImageConstants.investors,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.workProgress,
      label: 'Work Progress',
      icon: ImageConstants.workProgress,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.photosVideos,
      label: 'Photos & Videos',
      icon: ImageConstants.photosVideos,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.updatesStatus,
      label: 'Updates / Status',
      icon: ImageConstants.investors,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.reports,
      label: 'Reports',
      icon: ImageConstants.reports,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.settings,
      label: 'Settings',
      icon: ImageConstants.investors,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.adminUsers,
      label: 'Admin Users',
      icon: ImageConstants.investors,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animate
          ? const Duration(milliseconds: 220)
          : Duration.zero,
      curve: Curves.easeInOut,
      width: collapsed ? collapsedWidth : sidebarWidth,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showLabels = constraints.maxWidth >= _labelRevealWidth;
          final horizontalPad = showLabels ? 14.0 : 10.0;

          return SafeArea(
            right: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalPad, 18, horizontalPad, 16),
              child: Column(
                crossAxisAlignment: showLabels
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (showLabels)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Image.asset(
                        ImageConstants.logo,
                        height: 36,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ),
                    )
                  else
                    Tooltip(
                      message: 'Maribel Wellness Centre',
                      child: Image.asset(
                        ImageConstants.logo,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _destinations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final destination = _destinations[index];

                        return _DrawerNavTile(
                          icon: destination.icon,
                          label: destination.label,
                          isSelected: destination.item == selectedItem,
                          showLabel: showLabels,
                          onTap: () => onItemSelected(destination.item),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AppVersionLabel(showFullLabel: showLabels),
                  _DrawerNavTile(
                    icon: ImageConstants.logout,
                    label: 'Logout',
                    isSelected: false,
                    showLabel: showLabels,
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DrawerDestination {
  const _DrawerDestination({
    required this.item,
    required this.label,
    required this.icon,
  });

  final AdminDrawerItem item;
  final String label;
  final String icon;
}

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel({required this.showFullLabel});

  final bool showFullLabel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        if (version == null || version.isEmpty) {
          return const SizedBox(height: 8);
        }

        final fullText = 'version $version';

        if (showFullLabel) {
          return Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 8),
            child: Text(
              fullText,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Tooltip(
            message: fullText,
            child: Text(
              'v$version',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.showLabel,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.textPrimary : AppColors.textMuted;

    final tile = Material(
      color: isSelected ? AppColors.cardBg : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 12 : 0,
            vertical: 11,
          ),
          child: Row(
            mainAxisAlignment:
                showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              if (showLabel) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (showLabel) return tile;

    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 400),
      child: tile,
    );
  }
}
