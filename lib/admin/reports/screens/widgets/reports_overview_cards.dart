import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/reports/cubit/report__cubit.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class ReportsOverviewCards extends StatelessWidget {
  const ReportsOverviewCards({
    super.key,
    this.onExportTap,
  });

  final VoidCallback? onExportTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      buildWhen: (previous, current) =>
          previous.fundingOverviewLoading != current.fundingOverviewLoading ||
          previous.fundingOverviewError != current.fundingOverviewError ||
          previous.fundingOverview != current.fundingOverview,
      builder: (context, state) {
        final summary = state.fundingOverviewSummary;
        final isLoading =
            state.fundingOverviewLoading && state.fundingOverview == null;

        final stats = [
          _StatCardData(
            label: 'Total Project Investment',
            value: isLoading
                ? '—'
                : CurrencyFormatter.format(summary?.projectAmount ?? 0),
            icon: ImageConstants.totalFunding,
            iconColor: const Color(0xFF9B7EBF),
            iconBg: const Color(0xFFF0EBF6),
          ),
          _StatCardData(
            label: 'Total Investment By Investors',
            value: isLoading
                ? '—'
                : CurrencyFormatter.format(
                    summary?.totalInvestmentAmount ?? 0,
                  ),
            icon: ImageConstants.reports,
            iconColor: const Color(0xFF5B8DEF),
            iconBg: const Color(0xFFEAF1FC),
          ),
          _StatCardData(
            label: 'Total Amount Received',
            value: isLoading
                ? '—'
                : CurrencyFormatter.format(summary?.totalPaidAmount ?? 0),
            icon: ImageConstants.totalInvestors,
            iconColor: const Color(0xFF2CB5A8),
            iconBg: const Color(0xFFE6F7F5),
          ),
          _StatCardData(
            label: 'Total Pending Amount',
            value: isLoading
                ? '—'
                : CurrencyFormatter.format(summary?.totalPendingAmount ?? 0),
            icon: ImageConstants.workProgress,
            iconColor: const Color(0xFFE06B7A),
            iconBg: const Color(0xFFFDECEE),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _StatsGrid(stats: stats),
          ],
        );
      },
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
