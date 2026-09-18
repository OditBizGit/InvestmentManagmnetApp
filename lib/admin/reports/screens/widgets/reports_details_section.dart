import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

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
  static const _months = [
    'Jan 2026',
    'Feb 2026',
    'Mar 2026',
    'Apr 2026',
    'May 2026',
    'Jun 2026',
  ];

  static const _funding = [9.0, 11.5, 13.5, 15.5, 17.5, 19.0];
  static const _payments = [5.5, 7.0, 8.5, 10.0, 11.5, 13.0];

  DateTime _fromDate = DateTime(2026, 1, 1);
  DateTime _toDate = DateTime(2026, 6, 30);

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

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10),
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

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate;
        }
      } else {
        _toDate = picked.isBefore(_fromDate) ? _fromDate : picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxY = [
      ..._funding,
      ..._payments,
    ].fold<double>(0, (max, value) => value > max ? value : max);

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
                    label: 'Payments',
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
            child: _GroupedBarLineChart(
              months: _months,
              funding: _funding,
              payments: _payments,
              maxY: maxY <= 0 ? 1 : maxY * 1.18,
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

  static String _formatCr(double value) {
    final isWhole = value == value.roundToDouble();
    final raw = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$raw Cr';
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
        text: _formatCr(funding[i]),
        centerX: fundingLeft + barWidth / 2,
        barTop: fundingTop,
        style: baseStyle.copyWith(color: _fundingColor),
      );
      _drawValueLabel(
        canvas,
        chartWidth: size.width,
        text: _formatCr(payments[i]),
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

  static const _items = [
    _ProgressItem(label: 'Foundation', percent: 100, color: Color(0xFF1BA752)),
    _ProgressItem(label: 'Structure', percent: 85, color: Color(0xFF1BA752)),
    _ProgressItem(label: 'Electrical', percent: 60, color: Color(0xFFE8A03D)),
    _ProgressItem(label: 'Plumbing', percent: 45, color: Color(0xFFE06B7A)),
    _ProgressItem(label: 'Interior', percent: 20, color: Color(0xFFE06B7A)),
    _ProgressItem(label: 'External Works', percent: 0, color: Color(0xFFE06B7A)),
  ];

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

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(height: 22),
          _InlineProgressRow(item: _items[i]),
        ],
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
            Expanded(child: SingleChildScrollView(child: body))
          else
            body,
        ],
      ),
    );
  }
}

class _ProgressItem {
  const _ProgressItem({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;
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
            '${item.percent}%',
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

  static const _statusItems = [
    _ProgressItem(
      label: 'Individual Investors',
      percent: 45,
      color: Color(0xFFA28CC1),
    ),
    _ProgressItem(
      label: 'Corporate Investors',
      percent: 30,
      color: Color(0xFF9EC5F0),
    ),
    _ProgressItem(
      label: 'Institutional Investors',
      percent: 15,
      color: Color(0xFF1BA752),
    ),
    _ProgressItem(
      label: 'Angel Investors',
      percent: 8,
      color: Color(0xFFE06B7A),
    ),
    _ProgressItem(
      label: 'Other',
      percent: 2,
      color: Color(0xFF7B8CDE),
    ),
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

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 420;
            final cards = const [
              _InvestorStatChip(
                label: 'Active Investors',
                value: '92',
                icon: Icons.groups_outlined,
                iconColor: Color(0xFF1BA752),
                background: Color(0xFFE8F7EE),
              ),
              _InvestorStatChip(
                label: 'Pending Payments',
                value: '12',
                icon: Icons.access_time_rounded,
                iconColor: Color(0xFFE8A03D),
                background: Color(0xFFFFF3E8),
              ),
              _InvestorStatChip(
                label: 'Completed Payments',
                value: '35',
                icon: Icons.check_circle_outline_rounded,
                iconColor: Color(0xFF5B8DEF),
                background: Color(0xFFEAF1FC),
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
        for (var i = 0; i < _statusItems.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _StatusBreakdownRow(item: _statusItems[i]),
        ],
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
            Expanded(child: SingleChildScrollView(child: body))
          else
            body,
        ],
      ),
    );
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
