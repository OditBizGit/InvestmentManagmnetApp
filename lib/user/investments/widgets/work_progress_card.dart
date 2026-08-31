import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WorkProgressCard extends StatefulWidget {
  const WorkProgressCard({super.key});

  @override
  State<WorkProgressCard> createState() => _WorkProgressCardState();
}

class _WorkProgressCardState extends State<WorkProgressCard> {
  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _accent = Color(0xFFA28CC1);
  static const Color _border = Color(0xFFE8E4EE);

  static const List<String> _phases = [
    'Phase 1',
    'Phase 2',
    'Phase 3',
    'Phase 4',
    'Phase 5',
  ];

  static const Map<String, List<double>> _phaseProgress = {
    'Phase 1': [0.22, 0.38, 0.48, 0.72, 0.92],
    'Phase 2': [0.18, 0.30, 0.45, 0.58, 0.70],
    'Phase 3': [0.12, 0.25, 0.40, 0.55, 0.62],
    'Phase 4': [0.08, 0.18, 0.28, 0.35, 0.42],
    'Phase 5': [0.05, 0.10, 0.16, 0.22, 0.28],
  };

  static const List<String> _labels = ['01', '02', '03', '04', '05'];

  String _selectedPhase = _phases.first;

  @override
  Widget build(BuildContext context) {
    final progressValues = _phaseProgress[_selectedPhase]!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Progress',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      'From pending to completed All in one place.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: _textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              _PhaseDropdown(
                phases: _phases,
                selectedPhase: _selectedPhase,
                onChanged: (phase) {
                  if (phase == null || phase == _selectedPhase) return;
                  setState(() => _selectedPhase = phase);
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 14.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _WorkProgressChartPainter(
                values: progressValues,
                lineColor: _accent,
                fillColor: _accent.withValues(alpha: 0.28),
              ),
            ),
          ),
          SizedBox(height: 0.8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in _labels)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseDropdown extends StatelessWidget {
  const _PhaseDropdown({
    required this.phases,
    required this.selectedPhase,
    required this.onChanged,
  });

  final List<String> phases;
  final String selectedPhase;
  final ValueChanged<String?> onChanged;

  static const Color _accent = Color(0xFFA28CC1);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _textPrimary = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w),
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPhase,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          elevation: 4,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _accent,
            size: 5.w,
          ),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _accent,
          ),
          selectedItemBuilder: (context) {
            return [
              for (final phase in phases)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    phase,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
            ];
          },
          items: [
            for (final phase in phases)
              DropdownMenuItem<String>(
                value: phase,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: phase == selectedPhase
                        ? _accentSoft
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      phase,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: phase == selectedPhase
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: phase == selectedPhase ? _accent : _textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          onChanged: onChanged,
          menuMaxHeight: 40.h,
        ),
      ),
    );
  }
}

class _WorkProgressChartPainter extends CustomPainter {
  const _WorkProgressChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final path = Path();
    final points = <Offset>[];

    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height * (1 - values[i].clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      path.cubicTo(
        controlX,
        current.dy,
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          fillColor,
          fillColor.withValues(alpha: 0.02),
        ],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WorkProgressChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
