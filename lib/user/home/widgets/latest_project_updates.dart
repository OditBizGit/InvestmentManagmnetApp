import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_bottom_nav.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class LatestProjectUpdates extends StatelessWidget {
  const LatestProjectUpdates({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _button = Color(0xFFA28CC1);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LatestProjectUpdatesShimmer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Project Updates',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&h=450&fit=crop',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFF0EBF6),
                child: Icon(
                  Icons.apartment_outlined,
                  color: _button,
                  size: 10.w,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  color: const Color(0xFFF0EBF6),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Second Floor Structural Work Completed',
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 0.4.h),
        Text(
          'The main load-bearing walls and celling structures for the secondary patient wing are now fully cured and approved by site inspectors',
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
            height: 1.45,
          ),
        ),
        SizedBox(height: 1.8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: _button,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                UserMainScreen.goToTab(context, UserBottomNav.updatesIndex);
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.2.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Update',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 4.5.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LatestProjectUpdatesShimmer extends StatelessWidget {
  const _LatestProjectUpdatesShimmer();

  @override
  Widget build(BuildContext context) {
    final sectionTitleStyle = TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w700,
      color: LatestProjectUpdates._textPrimary,
    );
    final titleStyle = TextStyle(
      fontSize: 14.5.sp,
      fontWeight: FontWeight.w700,
      color: LatestProjectUpdates._textPrimary,
    );
    final bodyStyle = TextStyle(
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w400,
      color: LatestProjectUpdates._textSecondary,
      height: 1.45,
    );
    final buttonStyle = TextStyle(
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Shimmer.fromColors(
      baseColor: LatestProjectUpdates._shimmerBase,
      highlightColor: LatestProjectUpdates._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlaceholderLine(
            sample: 'Latest Project Updates',
            style: sectionTitleStyle,
            widthFactor: 0.7,
          ),
          SizedBox(height: 1.5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          _PlaceholderLine(
            sample: 'Second Floor Structural Work Completed',
            style: titleStyle,
            widthFactor: 0.85,
          ),
          SizedBox(height: 0.4.h),
          _PlaceholderLine(
            sample:
                'The main load-bearing walls and celling structures for the',
            style: bodyStyle,
            widthFactor: 1,
          ),
          SizedBox(height: 0.35.h),
          _PlaceholderLine(
            sample: 'secondary patient wing are now fully cured',
            style: bodyStyle,
            widthFactor: 0.9,
          ),
          SizedBox(height: 0.35.h),
          _PlaceholderLine(
            sample: 'and approved by site inspectors',
            style: bodyStyle,
            widthFactor: 0.65,
          ),
          SizedBox(height: 1.8.h),
          _PlaceholderLine(
            sample: 'View Update →',
            style: buttonStyle,
            widthFactor: 1,
            heightPadding: 1.2.h,
            horizontalPadding: 4.w,
            borderRadius: 10,
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
    this.heightPadding = 0,
    this.horizontalPadding = 0,
    this.borderRadius = 4,
  });

  final String sample;
  final TextStyle style;
  final double widthFactor;
  final double heightPadding;
  final double horizontalPadding;
  final double borderRadius;

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
            : painter.width + (horizontalPadding * 2);
        final contentWidth =
            (painter.width * widthFactor) + (horizontalPadding * 2);
        final width = contentWidth.clamp(0.0, maxWidth);

        return Container(
          width: width,
          height: painter.height + (heightPadding * 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}
