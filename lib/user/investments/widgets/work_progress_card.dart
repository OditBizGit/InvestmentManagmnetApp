import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/project_stage_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/work_progress_graph_point_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/repository/investments_repository.dart';
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
                const _PhaseDropdownShimmer(wrapWithShimmer: false),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 22.h,
              width: double.infinity,
              child: const _WorkProgressGraphShimmer(wrapWithShimmer: false),
            ),
            SizedBox(height: 0.8.h),
            const _WorkProgressGraphFooterShimmer(wrapWithShimmer: false),
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

  bool _isLoadingStages = true;
  bool _isLoadingGraph = false;
  List<ProjectStageModel> _stages = const [];
  ProjectStageModel? _selectedStage;
  List<WorkProgressGraphPointModel> _graphPoints = const [];
  int? _graphRequestId;
  int? _selectedPointIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStages());
  }

  Future<void> _loadStages() async {
    setState(() => _isLoadingStages = true);

    try {
      final stages =
          await getIt<InvestmentsRepository>().getWorkProgressStages();
      if (!mounted) return;

      final selected = stages.isNotEmpty ? stages.first : null;
      setState(() {
        _stages = stages;
        _selectedStage = selected;
        _isLoadingStages = false;
        _selectedPointIndex = null;
        if (selected == null) {
          _graphPoints = const [];
          _isLoadingGraph = false;
        }
      });

      if (selected != null) {
        await _loadGraph(selected.stageId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stages = const [];
        _selectedStage = null;
        _graphPoints = const [];
        _selectedPointIndex = null;
        _isLoadingStages = false;
        _isLoadingGraph = false;
      });
    }
  }

  Future<void> _loadGraph(int stageId) async {
    final requestId = DateTime.now().microsecondsSinceEpoch;
    _graphRequestId = requestId;

    setState(() {
      _isLoadingGraph = true;
      _graphPoints = const [];
      _selectedPointIndex = null;
    });

    try {
      final points =
          await getIt<InvestmentsRepository>().getWorkProgressGraph(stageId);
      if (!mounted || _graphRequestId != requestId) return;

      setState(() {
        _graphPoints = List.unmodifiable(
          [...points]..sort((a, b) {
            final aDate = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aDate.compareTo(bDate);
          }),
        );
        _isLoadingGraph = false;
      });
    } catch (_) {
      if (!mounted || _graphRequestId != requestId) return;
      setState(() {
        _graphPoints = const [];
        _isLoadingGraph = false;
      });
    }
  }

  void _onStageSelected(String? phase) {
    if (phase == null) return;

    ProjectStageModel? match;
    for (final stage in _stages) {
      if (stage.stageName == phase) {
        match = stage;
        break;
      }
    }

    if (match == null || match.stageId == _selectedStage?.stageId) return;

    setState(() => _selectedStage = match);
    _loadGraph(match.stageId);
  }

  void _onChartTapDown(TapDownDetails details, Size chartSize) {
    final values = _chartValues;
    if (values.isEmpty) return;

    final points = _WorkProgressChartPainter.pointOffsets(values, chartSize);
    if (points.isEmpty) return;

    const hitRadius = 28.0;
    var nearestIndex = 0;
    var nearestDistance = double.infinity;

    for (var i = 0; i < points.length; i++) {
      final distance = (points[i] - details.localPosition).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestDistance > hitRadius) {
      if (_selectedPointIndex != null) {
        setState(() => _selectedPointIndex = null);
      }
      return;
    }

    setState(() {
      _selectedPointIndex =
          _selectedPointIndex == nearestIndex ? null : nearestIndex;
    });
  }

  List<double> get _chartValues {
    if (_graphPoints.isEmpty) return const [];
    return _graphPoints.map((point) => point.progressFraction).toList();
  }

  List<String> get _chartLabels {
    if (_graphPoints.isEmpty) return const [];
    return _graphPoints.map((point) => _formatDayMonth(point.date)).toList();
  }

  static const List<String> _monthAbbreviations = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  static String _formatDayMonth(DateTime? date) {
    if (date == null) return '--';
    final day = date.day.toString().padLeft(2, '0');
    return '$day-${_monthAbbreviations[date.month - 1]}';
  }

  String? get _selectedProgressLabel {
    final index = _selectedPointIndex;
    if (index == null || index < 0 || index >= _graphPoints.length) {
      return null;
    }
    final progress = _graphPoints[index].progress;
    final display = progress == progress.roundToDouble()
        ? progress.toInt().toString()
        : progress.toStringAsFixed(1);
    return '$display%';
  }

  @override
  Widget build(BuildContext context) {
    final stageNames = _stages.map((stage) => stage.stageName).toList();
    final selectedName = _selectedStage?.stageName ??
        (stageNames.isNotEmpty ? stageNames.first : 'Stage');
    final chartValues = _chartValues;
    final chartLabels = _chartLabels;
    final selectedLabel = _selectedProgressLabel;

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
                phases: stageNames,
                selectedPhase: selectedName,
                isLoading: _isLoadingStages,
                onChanged: _onStageSelected,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 22.h,
            width: double.infinity,
            child: _isLoadingGraph
                ? const _WorkProgressGraphShimmer()
                : chartValues.isEmpty
                    ? Center(
                        child: Text(
                          'No progress data',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: _textSecondary,
                          ),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _ChartPercentAxis(),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final chartSize = Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                final selectedOffsets =
                                    _WorkProgressChartPainter.pointOffsets(
                                  chartValues,
                                  chartSize,
                                );
                                final selectedOffset =
                                    _selectedPointIndex != null &&
                                            _selectedPointIndex! >= 0 &&
                                            _selectedPointIndex! <
                                                selectedOffsets.length
                                        ? selectedOffsets[
                                            _selectedPointIndex!]
                                        : null;

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) =>
                                      _onChartTapDown(details, chartSize),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _WorkProgressChartPainter(
                                            values: chartValues,
                                            lineColor: _accent,
                                            fillColor: _accent.withValues(
                                              alpha: 0.28,
                                            ),
                                            selectedIndex:
                                                _selectedPointIndex,
                                          ),
                                        ),
                                      ),
                                      if (selectedOffset != null &&
                                          selectedLabel != null)
                                        _ChartPercentTooltip(
                                          offset: selectedOffset,
                                          label: selectedLabel,
                                          chartSize: chartSize,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
          SizedBox(height: 0.8.h),
          if (_isLoadingGraph)
            const _WorkProgressGraphFooterShimmer()
          else if (chartLabels.isNotEmpty)
            Row(
              children: [
                SizedBox(width: _ChartPercentAxis.width + 1.w),
                Expanded(
                  child: Row(
                    mainAxisAlignment: chartLabels.length == 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      for (final label in chartLabels)
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
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WorkProgressGraphShimmer extends StatelessWidget {
  const _WorkProgressGraphShimmer({
    this.wrapWithShimmer = true,
  });

  final bool wrapWithShimmer;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const List<double> _placeholderValues = [
    0.18,
    0.42,
    0.30,
    0.68,
    0.55,
  ];

  @override
  Widget build(BuildContext context) {
    final child = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: _ChartPercentAxis.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final label in const [
                '100%',
                '75%',
                '50%',
                '25%',
                '0%',
              ])
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.transparent,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: CustomPaint(
            painter: _WorkProgressChartPainter(
              values: _placeholderValues,
              lineColor: Colors.white,
              fillColor: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );

    if (!wrapWithShimmer) return child;

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class _WorkProgressGraphFooterShimmer extends StatelessWidget {
  const _WorkProgressGraphFooterShimmer({
    this.wrapWithShimmer = true,
  });

  final bool wrapWithShimmer;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        SizedBox(width: _ChartPercentAxis.width + 1.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in const [
                '01-JAN',
                '02-JAN',
                '03-JAN',
                '04-JAN',
                '05-JAN',
              ])
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
        ),
      ],
    );

    if (!wrapWithShimmer) return child;

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class _ChartPercentAxis extends StatelessWidget {
  const _ChartPercentAxis();

  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const List<String> _labels = ['100%', '75%', '50%', '25%', '0%'];

  /// Fixed width so day labels can align under the chart area.
  static double get width => 7.w;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final label in _labels)
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartPercentTooltip extends StatelessWidget {
  const _ChartPercentTooltip({
    required this.offset,
    required this.label,
    required this.chartSize,
  });

  final Offset offset;
  final String label;
  final Size chartSize;

  static const Color _accent = Color(0xFFA28CC1);

  @override
  Widget build(BuildContext context) {
    const tooltipWidth = 40.0;
    const tooltipHeight = 25.0;
    const gap = 10.0;

    var left = offset.dx - (tooltipWidth / 2);
    left = left.clamp(0.0, (chartSize.width - tooltipWidth).clamp(0.0, double.infinity));

    var top = offset.dy - tooltipHeight - gap;
    if (top < 0) {
      top = offset.dy + gap;
    }

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: tooltipWidth,
          height: tooltipHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseDropdown extends StatefulWidget {
  const _PhaseDropdown({
    required this.phases,
    required this.selectedPhase,
    required this.onChanged,
    this.isLoading = false,
  });

  final List<String> phases;
  final String selectedPhase;
  final ValueChanged<String?> onChanged;
  final bool isLoading;

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
    if (widget.isLoading || widget.phases.isEmpty) return;
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
                  width: fieldSize.width < 28.w ? 28.w : fieldSize.width,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 28.h),
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
                      child: SingleChildScrollView(
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
    if (widget.isLoading) {
      return const _PhaseDropdownShimmer();
    }

    final label =
        widget.phases.isEmpty ? 'No stages' : widget.selectedPhase;

    final dropdownWidth = 28.w;

    return SizedBox(
      width: dropdownWidth,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Material(
          key: _fieldKey,
          color: _accentSoft,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: dropdownWidth,
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
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                        height: 1.2,
                      ),
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
      ),
    );
  }
}

class _PhaseDropdownShimmer extends StatelessWidget {
  const _PhaseDropdownShimmer({
    this.wrapWithShimmer = true,
  });

  final bool wrapWithShimmer;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final dropdownWidth = 28.w;

    final child = SizedBox(
      width: dropdownWidth,
      child: Container(
        width: dropdownWidth,
        padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Phase 1',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.transparent,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.transparent,
              size: 5.w,
            ),
          ],
        ),
      ),
    );

    if (!wrapWithShimmer) return child;

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: child,
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
    this.selectedIndex,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final int? selectedIndex;

  static List<Offset> pointOffsets(List<double> values, Size size) {
    if (values.isEmpty) return const [];

    if (values.length == 1) {
      // Single date: place the real point on the right (matches footer).
      final y = size.height * (1 - values.first.clamp(0.0, 1.0));
      return [Offset(size.width, y)];
    }

    return [
      for (var i = 0; i < values.length; i++)
        Offset(
          size.width * (i / (values.length - 1)),
          size.height * (1 - values[i].clamp(0.0, 1.0)),
        ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final path = Path();
    final points = pointOffsets(values, size);

    // Single date: curve from 0% (left) up to the data point (right).
    final linePoints = values.length == 1
        ? [
            Offset(0, size.height),
            points.first,
          ]
        : points;

    path.moveTo(linePoints.first.dx, linePoints.first.dy);
    for (var i = 0; i < linePoints.length - 1; i++) {
      final current = linePoints[i];
      final next = linePoints[i + 1];
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

    final dotFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotStroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < points.length; i++) {
      final isSelected = selectedIndex == i;
      final radius = isSelected ? 6.0 : 4.0;
      canvas.drawCircle(points[i], radius, dotFill);
      canvas.drawCircle(points[i], radius, dotStroke);

      if (isSelected) {
        canvas.drawCircle(
          points[i],
          10,
          Paint()
            ..color = lineColor.withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorkProgressChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
