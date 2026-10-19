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
  reports,
  manageUsers,
  duePayments,
  pendingRequests,
  settings,
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
      label: 'Payments',
      icon: ImageConstants.addPayment,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.workProgress,
      label: 'Work Progress',
      icon: ImageConstants.workProgress,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.reports,
      label: 'Reports',
      icon: ImageConstants.reports,
    ),
    _DrawerDestination(
      item: AdminDrawerItem.pendingRequests,
      label: 'Pending Requests',
      icon: ImageConstants.documents,
    ),
    _DrawerDestination(
      label: 'User Management',
      icon: ImageConstants.username,
      children: [
        _DrawerDestination(
          item: AdminDrawerItem.manageUsers,
          label: 'Manage Users',
          icon: ImageConstants.investors,
        ),
        _DrawerDestination(
          item: AdminDrawerItem.duePayments,
          label: 'Due Payments',
          icon: ImageConstants.addPayment,
        ),
      ],
    ),
    _DrawerDestination(
      item: AdminDrawerItem.settings,
      label: 'Settings',
      icon: ImageConstants.createUpdates,
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
                      child: SvgPicture.asset(
                        ImageConstants.Meribel,
                        height: 70,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
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
                  const SizedBox(height: 35),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _destinations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final destination = _destinations[index];
                        if (destination.isGroup) {
                          return _ExpandableDrawerGroup(
                            destination: destination,
                            selectedItem: selectedItem,
                            showLabel: showLabels,
                            onItemSelected: onItemSelected,
                          );
                        }

                        return _DrawerNavTile(
                          icon: destination.icon,
                          label: destination.label,
                          isSelected: destination.item == selectedItem,
                          showLabel: showLabels,
                          onTap: () => onItemSelected(destination.item!),
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
    this.item,
    required this.label,
    required this.icon,
    this.children = const [],
  });

  final AdminDrawerItem? item;
  final String label;
  final String icon;
  final List<_DrawerDestination> children;

  bool get isGroup => children.isNotEmpty;
}

class _ExpandableDrawerGroup extends StatefulWidget {
  const _ExpandableDrawerGroup({
    required this.destination,
    required this.selectedItem,
    required this.showLabel,
    required this.onItemSelected,
  });

  final _DrawerDestination destination;
  final AdminDrawerItem selectedItem;
  final bool showLabel;
  final ValueChanged<AdminDrawerItem> onItemSelected;

  @override
  State<_ExpandableDrawerGroup> createState() => _ExpandableDrawerGroupState();
}

class _ExpandableDrawerGroupState extends State<_ExpandableDrawerGroup> {
  late bool _expanded = _isChildSelected;

  bool get _isChildSelected => widget.destination.children.any(
        (child) => child.item == widget.selectedItem,
      );

  @override
  void didUpdateWidget(covariant _ExpandableDrawerGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isChildSelected && !_expanded) {
      _expanded = true;
    }
  }

  Future<void> _showCollapsedMenu() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final offset = box.localToGlobal(Offset.zero);
    final selected = await showMenu<AdminDrawerItem>(
      context: context,
      color: AppColors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      position: RelativeRect.fromLTRB(
        offset.dx + box.size.width + 8,
        offset.dy,
        offset.dx + box.size.width + 180,
        offset.dy + box.size.height,
      ),
      items: [
        for (final child in widget.destination.children)
          if (child.item != null)
            PopupMenuItem<AdminDrawerItem>(
              value: child.item,
              child: Text(
                child.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: child.item == widget.selectedItem
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
      ],
    );

    if (selected != null) {
      widget.onItemSelected(selected);
    }
  }

  void _onParentTap() {
    if (!widget.showLabel) {
      _showCollapsedMenu();
      return;
    }
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final parentTile = _DrawerNavTile(
      icon: widget.destination.icon,
      label: widget.destination.label,
      isSelected: _isChildSelected,
      showLabel: widget.showLabel,
      trailing: widget.showLabel
          ? AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: _isChildSelected
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            )
          : null,
      onTap: _onParentTap,
    );

    if (!widget.showLabel || !_expanded) {
      return parentTile;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        parentTile,
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            children: [
              for (final child in widget.destination.children) ...[
                _DrawerNavTile(
                  icon: child.icon,
                  label: child.label,
                  isSelected: child.item == widget.selectedItem,
                  showLabel: true,
                  compact: true,
                  onTap: () {
                    if (child.item != null) {
                      widget.onItemSelected(child.item!);
                    }
                  },
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ],
    );
  }
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
    this.trailing,
    this.compact = false,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.textPrimary : AppColors.textMuted;
    final iconSize = compact ? 20.0 : 24.0;

    final tile = Material(
      color: isSelected ? AppColors.cardBg : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 12 : 0,
            vertical: compact ? 8 : 11,
          ),
          child: Row(
            mainAxisAlignment:
                showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: iconSize,
                height: iconSize,
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
                      fontSize: compact ? 10.5.sp : 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
                ?trailing,
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
