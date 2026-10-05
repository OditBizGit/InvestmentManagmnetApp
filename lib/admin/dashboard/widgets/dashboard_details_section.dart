import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import '../../work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import '../cubit/dashboard_cubit.dart';
import '../model/dashboard_model.dart';
import '../model/top_investors_model.dart';
import 'dashboard_shimmer.dart';

class DashboardDetailsSection extends StatelessWidget {
  const DashboardDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.dashboardLoading &&
              !current.dashboardLoading &&
              current.dashboardError != null,
          listener: (context, state) {
            AppToast.error(state.dashboardError!, context: context);
          },
        ),
        BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.workProgressLoading && !current.workProgressLoading,
          listener: (context, state) {
            final message = state.workProgressError;
            if (message == null ||
                message == DashboardCubit.noInternetMessage) {
              return;
            }
            AppToast.error(message, context: context);
          },
        ),
        BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.topInvestorsLoading && !current.topInvestorsLoading,
          listener: (context, state) {
            final message = state.topInvestorsError;
            if (message == null ||
                message == DashboardCubit.noInternetMessage) {
              return;
            }
            AppToast.error(message, context: context);
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;

          if (isNarrow) {
            return const Column(
              children: [
                _FundingOverviewCard(),
                SizedBox(height: 14),
                _HospitalWorkProgressCard(),
                SizedBox(height: 14),
                _TopRatedInvestorsCard(),
              ],
            );
          }

          return const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FundingOverviewCard(),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _HospitalWorkProgressCard(),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _TopRatedInvestorsCard(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.child});

  /// Matches the tallest common filled layout (~title + 5 list rows).
  static const double minHeight = 420;

  /// Body area used by empty / error states so height matches 5 data rows.
  static const double listBodyHeight = 340;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: minHeight),
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

