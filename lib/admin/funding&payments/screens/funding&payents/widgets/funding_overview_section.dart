import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/funding_investor_list_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class FundingOverviewSection extends StatelessWidget {
  const FundingOverviewSection({
    super.key,
    this.transactions = const [],
    this.onAddFunding,
  });

  final List<FundingInvestorModel> transactions;
  final VoidCallback? onAddFunding;

  List<_StatCardData> get _stats {
    final totalFunding = transactions
        .map((e) => e.totalInvestmentAmount)
        .fold<double>(0, (sum, value) => sum + value);
    final amountReceived = transactions
        .map((e) => e.totalPaidAmount)
        .fold<double>(0, (sum, value) => sum + value);
    final amountPending = transactions
        .map((e) => e.totalPendingAmount)
        .fold<double>(0, (sum, value) => sum + value);
    final pendingFallback =
        (totalFunding - amountReceived).clamp(0.0, double.infinity).toDouble();
    final pending = amountPending > 0 ? amountPending : pendingFallback;

    return [
      _StatCardData(
        label: 'Total Funding',
        value: _formatCurrency(totalFunding),
        icon: ImageConstants.totalFunding,
        iconColor: const Color(0xFF9B7EBF),
        iconBg: const Color(0xFFF0EBF6),
      ),
      _StatCardData(
        label: 'Amount Received',
        value: _formatCurrency(amountReceived),
        icon: ImageConstants.amountReceivable,
        iconColor: const Color(0xFF2CB5A8),
        iconBg: const Color(0xFFE6F7F5),
      ),
      _StatCardData(
        label: 'Amount Pending',
        value: _formatCurrency(pending),
        icon: ImageConstants.amountRemaining,
        iconColor: const Color(0xFFE06B7A),
        iconBg: const Color(0xFFFDECEE),
      ),
      _StatCardData(
        label: 'Total Payments',
        value: '${transactions.length}',
        icon: ImageConstants.reports,
        iconColor: const Color(0xFF5B8DEF),
        iconBg: const Color(0xFFEAF1FC),
      ),
    ];
  }

  static String _formatCurrency(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw =
        isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final withCommas = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FundingTitleRow(onAddFunding: onAddFunding),
        const SizedBox(height: 20),
        _StatsGrid(stats: _stats),
      ],
    );
  }
}

class _FundingTitleRow extends StatelessWidget {
  const _FundingTitleRow({this.onAddFunding});

  final VoidCallback? onAddFunding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Funding & Payments',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track all funding, payments and transitions related to the projects',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final addFundingButton = Material(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onAddFunding,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add Funding',
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
              addFundingButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            addFundingButton,
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
      padding: const EdgeInsets.all(12),
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
              colorFilter: ColorFilter.mode(data.iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 12),
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
    );
  }
}
