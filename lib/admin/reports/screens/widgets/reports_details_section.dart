import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/reports/model/funding_payment_overview_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/model/investor_type_count_model.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/model/work_phase_list_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import '../../cubit/report__cubit.dart';

class ReportsDetailsSection extends StatelessWidget {
  const ReportsDetailsSection({
    super.key,
    this.onViewWorkProgressDetails,
    this.onViewAllInvestors,
  });

  final VoidCallback? onViewWorkProgressDetails;
  final VoidCallback? onViewAllInvestors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FundingPaymentsOverviewCard(),
            const SizedBox(height: 16),
            if (isWide)
              SizedBox(
                height: 460,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _WorkProgressReportCard(
                        onViewDetails: onViewWorkProgressDetails,
                        fillHeight: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InvestorSummaryCard(
                        onViewAll: onViewAllInvestors,
                        fillHeight: true,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _WorkProgressReportCard(
                onViewDetails: onViewWorkProgressDetails,
              ),
              const SizedBox(height: 16),
              _InvestorSummaryCard(
                onViewAll: onViewAllInvestors,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.child,
    this.fillHeight = false,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final bool fillHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: fillHeight ? double.infinity : null,
      padding: padding,
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

// ---------------------------------------------------------------------------
// Funding & Payments Overview
// ---------------------------------------------------------------------------

class _FundingPaymentsOverviewCard extends StatefulWidget {
  const _FundingPaymentsOverviewCard();

  @override
  State<_FundingPaymentsOverviewCard> createState() =>
      _FundingPaymentsOverviewCardState();
}

class _FundingPaymentsOverviewCardState
    extends State<_FundingPaymentsOverviewCard> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = DateTime(now.year, now.month - 5, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchOverview();
    });
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  String _apiDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static const int _maxRangeMonths = 12;

  DateTime _shiftMonths(DateTime date, int months) {
    final totalMonths = date.year * 12 + (date.month - 1) + months;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }

  bool _isWithinTwelveMonths(DateTime from, DateTime to) {
    final maxTo = _shiftMonths(from, _maxRangeMonths);
    return !to.isAfter(maxTo);
  }

  void _fetchOverview() {
    context.read<ReportCubit>().fetchFundingPaymentOverview(
          fromDate: _apiDate(_fromDate),
          toDate: _apiDate(_toDate),
        );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    // Calendar is limited so From–To span is at most 12 months.
    final DateTime firstDate;
    final DateTime lastDate;
    if (isFrom) {
      firstDate = _shiftMonths(_toDate, -_maxRangeMonths);
      lastDate = _toDate;
    } else {
      firstDate = _fromDate;
      lastDate = _shiftMonths(_fromDate, _maxRangeMonths);
    }

    var initial = isFrom ? _fromDate : _toDate;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isFrom
          ? 'Select from date (max 12 months range)'
          : 'Select to date (max 12 months range)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;

    var nextFrom = _fromDate;
    var nextTo = _toDate;

    if (isFrom) {
      nextFrom = picked;
      if (nextTo.isBefore(nextFrom)) {
        nextTo = nextFrom;
      } else if (!_isWithinTwelveMonths(nextFrom, nextTo)) {
        nextTo = _shiftMonths(nextFrom, _maxRangeMonths);
        AppToast.info(
          'Date range limited to 12 months',
          title: 'Funding & Payments Overview',
          context: context,
        );
      }
    } else {
      nextTo = picked;
      if (nextTo.isBefore(nextFrom)) {
        nextFrom = nextTo;
      } else if (!_isWithinTwelveMonths(nextFrom, nextTo)) {
        nextFrom = _shiftMonths(nextTo, -_maxRangeMonths);
        AppToast.info(
          'Date range limited to 12 months',
          title: 'Funding & Payments Overview',
          context: context,
        );
      }
    }

    setState(() {
      _fromDate = nextFrom;
      _toDate = nextTo;
    });
    _fetchOverview();
  }

  String _monthLabel(FundingPaymentMonthModel item) {
    final month = item.month.trim();
    if (month.isNotEmpty) return month;
    final parsed = DateTime.tryParse(item.monthDate);
    if (parsed == null) return '-';
    const months = [
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
    return '${months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 640;
              final title = Text(
                'Funding & Payments Overview',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              );
              final legend = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(
                    color: Color(0xFFA28CC1),
                    label: 'Funding Received',
                  ),
                  SizedBox(width: 16),
                  _LegendDot(
                    color: Color(0xFF9EC5F0),
                    label: 'Pending Amount',
                  ),
                ],
              );
              final dateFilters = Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ChartDateField(
                    label: 'From',
                    value: _formatDate(_fromDate),
                    onTap: () => _pickDate(isFrom: true),
                  ),
                  _ChartDateField(
                    label: 'To',
                    value: _formatDate(_toDate),
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ],
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 10),
                    dateFilters,
                    const SizedBox(height: 10),
                    legend,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: title),
                      legend,
                    ],
                  ),
                  const SizedBox(height: 12),
                  dateFilters,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: BlocBuilder<ReportCubit, ReportState>(
              buildWhen: (previous, current) =>
                  previous.fundingOverviewLoading !=
                      current.fundingOverviewLoading ||
                  previous.fundingOverviewError !=
                      current.fundingOverviewError ||
                  previous.fundingOverview != current.fundingOverview,
              builder: (context, state) {
                final monthsData = state.fundingOverviewMonths;

                if (state.fundingOverviewLoading && monthsData.isEmpty) {
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }

                final error = state.fundingOverviewError;
                if (error != null && monthsData.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _fetchOverview,
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (monthsData.isEmpty) {
                  return Center(
                    child: Text(
                      'No data found',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                final months = monthsData.map(_monthLabel).toList();
                final funding = monthsData
                    .map((item) => item.fundingReceived)
                    .toList();
                final payments = monthsData
                    .map((item) => item.pendingAmount)
                    .toList();
                final maxY = [
                  ...funding,
                  ...payments,
                ].fold<double>(0, (max, value) => value > max ? value : max);

                return _GroupedBarLineChart(
                  months: months,
                  funding: funding,
                  payments: payments,
                  maxY: maxY <= 0 ? 1 : maxY * 1.18,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartDateField extends StatelessWidget {
  const _ChartDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    ImageConstants.calender,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textMuted,
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _GroupedBarLineChart extends StatelessWidget {
  const _GroupedBarLineChart({
    required this.months,
    required this.funding,
    required this.payments,
    required this.maxY,
  });

  final List<String> months;
  final List<double> funding;
  final List<double> payments;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const bottomLabelHeight = 28.0;
        final chartWidth = constraints.maxWidth;
        final chartHeight = constraints.maxHeight - bottomLabelHeight;

        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: chartWidth,
              height: chartHeight,
              child: CustomPaint(
                size: Size(chartWidth, chartHeight),
                painter: _GroupedBarLinePainter(
                  funding: funding,
                  payments: payments,
                  maxY: maxY,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              width: chartWidth,
              height: bottomLabelHeight,
              child: Row(
                children: [
                  for (final month in months)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          month,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GroupedBarLinePainter extends CustomPainter {
  _GroupedBarLinePainter({
    required this.funding,
    required this.payments,
    required this.maxY,
  });

  final List<double> funding;
  final List<double> payments;
  final double maxY;

  static const _fundingColor = Color(0xFFA28CC1);
  static const _paymentsColor = Color(0xFF9EC5F0);
  static const _gridColor = Color(0xFFEDEDED);
  static const _topLabelSpace = 22.0;

  static String _formatAmount(double value) {
    final isWhole = value == value.roundToDouble();
    final raw = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
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
  void paint(Canvas canvas, Size size) {
    final plotTop = _topLabelSpace;
    final plotHeight = size.height - plotTop;

    final gridPaint = Paint()
      ..color = _gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = plotTop + plotHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final count = funding.length;
    if (count == 0) return;

    final groupWidth = size.width / count;
    final barWidth = math.min(18.0, groupWidth * 0.22);
    const gap = 4.0;

    final fundingTops = <Offset>[];
    const baseStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    for (var i = 0; i < count; i++) {
      final centerX = groupWidth * (i + 0.5);
      final fundingHeight = (funding[i] / maxY) * plotHeight;
      final paymentsHeight = (payments[i] / maxY) * plotHeight;

      final fundingLeft = centerX - barWidth - gap / 2;
      final paymentsLeft = centerX + gap / 2;

      final fundingTop = size.height - fundingHeight;
      final paymentsTop = size.height - paymentsHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(fundingLeft, fundingTop, barWidth, fundingHeight),
          const Radius.circular(4),
        ),
        Paint()..color = _fundingColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(paymentsLeft, paymentsTop, barWidth, paymentsHeight),
          const Radius.circular(4),
        ),
        Paint()..color = _paymentsColor,
      );

      fundingTops.add(Offset(fundingLeft + barWidth / 2, fundingTop));

      _drawValueLabel(
        canvas,
        chartWidth: size.width,
        text: _formatAmount(funding[i]),
        centerX: fundingLeft + barWidth / 2,
        barTop: fundingTop,
        style: baseStyle.copyWith(color: _fundingColor),
      );
      _drawValueLabel(
        canvas,
        chartWidth: size.width,
        text: _formatAmount(payments[i]),
        centerX: paymentsLeft + barWidth / 2,
        barTop: paymentsTop,
        style: baseStyle.copyWith(color: const Color(0xFF5B8DEF)),
      );
    }

    if (fundingTops.length > 1) {
      final linePaint = Paint()
        ..color = _fundingColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(fundingTops.first.dx, fundingTops.first.dy);
      for (var i = 1; i < fundingTops.length; i++) {
        path.lineTo(fundingTops[i].dx, fundingTops[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    final fillPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = _fundingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final point in fundingTops) {
      canvas.drawCircle(point, 4, fillPaint);
      canvas.drawCircle(point, 4, strokePaint);
    }
  }

  void _drawValueLabel(
    Canvas canvas, {
    required double chartWidth,
    required String text,
    required double centerX,
    required double barTop,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final x = (centerX - painter.width / 2)
        .clamp(0.0, math.max(0.0, chartWidth - painter.width))
        .toDouble();
    final y = math.max(0.0, barTop - painter.height - 4);

    painter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _GroupedBarLinePainter oldDelegate) {
    return oldDelegate.funding != funding ||
        oldDelegate.payments != payments ||
        oldDelegate.maxY != maxY;
  }
}

// ---------------------------------------------------------------------------
// Work Progress Report
// ---------------------------------------------------------------------------

class _WorkProgressReportCard extends StatelessWidget {
  const _WorkProgressReportCard({
    this.onViewDetails,
    this.fillHeight = false,
  });

  final VoidCallback? onViewDetails;
  final bool fillHeight;

  Color _progressColor(int percent, String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.contains('complete') || percent >= 100) {
      return const Color(0xFF1BA752);
    }
    if (normalized.contains('progress') || percent >= 50) {
      return const Color(0xFFE8A03D);
    }
    return const Color(0xFFE06B7A);
  }

  List<_ProgressItem> _mapPhases(List<WorkPhaseListModel> phases) {
    return phases.map((phase) {
      final percent = phase.progress.clamp(0, 100);
      return _ProgressItem(
        label: phase.stageName.trim().isEmpty
            ? 'Untitled stage'
            : phase.stageName.trim(),
        percent: percent,
        color: _progressColor(percent, phase.status),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Expanded(
          child: Text(
            'Work Progress Report',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );

    return _PanelCard(
      fillHeight: fillHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 18),
          if (fillHeight)
            Expanded(
              child: BlocBuilder<ReportCubit, ReportState>(
                buildWhen: (previous, current) =>
                    previous.workProgressLoading !=
                        current.workProgressLoading ||
                    previous.workProgressError != current.workProgressError ||
                    previous.phases != current.phases,
                builder: (context, state) =>
                    _buildBody(context, state, scrollable: true),
              ),
            )
          else
            BlocBuilder<ReportCubit, ReportState>(
              buildWhen: (previous, current) =>
                  previous.workProgressLoading != current.workProgressLoading ||
                  previous.workProgressError != current.workProgressError ||
                  previous.phases != current.phases,
              builder: (context, state) =>
                  _buildBody(context, state, scrollable: false),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReportState state, {
    required bool scrollable,
  }) {
    if (state.workProgressLoading && state.phases.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.accent,
          ),
        ),
      );
    }

    final error = state.workProgressError;
    if (error != null && state.phases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    context.read<ReportCubit>().fetchWorkPhaseList(),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = _mapPhases(state.phases);

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No work progress data',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 22),
          _InlineProgressRow(item: items[i]),
        ],
      ],
    );

    if (scrollable) {
      return SingleChildScrollView(child: body);
    }
    return body;
  }
}

class _ProgressItem {
  const _ProgressItem({
    required this.label,
    required this.percent,
    required this.color,
    this.trailing,
  });

  final String label;
  final int percent;
  final Color color;
  final String? trailing;
}

class _InlineProgressRow extends StatelessWidget {
  const _InlineProgressRow({required this.item});

  final _ProgressItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: item.percent / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDED),
              color: item.color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            '${item.percent}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Investor Summary
// ---------------------------------------------------------------------------

class _InvestorSummaryCard extends StatelessWidget {
  const _InvestorSummaryCard({
    this.onViewAll,
    this.fillHeight = false,
  });

  final VoidCallback? onViewAll;
  final bool fillHeight;

  static const _typeColors = [
    Color(0xFFA28CC1),
    Color(0xFF9EC5F0),
    Color(0xFF1BA752),
    Color(0xFFE06B7A),
    Color(0xFF7B8CDE),
    Color(0xFFE0A86B),
    Color(0xFF5B9A9A),
  ];

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Expanded(
          child: Text(
            'Investor Summary',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );

    return _PanelCard(
      fillHeight: fillHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          if (fillHeight)
            Expanded(
              child: BlocBuilder<ReportCubit, ReportState>(
                buildWhen: (previous, current) =>
                    previous.investorTypeCountLoading !=
                        current.investorTypeCountLoading ||
                    previous.investorTypeCountError !=
                        current.investorTypeCountError ||
                    previous.investorTypeCount != current.investorTypeCount,
                builder: (context, state) =>
                    _buildBody(context, state, scrollable: true),
              ),
            )
          else
            BlocBuilder<ReportCubit, ReportState>(
              buildWhen: (previous, current) =>
                  previous.investorTypeCountLoading !=
                      current.investorTypeCountLoading ||
                  previous.investorTypeCountError !=
                      current.investorTypeCountError ||
                  previous.investorTypeCount != current.investorTypeCount,
              builder: (context, state) =>
                  _buildBody(context, state, scrollable: false),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReportState state, {
    required bool scrollable,
  }) {
    if (state.investorTypeCountLoading && state.investorTypeCount == null) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.accent,
          ),
        ),
      );
    }

    final error = state.investorTypeCountError;
    if (error != null && state.investorTypeCount == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    context.read<ReportCubit>().fetchInvestorTypeCount(),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasInvestorTypeCountData) {
      return Center(
        child: Text(
          'No data found',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    final data = state.investorTypeCount!;
    final statusItems = _mapInvestorTypes(data);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 420;
            final cards = [
              _InvestorStatChip(
                label: 'Active Investors',
                value: '${data.totalInvestors}',
                icon: Icons.groups_outlined,
                iconColor: const Color(0xFF1BA752),
                background: const Color(0xFFE8F7EE),
              ),
            ];

            if (stack) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    cards[i],
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: cards[i]),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Investor Status Breakdown',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        if (statusItems.isEmpty)
          Text(
            'No data found',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          )
        else
          for (var i = 0; i < statusItems.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _StatusBreakdownRow(item: statusItems[i]),
          ],
      ],
    );

    if (scrollable) {
      return SingleChildScrollView(child: body);
    }
    return body;
  }

  List<_ProgressItem> _mapInvestorTypes(InvestorTypeCountModel data) {
    final total = data.totalInvestors;
    final types = data.investorTypes;

    return [
      for (var i = 0; i < types.length; i++)
        _ProgressItem(
          label: types[i].investorType.isNotEmpty
              ? types[i].investorType
              : 'Other',
          percent: total > 0
              ? ((types[i].count / total) * 100).round().clamp(0, 100)
              : 0,
          color: _typeColors[i % _typeColors.length],
          trailing: '${types[i].count}',
        ),
    ];
  }
}

class _InvestorStatChip extends StatelessWidget {
  const _InvestorStatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBreakdownRow extends StatelessWidget {
  const _StatusBreakdownRow({required this.item});

  final _ProgressItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Text(
              item.trailing ?? '${item.percent}',
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
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: item.percent / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFFEDEDED),
            color: item.color,
          ),
        ),
      ],
    );
  }
}
