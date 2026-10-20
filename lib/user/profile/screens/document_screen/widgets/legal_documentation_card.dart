import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_llp_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_mou_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

enum DocumentProcessStep { pending, issued, completed }

extension DocumentProcessStepX on DocumentProcessStep {
  static DocumentProcessStep fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'issued':
        return DocumentProcessStep.issued;
      case 'completed':
        return DocumentProcessStep.completed;
      case 'pending':
      default:
        return DocumentProcessStep.pending;
    }
  }

  static DocumentProcessStep fromMouRecords(List<InvestorMouModel> records) {
    if (records.isEmpty) return DocumentProcessStep.pending;

    final sorted = [...records]
      ..sort((a, b) {
        final aDate =
            a.createdDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final byDate = bDate.compareTo(aDate);
        if (byDate != 0) return byDate;
        return b.id.compareTo(a.id);
      });

    return DocumentProcessStepX.fromApi(sorted.first.status);
  }

  static DocumentProcessStep fromLlpRecords(List<InvestorLlpModel> records) {
    if (records.isEmpty) return DocumentProcessStep.pending;

    final sorted = [...records]
      ..sort((a, b) {
        final aDate =
            a.createdDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final byDate = bDate.compareTo(aDate);
        if (byDate != 0) return byDate;
        return b.id.compareTo(a.id);
      });

    return DocumentProcessStepX.fromApi(sorted.first.status);
  }
}

class LegalDocumentationCard extends StatefulWidget {
  const LegalDocumentationCard({
    super.key,
    this.investorId,
  });

  final int? investorId;

  @override
  State<LegalDocumentationCard> createState() => LegalDocumentationCardState();
}

class LegalDocumentationCardState extends State<LegalDocumentationCard> {
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  DocumentProcessStep _mouStatus = DocumentProcessStep.pending;
  DocumentProcessStep _llpStatus = DocumentProcessStep.pending;
  bool _isLoadingMou = false;
  bool _isLoadingLlp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
  }

  @override
  void didUpdateWidget(covariant LegalDocumentationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.investorId != widget.investorId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
    }
  }

  Future<void> refresh({bool showLoading = true}) async {
    final investorId = widget.investorId;
    if (investorId == null || investorId <= 0) {
      setState(() {
        _mouStatus = DocumentProcessStep.pending;
        _llpStatus = DocumentProcessStep.pending;
        _isLoadingMou = false;
        _isLoadingLlp = false;
      });
      return;
    }

    if (showLoading) {
      setState(() {
        _isLoadingMou = true;
        _isLoadingLlp = true;
      });
    }

    final repository = context.read<ProfileRepository>();
    await Future.wait([
      _loadMouStatus(repository, investorId),
      _loadLlpStatus(repository, investorId),
    ]);
  }

  Future<void> _loadMouStatus(
    ProfileRepository repository,
    int investorId,
  ) async {
    try {
      final response = await repository.getInvestorMou(investorId);

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!mounted) return;

      setState(() {
        _isLoadingMou = false;
        _mouStatus = looksSuccessful
            ? DocumentProcessStepX.fromMouRecords(response.data)
            : DocumentProcessStep.pending;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _isLoadingMou = false;
        _mouStatus = DocumentProcessStep.pending;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMou = false;
        _mouStatus = DocumentProcessStep.pending;
      });
    }
  }

  Future<void> _loadLlpStatus(
    ProfileRepository repository,
    int investorId,
  ) async {
    try {
      final response = await repository.getInvestorLlp(investorId);

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!mounted) return;

      setState(() {
        _isLoadingLlp = false;
        _llpStatus = looksSuccessful
            ? DocumentProcessStepX.fromLlpRecords(response.data)
            : DocumentProcessStep.pending;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _isLoadingLlp = false;
        _llpStatus = DocumentProcessStep.pending;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLlp = false;
        _llpStatus = DocumentProcessStep.pending;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.4.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  ImageConstants.deliveredDocuments,
                  width: 5.w,
                  height: 5.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 2.5.w),
                Text(
                  'Legal Documentation',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
            indent: 4.w,
            endIndent: 4.w,
          ),
          if (_isLoadingMou)
            const _DocumentStatusShimmer(
              label: 'MOU',
              baseColor: _shimmerBase,
              highlightColor: _shimmerHighlight,
            )
          else
            _DocumentStatusBlock(label: 'MOU', status: _mouStatus),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
            indent: 4.w,
            endIndent: 4.w,
          ),
          if (_isLoadingLlp)
            const _DocumentStatusShimmer(
              label: 'LLP Registration',
              baseColor: _shimmerBase,
              highlightColor: _shimmerHighlight,
            )
          else
            _DocumentStatusBlock(
              label: 'LLP Registration',
              status: _llpStatus,
            ),
        ],
      ),
    );
  }
}

