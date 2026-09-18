import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class ReportsOverviewCards extends StatelessWidget {
  const ReportsOverviewCards({
    super.key,
    this.totalFunding = '₹65,50,00,000',
    this.totalPayments = '₹28,50,00,000',
    this.totalInvestors = '124',
    this.overallProgress = '68%',
    this.dateRangeLabel = '01 Jan, 2026 - 30 Jun, 2026',
    this.onDateRangeTap,
    this.onExportTap,
  });

  final String totalFunding;
  final String totalPayments;
  final String totalInvestors;
  final String overallProgress;
  final String dateRangeLabel;
  final VoidCallback? onDateRangeTap;
  final VoidCallback? onExportTap;

  List<_StatCardData> get _stats => [
        _StatCardData(
          label: 'Total Funding',
          value: totalFunding,
          icon: ImageConstants.totalFunding,
          iconColor: const Color(0xFF9B7EBF),
          iconBg: const Color(0xFFF0EBF6),
        ),
        _StatCardData(
          label: 'Total Payments',
          value: totalPayments,
          icon: ImageConstants.reports,
          iconColor: const Color(0xFF5B8DEF),
          iconBg: const Color(0xFFEAF1FC),
        ),
        _StatCardData(
          label: 'Total Investors',
          value: totalInvestors,
          icon: ImageConstants.totalInvestors,
          iconColor: const Color(0xFF2CB5A8),
          iconBg: const Color(0xFFE6F7F5),
        ),
        _StatCardData(
          label: 'Overall Progress',
          value: overallProgress,
          icon: ImageConstants.workProgress,
          iconColor: const Color(0xFFE06B7A),
          iconBg: const Color(0xFFFDECEE),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportsTitleRow(
          dateRangeLabel: dateRangeLabel,
          onDateRangeTap: onDateRangeTap,
          onExportTap: onExportTap,
        ),
        const SizedBox(height: 20),
        _StatsGrid(stats: _stats),
      ],
    );
  }
}

class _ReportsTitleRow extends StatelessWidget {
  const _ReportsTitleRow({
    required this.dateRangeLabel,
    this.onDateRangeTap,
    this.onExportTap,
  });

  final String dateRangeLabel;
  final VoidCallback? onDateRangeTap;
  final VoidCallback? onExportTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View and analyze funding, payments, investors and work progress reports',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _DateRangeButton(
              label: dateRangeLabel,
              onTap: onDateRangeTap,
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

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({
    required this.label,
    this.onTap,
  });

  final String label;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ImageConstants.calender,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.accent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 4
            : width >= 560
                ? 2
                : 1;

        if (columns == 4) {
          return Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                Expanded(child: _SummaryCard(data: stats[i])),
              ],
            ],
          );
        }

        final cardWidth =
            ((width - (spacing * (columns - 1))) / columns).clamp(140.0, width);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: cardWidth,
                child: _SummaryCard(data: stat),
              ),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
