import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer placeholders for dashboard cards, sized to match real layouts.
class DashboardShimmer {
  DashboardShimmer._();

  static const Color baseColor = Color(0xFFE0E0E0);
  static const Color highlightColor = Color(0xFFF5F5F5);
  static const Duration period = Duration(milliseconds: 1400);

  static Widget wrap({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: ShimmerDirection.ltr,
      period: period,
      child: child,
    );
  }

  static Widget box({
    double? width,
    double? height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Thin content line matching text-row height inside cards.
  static Widget line({
    double? width,
    double height = 10,
    double radius = 4,
  }) {
    return box(width: width, height: height, radius: radius);
  }
}

class DashboardStatsShimmer extends StatelessWidget {
  const DashboardStatsShimmer({super.key});

  static const double cardHeight = 96;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          const Expanded(child: _StatCardShimmer()),
        ],
      ],
    );
  }
}

class _StatCardShimmer extends StatelessWidget {
  const _StatCardShimmer();

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Container(
        height: DashboardStatsShimmer.cardHeight,
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
            DashboardShimmer.box(width: 28, height: 28, radius: 8),
            const SizedBox(height: 12),
            DashboardShimmer.line(width: 64, height: 9),
            const SizedBox(height: 8),
            DashboardShimmer.line(width: 78, height: 12),
          ],
        ),
      ),
    );
  }
}

class DashboardFundingOverviewShimmer extends StatelessWidget {
  const DashboardFundingOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.line(width: 120, height: 12),
          const SizedBox(height: 14),
          const Center(
            child: SizedBox(
              width: 110,
              height: 110,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: DashboardShimmer.baseColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _MetricTileShimmer()),
              SizedBox(width: 10),
              Expanded(child: _MetricTileShimmer()),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _MetricTileShimmer()),
              SizedBox(width: 10),
              Expanded(child: _MetricTileShimmer()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTileShimmer extends StatelessWidget {
  const _MetricTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DashboardShimmer.line(width: 58, height: 8),
          const SizedBox(height: 8),
          DashboardShimmer.line(width: 76, height: 11),
        ],
      ),
    );
  }
}

class DashboardWorkProgressShimmer extends StatelessWidget {
  const DashboardWorkProgressShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.line(width: 150, height: 12),
          const SizedBox(height: 14),
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            const _ProgressRowShimmer(),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              children: [
                DashboardShimmer.line(width: 90, height: 10),
                const Spacer(),
                DashboardShimmer.line(width: 36, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRowShimmer extends StatelessWidget {
  const _ProgressRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: DashboardShimmer.line(height: 9)),
              const SizedBox(width: 10),
              DashboardShimmer.line(width: 28, height: 9),
            ],
          ),
          const SizedBox(height: 6),
          DashboardShimmer.box(
            width: double.infinity,
            height: 6,
            radius: 3,
          ),
        ],
      ),
    );
  }
}

class DashboardTopInvestorsShimmer extends StatelessWidget {
  const DashboardTopInvestorsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.line(width: 140, height: 12),
          const SizedBox(height: 8),
          for (var i = 0; i < 5; i++) ...[
            const _InvestorRowShimmer(),
            if (i < 4) const Divider(height: 1, color: Color(0xFFEDEDED)),
          ],
        ],
      ),
    );
  }
}

class _InvestorRowShimmer extends StatelessWidget {
  const _InvestorRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: DashboardShimmer.baseColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardShimmer.line(width: 96, height: 9),
                const SizedBox(height: 5),
                DashboardShimmer.line(width: 48, height: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DashboardShimmer.line(width: 44, height: 8),
              const SizedBox(height: 5),
              DashboardShimmer.line(width: 60, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardRecentPaymentsShimmer extends StatelessWidget {
  const DashboardRecentPaymentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.line(width: 120, height: 12),
          const SizedBox(height: 8),
          for (var i = 0; i < 5; i++) ...[
            const _PaymentRowShimmer(),
            if (i < 4) const Divider(height: 1, color: Color(0xFFEDEDED)),
          ],
        ],
      ),
    );
  }
}

class _PaymentRowShimmer extends StatelessWidget {
  const _PaymentRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: DashboardShimmer.baseColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardShimmer.line(width: 104, height: 9),
                const SizedBox(height: 5),
                DashboardShimmer.line(width: 68, height: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DashboardShimmer.line(width: 58, height: 11),
        ],
      ),
    );
  }
}

class DashboardRecentUpdatesShimmer extends StatelessWidget {
  const DashboardRecentUpdatesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.line(width: 110, height: 12),
          const SizedBox(height: 8),
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            const _UpdateRowShimmer(),
          ],
        ],
      ),
    );
  }
}

class _UpdateRowShimmer extends StatelessWidget {
  const _UpdateRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.box(width: 40, height: 40, radius: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardShimmer.line(width: double.infinity, height: 9),
                const SizedBox(height: 5),
                DashboardShimmer.line(width: 120, height: 9),
                const SizedBox(height: 6),
                DashboardShimmer.line(width: 72, height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full dashboard body shimmer used when the whole page should load together.
class DashboardPageShimmer extends StatelessWidget {
  const DashboardPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardShimmer.wrap(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardShimmer.line(width: 120, height: 16),
                  const SizedBox(height: 6),
                  DashboardShimmer.line(
                    width: constraints.maxWidth * 0.5,
                    height: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const DashboardStatsShimmer(),
            const SizedBox(height: 16),
            if (isNarrow) ...[
              const _PanelShimmer(child: DashboardFundingOverviewShimmer()),
              const SizedBox(height: 12),
              const _PanelShimmer(child: DashboardWorkProgressShimmer()),
              const SizedBox(height: 12),
              const _PanelShimmer(child: DashboardTopInvestorsShimmer()),
              const SizedBox(height: 16),
              const _PanelShimmer(child: DashboardRecentPaymentsShimmer()),
              const SizedBox(height: 12),
              const _PanelShimmer(child: DashboardRecentUpdatesShimmer()),
              const SizedBox(height: 12),
              const _PanelShimmer(child: _QuickActionsShimmer()),
            ] else ...[
              const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PanelShimmer(
                        child: DashboardFundingOverviewShimmer(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PanelShimmer(
                        child: DashboardWorkProgressShimmer(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PanelShimmer(
                        child: DashboardTopInvestorsShimmer(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PanelShimmer(
                        child: DashboardRecentPaymentsShimmer(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PanelShimmer(
                        child: DashboardRecentUpdatesShimmer(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PanelShimmer(child: _QuickActionsShimmer()),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PanelShimmer extends StatelessWidget {
  const _PanelShimmer({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _QuickActionsShimmer extends StatelessWidget {
  const _QuickActionsShimmer();

  @override
  Widget build(BuildContext context) {
    return DashboardShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShimmer.line(width: 100, height: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEDEDED)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DashboardShimmer.box(width: 22, height: 22, radius: 6),
                        const SizedBox(height: 8),
                        DashboardShimmer.line(width: 48, height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
