import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class DashboardActivitySection extends StatelessWidget {
  const DashboardActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        if (isNarrow) {
          return const Column(
            children: [
              _RecentPaymentsCard(),
              SizedBox(height: 14),
              _RecentUpdatesCard(),
              SizedBox(height: 14),
              _QuickActionsCard(),
            ],
          );
        }

        return const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _RecentPaymentsCard()),
              SizedBox(width: 14),
              Expanded(child: _RecentUpdatesCard()),
              SizedBox(width: 14),
              Expanded(child: _QuickActionsCard()),
            ],
          ),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction ?? () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.accent,
            ),
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentPaymentsCard extends StatelessWidget {
  const _RecentPaymentsCard();

  static const List<_PaymentItem> _payments = [
    _PaymentItem(name: 'Corey Herwitz', date: '03 Jun, 2026', amount: '2,00,00,00'),
    _PaymentItem(name: 'Alfredo Curtis', date: '03 Jun, 2026', amount: '2,00,00,00'),
    _PaymentItem(name: 'Talan Baptista', date: '03 Jun, 2026', amount: '2,00,00,00'),
    _PaymentItem(name: 'Alfonso Herwitz', date: '03 Jun, 2026', amount: '2,00,00,00'),
    _PaymentItem(name: 'Terry Rosser', date: '03 Jun, 2026', amount: '2,00,00,00'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Recent Payments',
            actionLabel: 'View All',
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _payments.length; i++) ...[
            _PaymentRow(item: _payments[i]),
            if (i < _payments.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _PaymentItem {
  const _PaymentItem({
    required this.name,
    required this.date,
    required this.amount,
  });

  final String name;
  final String date;
  final String amount;
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.item});

  final _PaymentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.cardBg,
            child: Text(
              item.name.isNotEmpty ? item.name[0] : '?',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Received',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.amount,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentUpdatesCard extends StatelessWidget {
  const _RecentUpdatesCard();

  static const List<_UpdateItem> _updates = [
    _UpdateItem(
      title: '2nd Floor Construction Completed Successfully',
      date: '03 Jun, 2026',
      icon: Icons.apartment_outlined,
      color: Color(0xFF5B8DEF),
    ),
    _UpdateItem(
      title: '2nd Floor Construction Completed Successfully',
      date: '03 Jun, 2026',
      icon: Icons.construction_outlined,
      color: Color(0xFFE89A3C),
    ),
    _UpdateItem(
      title: '2nd Floor Construction Completed Successfully',
      date: '03 Jun, 2026',
      icon: Icons.groups_outlined,
      color: Color(0xFF3CB371),
    ),
    _UpdateItem(
      title: '2nd Floor Construction Completed Successfully',
      date: '03 Jun, 2026',
      icon: Icons.home_work_outlined,
      color: Color(0xFF9B7EBF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Recent Updates',
            actionLabel: 'View All',
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _updates.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _UpdateRow(item: _updates[i]),
          ],
        ],
      ),
    );
  }
}

class _UpdateItem {
  const _UpdateItem({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String title;
  final String date;
  final IconData icon;
  final Color color;
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.item});

  final _UpdateItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: item.color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  static const List<_QuickActionItem> _actions = [
    _QuickActionItem(
      label: 'Add Investor',
      icon: ImageConstants.investors,
      color: AppColors.accent,
      destination: AdminDrawerItem.investors,
    ),
    _QuickActionItem(
      label: 'Add Payment',
      icon: ImageConstants.addPayment,
      color: Color(0xFF2CB5A8),
      destination: AdminDrawerItem.fundingPayments,
    ),
    _QuickActionItem(
      label: 'Upload Photo',
      icon: ImageConstants.uploadPhoto,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.photosVideos,
    ),
    _QuickActionItem(
      label: 'Upload Video',
      icon: ImageConstants.uploadVideo,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.photosVideos,
    ),
    _QuickActionItem(
      label: 'Create Updates',
      icon: ImageConstants.createUpdates,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.updatesStatus,
    ),
    _QuickActionItem(
      label: 'Sent Notification',
      icon: ImageConstants.notification,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _QuickActionTile(item: _actions[i])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 3; i < 6; i++) ...[
                if (i > 3) const SizedBox(width: 12),
                Expanded(child: _QuickActionTile(item: _actions[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.destination,
  });

  final String label;
  final String icon;
  final Color color;
  final AdminDrawerItem destination;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            AdminNavigateNotification(item.destination).dispatch(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.color.withValues(alpha: 0.45)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  item.icon,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
