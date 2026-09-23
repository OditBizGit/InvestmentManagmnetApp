import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/home/model/work_progress_item_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class PhaseProgressCard extends StatelessWidget {
  const PhaseProgressCard({
    super.key,
    this.isLoading = false,
    this.items = const [],
  });

  final bool isLoading;
  final List<WorkProgressItemModel> items;

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _progress = Color(0xFF4DB6AC);
  static const Color _track = Color(0xFFE8E8E8);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? const _PhaseProgressShimmer()
          : _PhaseProgressBody(items: items),
    );
  }
}

class _PhaseProgressBody extends StatelessWidget {
  const _PhaseProgressBody({required this.items});

  final List<WorkProgressItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              ImageConstants.tools,
              width: 5.w,
              height: 5.w,
              colorFilter: const ColorFilter.mode(
                PhaseProgressCard._progress,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              'Work progress',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: PhaseProgressCard._textPrimary,
              ),
            ),
          ],
        ),
        if (items.isEmpty)
          SizedBox(
            width: double.infinity,
            height: 20.h,
            child: Center(
              child: Text(
                'No work progress available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: PhaseProgressCard._textPrimary.withValues(alpha: 0.55),
                ),
              ),
            ),
          )
        else ...[
          SizedBox(height: 2.h),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == items.length - 1 ? 0 : 1.6.h,
              ),
              child: _ProgressRow(item: items[i]),
            ),
        ],
      ],
    );
  }
}

class _PhaseProgressShimmer extends StatelessWidget {
  const _PhaseProgressShimmer();

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: PhaseProgressCard._textPrimary,
    );
    final labelStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: PhaseProgressCard._textPrimary,
    );

    return Shimmer.fromColors(
      baseColor: PhaseProgressCard._shimmerBase,
      highlightColor: PhaseProgressCard._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 2.w),
              _PlaceholderLine(
                sample: 'Phase 1 progress',
                style: titleStyle,
                widthFactor: 0.55,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == 2 ? 0 : 1.6.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PlaceholderLine(
                        sample: i == 1 ? 'Brick work' : 'Structure',
                        style: labelStyle,
                        widthFactor: 0.35,
                      ),
                      _PlaceholderLine(
                        sample: '48%',
                        style: labelStyle,
                        widthFactor: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: 0.9.h,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  const _PlaceholderLine({
    required this.sample,
    required this.style,
    this.widthFactor = 1,
  });

  final String sample;
  final TextStyle style;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: sample, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : painter.width;
        final width = (painter.width * widthFactor).clamp(0.0, maxWidth);

        return Container(
          width: width,
          height: painter.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final WorkProgressItemModel item;

  @override
  Widget build(BuildContext context) {
    final percent = item.progress.round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.stageName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: PhaseProgressCard._textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: PhaseProgressCard._textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: item.progressFraction,
            minHeight: 0.9.h,
            backgroundColor: PhaseProgressCard._track,
            valueColor: const AlwaysStoppedAnimation<Color>(
              PhaseProgressCard._progress,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
      ],
    );
  }
}
