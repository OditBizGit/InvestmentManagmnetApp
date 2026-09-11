import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_activity_section.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_details_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  static const List<_StatCardData> _stats = [
    _StatCardData(
      label: 'Total Funding',
      value: '25 Core',
      icon: ImageConstants.totalFunding,
      iconColor: Color(0xFF9B7EBF),
      iconBg: Color(0xFFF0EBF6),
    ),
    _StatCardData(
      label: 'Amount Received',
      value: '₹85,0000',
      icon: ImageConstants.amountReceivable,
      iconColor: Color(0xFF2CB5A8),
      iconBg: Color(0xFFE6F7F5),
    ),
    _StatCardData(
      label: 'Amount Remaining',
      value: '₹2,500,000',
      icon: ImageConstants.amountRemaining,
      iconColor: Color(0xFFE06B7A),
      iconBg: Color(0xFFFDECEE),
    ),
    _StatCardData(
      label: 'Total Investors',
      value: '124',
      icon: ImageConstants.totalInvestors,
      iconColor: Color(0xFFE89A3C),
      iconBg: Color(0xFFFFF3E8),
    ),
    _StatCardData(
      label: 'Active Investors',
      value: '92',
      icon: ImageConstants.activeInvestors,
      iconColor: Color(0xFF3CB371),
      iconBg: Color(0xFFE8F8EF),
    ),
    _StatCardData(
      label: 'Funding Progress',
      value: '25%',
      icon: ImageConstants.investment,
      iconColor: Color(0xFF4A90D9),
      iconBg: Color(0xFFE8F1FB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DashboardTitleRow(),
        const SizedBox(height: 24),
        _StatsGrid(stats: _stats),
        const SizedBox(height: 20),
        const DashboardDetailsSection(),
        const SizedBox(height: 20),
        const DashboardActivitySection(),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    // Always keep all six cards in a single row; they shrink with available width.
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: spacing),
          Expanded(child: _SummaryCard(data: stats[i])),
        ],
      ],
    );
  }
}

class _DashboardTitleRow extends StatelessWidget {
  const _DashboardTitleRow();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatToday() {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage all investors and data that appears on the admin pannel',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final dateButton = Material(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatToday(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              dateButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            dateButton,
          ],
        );
      },
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final String icon;
  final Color iconColor;
  final Color iconBg;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              data.icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(data.iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
