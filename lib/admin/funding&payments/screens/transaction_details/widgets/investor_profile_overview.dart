import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class InvestorProfileOverview extends StatelessWidget {
  const InvestorProfileOverview({
    super.key,
    required this.details,
    required this.formatCurrency,
    required this.formatDate,
  });

  final InvestorDetailsModel details;
  final String Function(double amount) formatCurrency;
  final String Function(DateTime? date) formatDate;

  List<_ProfileStatCardData> get _stats {
    final committed = details.investmentAmount;
    final paid = details.totalPaidAmount;
    final pending = details.totalPendingAmount;
    final paidPercent = committed > 0 ? (paid / committed) * 100 : 0.0;

    InvestorDueDateModel? nextDue;
    for (final due in details.dueDates) {
      final status = due.status.toLowerCase();
      if (status.contains('pending') ||
          status.contains('due') ||
          status.contains('schedul')) {
        nextDue = due;
        break;
      }
    }
    nextDue ??= details.dueDates.isNotEmpty ? details.dueDates.first : null;

    final activePhases = details.dueDates
        .where((d) => !d.status.toLowerCase().contains('complete'))
        .length;

    return [
      _ProfileStatCardData(
        label: 'Total Committed Investment',
        value: formatCurrency(committed),
        icon: ImageConstants.totalFunding,
        iconColor: const Color(0xFF9B7EBF),
        iconBg: const Color(0xFFF0EBF6),
        badgeLabel: activePhases > 0
            ? '$activePhases Active Phase${activePhases == 1 ? '' : 's'}'
            : 'No active phases',
        badgeColor: const Color(0xFF5B8DEF),
        badgeBg: const Color(0xFFEAF1FC),
      ),
      _ProfileStatCardData(
        label: 'Total Paid Amount',
        value: formatCurrency(paid),
        icon: ImageConstants.amountReceivable,
        iconColor: const Color(0xFF2CB5A8),
        iconBg: const Color(0xFFE6F7F5),
        badgeLabel: 'Paid ${paidPercent.toStringAsFixed(1)}%',
        badgeColor: const Color(0xFF1BA752),
        badgeBg: const Color(0xFFE6F6EC),
      ),
      _ProfileStatCardData(
        label: 'Pending Balance',
        value: formatCurrency(pending),
        icon: ImageConstants.amountRemaining,
        iconColor: const Color(0xFFE06B7A),
        iconBg: const Color(0xFFFDECEE),
        badgeLabel: nextDue?.dueDate != null
            ? 'Next Due: ${formatDate(nextDue!.dueDate)}'
            : 'No upcoming due',
        badgeColor: const Color(0xFFE06B7A),
        badgeBg: const Color(0xFFFDECEE),
      ),
      _ProfileStatCardData(
        label: details.lastPaymentDate != null
            ? 'Last Payment (${formatDate(details.lastPaymentDate)})'
            : 'Last Payment',
        value: formatCurrency(details.lastPaymentAmount),
        icon: ImageConstants.reports,
        iconColor: const Color(0xFF5B8DEF),
        iconBg: const Color(0xFFEAF1FC),
        badgeLabel: details.lastPaymentAmount > 0 ? 'Completed' : 'No payment',
        badgeColor: const Color(0xFF1BA752),
        badgeBg: const Color(0xFFE6F6EC),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const _ProfileTitleRow(
        ),
        const SizedBox(height: 20),
        _ProfileStatsGrid(stats: _stats),
      ],
    );
  }
}

class _ProfileTitleRow extends StatelessWidget {
  const _ProfileTitleRow();

  @override
  Widget build(BuildContext context) {
    return Column(
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
