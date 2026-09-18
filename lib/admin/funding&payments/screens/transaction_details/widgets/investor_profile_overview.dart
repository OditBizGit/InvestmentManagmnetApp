import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class InvestorProfileOverview extends StatelessWidget {
  const InvestorProfileOverview({
    super.key,
    this.onDownloadStatement,
    this.onRecordPayment,
  });

  final VoidCallback? onDownloadStatement;
  final VoidCallback? onRecordPayment;

  static const List<_ProfileStatCardData> _stats = [
    _ProfileStatCardData(
      label: 'Total Committed Investment',
      value: '₹1,20,00,000',
      icon: ImageConstants.totalFunding,
      iconColor: Color(0xFF9B7EBF),
      iconBg: Color(0xFFF0EBF6),
      badgeLabel: '3 Active Phases',
      badgeColor: Color(0xFF5B8DEF),
      badgeBg: Color(0xFFEAF1FC),
    ),
    _ProfileStatCardData(
      label: 'Total Paid Amount',
      value: '₹80,00,000',
      icon: ImageConstants.amountReceivable,
      iconColor: Color(0xFF2CB5A8),
      iconBg: Color(0xFFE6F7F5),
      badgeLabel: 'Paid 66.7%',
      badgeColor: Color(0xFF1BA752),
      badgeBg: Color(0xFFE6F6EC),
    ),
    _ProfileStatCardData(
      label: 'Pending Balance',
      value: '₹40,00,000',
      icon: ImageConstants.amountRemaining,
      iconColor: Color(0xFFE06B7A),
      iconBg: Color(0xFFFDECEE),
      badgeLabel: 'Next Due: 15 Jun, 2026',
      badgeColor: Color(0xFFE06B7A),
      badgeBg: Color(0xFFFDECEE),
    ),
    _ProfileStatCardData(
      label: 'Last Payment (03 Jun, 2026)',
      value: '₹20,00,000',
      icon: ImageConstants.reports,
      iconColor: Color(0xFF5B8DEF),
      iconBg: Color(0xFFEAF1FC),
      badgeLabel: 'Completed',
      badgeColor: Color(0xFF1BA752),
      badgeBg: Color(0xFFE6F6EC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileTitleRow(
          onDownloadStatement: onDownloadStatement,
          onRecordPayment: onRecordPayment,
        ),
        const SizedBox(height: 20),
        _ProfileStatsGrid(stats: _stats),
      ],
    );
  }
}

class _ProfileTitleRow extends StatelessWidget {
  const _ProfileTitleRow({
    this.onDownloadStatement,
    this.onRecordPayment,
  });

  final VoidCallback? onDownloadStatement;
  final VoidCallback? onRecordPayment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investor Profile & History',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Overview of personal details, investment tranches, pending dues, and ledger records',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _OutlineActionButton(
              label: 'Download Statement',
              icon: Icons.cloud_download_outlined,
              onTap: onDownloadStatement,
            ),
            _FilledActionButton(
              label: 'Record New Payment',
              icon: Icons.add,
              onTap: onRecordPayment,
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 14),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.white),
              const SizedBox(width: 8),
              Text(
                label,
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
  }
}

class _ProfileStatsGrid extends StatelessWidget {
  const _ProfileStatsGrid({required this.stats});

  final List<_ProfileStatCardData> stats;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100
            ? 4
            : width >= 700
                ? 2
                : 1;

        if (columns == 4) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                Expanded(child: _ProfileStatCard(data: stats[i])),
              ],
            ],
          );
        }

        final cardWidth =
            ((width - (spacing * (columns - 1))) / columns).clamp(160.0, width);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: cardWidth,
                child: _ProfileStatCard(data: stat),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileStatCardData {
  const _ProfileStatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
  });

  final String label;
  final String value;
  final String icon;
  final Color iconColor;
  final Color iconBg;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({required this.data});

  final _ProfileStatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  data.icon,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    data.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.badgeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: data.badgeColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