class _CardStatusBody extends StatelessWidget {
  const _CardStatusBody({
    required this.title,
    required this.message,
    this.isError = false,
  });

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _DashboardPanel.listBodyHeight,
          width: double.infinity,
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: isError ? Colors.red : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FundingOverviewCard extends StatelessWidget {
  const _FundingOverviewCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.dashboardLoading != current.dashboardLoading ||
            previous.dashboardError != current.dashboardError ||
            previous.dashboard != current.dashboard ||
            previous.dashboardLoaded != current.dashboardLoaded,
        builder: (context, state) {
          if (state.dashboardLoading) {
            return _buildLoading();
          }

          if (state.dashboardError != null) {
            return _CardStatusBody(
              title: 'Funding Overview',
              message: state.dashboardError!,
              isError: true,
            );
          }

          if (state.dashboardLoaded && state.dashboard != null) {
            return _buildContent(state.dashboard!);
          }

          if (state.dashboardLoaded) {
            return const _CardStatusBody(
              title: 'Funding Overview',
              message: 'No data found',
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const DashboardFundingOverviewShimmer();
  }

  Widget _buildContent(DashboardModel dashboard) {
    final progressPercent = _normalizePercent(dashboard.fundingProgress);
    final progressValue = (progressPercent / 100).clamp(0.0, 1.0);
    final progressLabel = progressPercent == progressPercent.roundToDouble()
        ? '${progressPercent.toStringAsFixed(0)}%'
        : '${progressPercent.toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Funding Overview',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 14,
                    backgroundColor: const Color(0xFFEDEDED),
                    color: AppColors.green,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      progressLabel,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                    Text(
                      'Of Goal',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _FundingMetricTile(
                label: 'Project Fund',
                value: _formatAmount(dashboard.projectFund),
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FundingMetricTile(
                label: 'Total Investment',
                value: _formatAmount(dashboard.totalInvestmentAmount),
                color: const Color(0xFF2CB5A8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FundingMetricTile(
                label: 'Total Received',
                value: _formatAmount(dashboard.totalReceivedAmount),
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FundingMetricTile(
                label: 'Total Pending',
                value: _formatAmount(dashboard.totalPendingAmount),
                color: const Color(0xFFE06B7A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _normalizePercent(double value) {
    if (value <= 1) return value * 100;
    return value;
  }

  String _formatAmount(double amount) {
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
}

class _FundingMetricTile extends StatelessWidget {
  const _FundingMetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalWorkProgressCard extends StatelessWidget {
  const _HospitalWorkProgressCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.workProgressLoading != current.workProgressLoading ||
            previous.workProgressError != current.workProgressError ||
            previous.workPhases != current.workPhases ||
            previous.workProgressLoaded != current.workProgressLoaded,
        builder: (context, state) {
          if (state.workProgressLoading) {
            return _buildLoading();
          }

          if (state.workProgressError != null) {
            return _CardStatusBody(
              title: 'Hospital Work Progress',
              message: state.workProgressError!,
              isError: true,
            );
          }

          if (state.workProgressLoaded) {
            return _buildContent(state.workPhases);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const DashboardWorkProgressShimmer();
  }

  Widget _buildContent(List<WorkPhaseListModel> workPhases) {
    // Fixed height so Overall Progress can sit at the bottom without
    // LayoutBuilder (incompatible with the parent IntrinsicHeight).
    return SizedBox(
      height: _DashboardPanel.minHeight - 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Work Progress',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: workPhases.isEmpty
                ? Center(
                    child: Text(
                      'No work phases available',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < workPhases.length; i++) ...[
                          if (i > 0) const SizedBox(height: 14),
                          _WorkProgressRow(
                            item: _WorkProgressItem(
                              label: workPhases[i].stageName,
                              percent: workPhases[i].progress,
                              color: _getProgressColor(
                                workPhases[i].progress,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          _buildOverallProgress(workPhases),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(
      List<WorkPhaseListModel> workPhases,
      ) {
    int overallProgress = 0;

    if (workPhases.isNotEmpty) {
      final total = workPhases.fold<int>(
        0,
            (sum, phase) => sum + (phase.progress),
      );

      overallProgress = (total / workPhases.length).round();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          const Spacer(),
          Text(
            '$overallProgress%',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) {
      return AppColors.green;
    }

    if (progress >= 50) {
      return const Color(0xFFF2C94C);
    }

    return const Color(0xFFE57373);
  }
}
class _WorkProgressItem {
  const _WorkProgressItem({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;
}

class _WorkProgressRow extends StatelessWidget {
  const _WorkProgressRow({required this.item});

  final _WorkProgressItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Text(
              '${item.percent}%',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: item.percent / 100,
            minHeight: 7,
            backgroundColor: const Color(0xFFEDEDED),
            color: item.color,
          ),
        ),
      ],
    );
  }
}

class _TopRatedInvestorsCard extends StatelessWidget {
  const _TopRatedInvestorsCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.topInvestorsLoading != current.topInvestorsLoading ||
            previous.topInvestorsError != current.topInvestorsError ||
            previous.topInvestors != current.topInvestors ||
            previous.topInvestorsLoaded != current.topInvestorsLoaded,
        builder: (context, state) {
          if (state.topInvestorsLoading) {
            return _buildLoading();
          }

          if (state.topInvestorsError != null) {
            return _CardStatusBody(
              title: 'Top Rated Investors',
              message: state.topInvestorsError!,
              isError: true,
            );
          }

          if (state.topInvestorsLoaded) {
            return _buildContent(state.topInvestors);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const DashboardTopInvestorsShimmer();
  }

  Widget _buildContent(List<TopInvestorsModel> investors) {
    final visibleInvestors = investors.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Rated Investors',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _DashboardPanel.listBodyHeight,
          ),
          child: SizedBox(
            width: double.infinity,
            child: visibleInvestors.isEmpty
                ? SizedBox(
                    height: _DashboardPanel.listBodyHeight,
                    child: Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < visibleInvestors.length; i++) ...[
                        _InvestorRow(investor: visibleInvestors[i]),
                        if (i < visibleInvestors.length - 1)
                          const Divider(height: 1, color: AppColors.border),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _InvestorRow extends StatelessWidget {
  const _InvestorRow({required this.investor});

  final TopInvestorsModel investor;

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(investor.profileImage);
    final paidPercent = _paidPercent(investor);
    final amountLabel = _formatAmount(investor.investmentAmount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.cardBg,
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    investor.fullName.isNotEmpty
                        ? investor.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investor.fullName.isNotEmpty
                      ? investor.fullName
                      : 'Unknown Investor',
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
                  'Invested',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
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
                'Paid $paidPercent%',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amountLabel,
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

  int _paidPercent(TopInvestorsModel investor) {
    if (investor.investmentAmount <= 0) return 0;
    return ((investor.totalPaidAmount / investor.investmentAmount) * 100)
        .round()
        .clamp(0, 100);
  }

  String _formatAmount(double amount) {
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
}
