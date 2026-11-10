import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/cubit/dashboard_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/model/dashboard_model.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_activity_section.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_shimmer.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DashboardTitleRow(),
        const SizedBox(height: 16),
        const _DashboardDateRangeFilter(),
        const SizedBox(height: 24),
        BlocBuilder<DashboardCubit, DashboardState>(
          buildWhen: (previous, current) =>
              previous.dashboardLoading != current.dashboardLoading ||
              previous.dashboardError != current.dashboardError ||
              previous.dashboard != current.dashboard ||
              previous.dashboardLoaded != current.dashboardLoaded,
          builder: (context, state) {
            if (state.dashboardLoading) {
              return const DashboardStatsShimmer();
            }

            if (state.dashboardError != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  state.dashboardError!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.red,
                  ),
                ),
              );
            }

            final dashboard = state.dashboard;
            if (dashboard == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No data found',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }

            return _StatsGrid(stats: _buildStats(dashboard));
          },
        ),
        const SizedBox(height: 20),
        const DashboardDetailsSection(),
        const SizedBox(height: 20),
        const DashboardActivitySection(),
      ],
    );
  }

  List<_StatCardData> _buildStats(DashboardModel dashboard) {
    final investorsCount = '${dashboard.totalInvestors}';

    return [
      _StatCardData(
        label: 'Total Funding',
        value: _formatAmount(dashboard.projectFund),
        icon: ImageConstants.totalFunding,
        iconColor: const Color(0xFF9B7EBF),
        iconBg: const Color(0xFFF0EBF6),
      ),
      _StatCardData(
        label: 'Amount Received',
        value: _formatAmount(dashboard.totalReceivedAmount),
        icon: ImageConstants.amountReceivable,
        iconColor: const Color(0xFF2CB5A8),
        iconBg: const Color(0xFFE6F7F5),
      ),
      _StatCardData(
        label: 'Amount Remaining',
        value: _formatAmount(dashboard.totalPendingAmount),
        icon: ImageConstants.amountRemaining,
        iconColor: const Color(0xFFE06B7A),
        iconBg: const Color(0xFFFDECEE),
      ),
      _StatCardData(
        label: 'Total Investors',
        value: investorsCount,
        icon: ImageConstants.totalInvestors,
        iconColor: const Color(0xFFE89A3C),
        iconBg: const Color(0xFFFFF3E8),
      ),
      _StatCardData(
        label: 'Active Investors',
        value: investorsCount,
        icon: ImageConstants.activeInvestors,
        iconColor: const Color(0xFF3CB371),
        iconBg: const Color(0xFFE8F8EF),
      ),
      _StatCardData(
        label: 'Funding Progress',
        value: _formatPercent(dashboard.fundingProgress),
        icon: ImageConstants.investment,
        iconColor: const Color(0xFF4A90D9),
        iconBg: const Color(0xFFE8F1FB),
      ),
    ];
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

  String _formatPercent(double value) {
    final isWhole = value == value.roundToDouble();
    final raw = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$raw%';
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

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

  @override
  Widget build(BuildContext context) {
    return Column(
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
  }
}

class _DashboardDateRangeFilter extends StatefulWidget {
  const _DashboardDateRangeFilter();

  @override
  State<_DashboardDateRangeFilter> createState() =>
      _DashboardDateRangeFilterState();
}

class _DashboardDateRangeFilterState extends State<_DashboardDateRangeFilter> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final state = context.read<DashboardCubit>().state;
    _fromDate = state.fromDate;
    _toDate = state.toDate;
  }

  String _formatPickerDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (!mounted || picked == null) return;
    setState(() {
      final dateOnly = DateTime(picked.year, picked.month, picked.day);
      if (isFrom) {
        _fromDate = dateOnly;
      } else {
        _toDate = dateOnly;
      }
    });
  }

  Future<void> _apply() async {
    if (_toDate.isBefore(_fromDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('To date cannot be earlier than from date'),
        ),
      );
      return;
    }

    await context.read<DashboardCubit>().applyDateRange(
          fromDate: _fromDate,
          toDate: _toDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardCubit, DashboardState>(
      listenWhen: (previous, current) =>
          previous.fromDate != current.fromDate ||
          previous.toDate != current.toDate,
      listener: (context, state) {
        setState(() {
          _fromDate = state.fromDate;
          _toDate = state.toDate;
        });
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.dashboardLoading != current.dashboardLoading,
        builder: (context, state) {
          final isBusy = state.dashboardLoading;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stack = constraints.maxWidth < 520;

                final dates = Row(
                  children: [
                    Expanded(
                      child: _DashboardDateField(
                        label: 'From',
                        value: _formatPickerDate(_fromDate),
                        onTap: isBusy ? null : () => _pickDate(isFrom: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardDateField(
                        label: 'To',
                        value: _formatPickerDate(_toDate),
                        onTap: isBusy ? null : () => _pickDate(isFrom: false),
                      ),
                    ),
                  ],
                );

                final apply = FilledButton(
                  onPressed: isBusy ? null : _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );

                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      dates,
                      const SizedBox(height: 12),
                      Align(alignment: Alignment.centerRight, child: apply),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: dates),
                    const SizedBox(width: 12),
                    apply,
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DashboardDateField extends StatelessWidget {
  const _DashboardDateField({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: AppColors.screenBg,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
