import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
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

class AdminSideDrawer extends StatelessWidget {
  const AdminSideDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onLogout,
  });

  final AdminDrawerItem selectedItem;
  final ValueChanged<AdminDrawerItem> onItemSelected;
  final VoidCallback onLogout;

  static const double sidebarWidth = 248;

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
    return Container(
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Image.asset(
                  ImageConstants.logo,
                  height: 36,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
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
                      onTap: () => onItemSelected(destination.item),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              _DrawerNavTile(
                icon: ImageConstants.investors,
                label: 'Logout',
                isSelected: false,
                onTap: onLogout,
              ),
            ],
          ),
        ),
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

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.textPrimary : AppColors.textMuted;

    return Material(
      color: isSelected ? AppColors.cardBg : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
