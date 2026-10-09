import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_bottom_nav.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:maribel_wellness_centre_application/user/updates/model/work_update_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';
import 'package:maribel_wellness_centre_application/user/updates/widgets/work_update_fullscreen_image.dart';
import 'package:maribel_wellness_centre_application/user/updates/widgets/work_update_inline_video.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class LatestProjectUpdates extends StatelessWidget {
  const LatestProjectUpdates({
    super.key,
    this.isLoading = false,
    this.isActive = false,
    this.latestUpdate,
  });

  final bool isLoading;
  /// When false (e.g. home tab not visible), skip initializing the video player.
  final bool isActive;
  final WorkUpdateModel? latestUpdate;

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

    final update = latestUpdate;
    if (update == null) {
      return const SizedBox.shrink();
    }

    final description = update.description.trim();
    final mediaUrl = update.resolvedFileUrl;

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
            child: _buildMedia(context, mediaUrl, update),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          update.title,
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        if (description.isNotEmpty) ...[
          SizedBox(height: 0.4.h),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
              height: 1.45,
            ),
          ),
        ],
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

  Widget _buildMedia(
    BuildContext context,
    String? mediaUrl,
    WorkUpdateModel update,
  ) {
    if (update.isVideo && mediaUrl != null) {
      if (!isActive) {
        return ColoredBox(
          color: const Color(0xFFF0EBF6),
          child: Center(
            child: Icon(
              Icons.videocam_rounded,
              color: _button.withValues(alpha: 0.7),
              size: 12.w,
            ),
          ),
        );
      }

      return WorkUpdateInlineVideo(
        key: ValueKey('latest-update-video-${update.workUpdateId}'),
        videoUrl: mediaUrl,
        title: update.title,
        fileName: update.fileName,
      );
    }

    if (mediaUrl != null && update.isImage) {
      return GestureDetector(
        onTap: () => openWorkUpdateFullscreenImage(
          context,
          imageUrl: mediaUrl,
          title: update.title,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: mediaUrl,
              cacheManager: WorkUpdateMediaCache.manager,
              httpHeaders: WorkUpdateMediaCache.authHeaders(),
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: _shimmerBase,
                highlightColor: _shimmerHighlight,
                direction: ShimmerDirection.ltr,
                child: const ColoredBox(color: _shimmerBase),
              ),
              errorWidget: (context, url, error) => const _MediaErrorPane(
                svgPath: ImageConstants.imageError,
                message: 'Unable to load image',
              ),
            ),
            Positioned(
              right: 2.w,
              bottom: 1.2.h,
              child: Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  ImageConstants.view,
                  width: 4.5.w,
                  height: 4.5.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (update.isVideo) {
      return const _MediaErrorPane(
        svgPath: ImageConstants.videoError,
        message: 'Unable to load preview',
      );
    }

    if (update.isImage) {
      return const _MediaErrorPane(
        svgPath: ImageConstants.imageError,
        message: 'Unable to load image',
      );
    }

    return Container(
      color: const Color(0xFFF0EBF6),
      child: Icon(
        Icons.apartment_outlined,
        color: _button,
        size: 10.w,
      ),
    );
  }
}

class _MediaErrorPane extends StatelessWidget {
  const _MediaErrorPane({
    required this.svgPath,
    required this.message,
  });

  final String svgPath;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 10.w,
            height: 10.w,
            colorFilter: ColorFilter.mode(
              Colors.grey[600]!,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
            sample: 'The main load-bearing walls and ceiling structures',
            style: bodyStyle,
            widthFactor: 1,
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