class _DocumentStatusBlock extends StatelessWidget {
  const _DocumentStatusBlock({
    required this.label,
    required this.status,
  });

  final String label;
  final DocumentProcessStep status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.2.h),
          _DocumentStatusTimeline(activeStatus: status),
        ],
      ),
    );
  }
}

class _DocumentStatusShimmer extends StatelessWidget {
  const _DocumentStatusShimmer({
    required this.label,
    required this.baseColor,
    required this.highlightColor,
  });

  final String label;
  final Color baseColor;
  final Color highlightColor;

  static const _stepLabels = ['Pending', 'Issued', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final iconSize = 5.w;
    const gap = 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.2.h),
            Row(
              children: [
                for (var i = 0; i < _stepLabels.length; i++)
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: iconSize,
                          child: Row(
                            children: [
                              Expanded(
                                child: i == 0
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: gap),
                                        child: Container(
                                          height: 1,
                                          color: baseColor,
                                        ),
                                      ),
                              ),
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: i == _stepLabels.length - 1
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: gap),
                                        child: Container(
                                          height: 1,
                                          color: baseColor,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 0.7.h),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            _stepLabels[i],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
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

enum _TimelineStepVisual { pendingError, success, inactive }

class _DocumentStatusTimeline extends StatelessWidget {
  const _DocumentStatusTimeline({required this.activeStatus});

  final DocumentProcessStep activeStatus;

  static const _steps = [
    DocumentProcessStep.pending,
    DocumentProcessStep.issued,
    DocumentProcessStep.completed,
  ];

  static String _labelFor(DocumentProcessStep step) {
    switch (step) {
      case DocumentProcessStep.pending:
        return 'Pending';
      case DocumentProcessStep.issued:
        return 'Issued';
      case DocumentProcessStep.completed:
        return 'Completed';
    }
  }

  _TimelineStepVisual _visualFor(DocumentProcessStep step) {
    if (step == DocumentProcessStep.pending) {
      return _TimelineStepVisual.pendingError;
    }

    final stepIndex = _steps.indexOf(step);
    final activeIndex = _steps.indexOf(activeStatus);

    if (stepIndex > activeIndex) return _TimelineStepVisual.inactive;

    return _TimelineStepVisual.success;
  }

  Color _connectorColorLeadingTo(int stepIndex) {
    final activeIndex = _steps.indexOf(activeStatus);
    if (activeIndex >= stepIndex && stepIndex > 0) {
      return AppColors.green;
    }
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = 5.w;
    const gap = 4.0;

    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: iconSize,
                  child: Row(
                    children: [
                      Expanded(
                        child: i == 0
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(right: gap),
                                child: _DottedConnector(
                                  showArrow: true,
                                  color: _connectorColorLeadingTo(i),
                                ),
                              ),
                      ),
                      _TimelineDot(
                        size: iconSize,
                        visual: _visualFor(_steps[i]),
                      ),
                      Expanded(
                        child: i == _steps.length - 1
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(left: gap),
                                child: _DottedLine(
                                  color: _connectorColorLeadingTo(i + 1),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0.7.h),
                _TimelineLabel(
                  label: _labelFor(_steps[i]),
                  visual: _visualFor(_steps[i]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DottedConnector extends StatelessWidget {
  const _DottedConnector({
    this.showArrow = false,
    this.color = AppColors.textMuted,
  });

  final bool showArrow;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _DottedLine(color: color)),
        if (showArrow)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 2.2.w,
            color: color,
          ),
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({this.color = AppColors.textMuted});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DottedLinePainter(color: color),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    const dashWidth = 3.0;
    const dashSpace = 3.5;
    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({
    required this.size,
    required this.visual,
  });

  final double size;
  final _TimelineStepVisual visual;

  @override
  Widget build(BuildContext context) {
    switch (visual) {
      case _TimelineStepVisual.pendingError:
        return Icon(
          Icons.cancel_rounded,
          size: size,
          color: AppColors.error,
        );
      case _TimelineStepVisual.success:
        return Icon(
          Icons.check_circle_rounded,
          size: size,
          color: AppColors.green,
        );
      case _TimelineStepVisual.inactive:
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.textMuted, width: 1.6),
              ),
            ),
          ),
        );
    }
  }
}

class _TimelineLabel extends StatelessWidget {
  const _TimelineLabel({
    required this.label,
    required this.visual,
  });

  final String label;
  final _TimelineStepVisual visual;

  @override
  Widget build(BuildContext context) {
    final color = switch (visual) {
      _TimelineStepVisual.pendingError => AppColors.error,
      _TimelineStepVisual.success => AppColors.green,
      _TimelineStepVisual.inactive => AppColors.textMuted,
    };

    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: visual == _TimelineStepVisual.inactive
            ? FontWeight.w500
            : FontWeight.w600,
        color: color,
      ),
    );
  }
}
