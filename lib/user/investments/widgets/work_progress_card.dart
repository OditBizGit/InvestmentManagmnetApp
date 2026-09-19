import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class WorkProgressCard extends StatefulWidget {
  const WorkProgressCard({super.key});

  @override
  State<WorkProgressCard> createState() => _WorkProgressCardState();
}

/// Shimmer matching [WorkProgressCard] padding, chart height, and typography.
class WorkProgressCardShimmer extends StatelessWidget {
  const WorkProgressCardShimmer({super.key});

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const Color _border = Color(0xFFE8E4EE);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
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
                      _Line(
                        sample: 'Work Progress',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        widthFactor: 0.45,
                      ),
                      SizedBox(height: 0.2.h),
                      _Line(
                        sample: 'From pending to completed All in one place.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        widthFactor: 0.92,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Phase 1',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              height: 22.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 0.8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final label in const ['01', '02', '03', '04', '05'])
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.sample,
    required this.style,
    this.widthFactor,
  });

  final String sample;
  final TextStyle style;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        sample,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style.copyWith(color: Colors.transparent),
      ),
    );

    if (widthFactor == null) return line;

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor!.clamp(0.0, 1.0),
        child: line,
      ),
    );
  }
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
    'Phase 1': [0.22, 0.48, 0.28, 0.82, 0.52],
    'Phase 2': [0.38, 0.10, 0.85, 0.78, 0.99],
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
                    SizedBox(height: 0.2.h),
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
            height: 22.h,
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

class _PhaseDropdown extends StatefulWidget {
  const _PhaseDropdown({
    required this.phases,
    required this.selectedPhase,
    required this.onChanged,
  });

  final List<String> phases;
  final String selectedPhase;
  final ValueChanged<String?> onChanged;

  @override
  State<_PhaseDropdown> createState() => _PhaseDropdownState();
}

class _PhaseDropdownState extends State<_PhaseDropdown> {
  static const Color _accent = Color(0xFFA28CC1);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _border = Color(0xFFE8E4EE);

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen && mounted) {
      setState(() => _isOpen = false);
    } else {
      _isOpen = false;
    }
  }

  void _showOverlay() {
    final fieldBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fieldBox == null) return;

    final fieldSize = fieldBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 6),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: fieldSize.width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < widget.phases.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: _border.withValues(alpha: 0.8),
                              ),
                            _PhaseOption(
                              label: widget.phases[i],
                              isSelected:
                                  widget.phases[i] == widget.selectedPhase,
                              onTap: () {
                                final phase = widget.phases[i];
                                _removeOverlay();
                                widget.onChanged(phase);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        key: _fieldKey,
        color: _accentSoft,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isOpen
                    ? _accent
                    : _accent.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedPhase,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
                SizedBox(width: 1.w),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _accent,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseOption extends StatelessWidget {
  const _PhaseOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _accent = Color(0xFFA28CC1);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _textPrimary = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        color: isSelected ? _accentSoft : Colors.white,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? _accent : _textPrimary,
          ),
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
