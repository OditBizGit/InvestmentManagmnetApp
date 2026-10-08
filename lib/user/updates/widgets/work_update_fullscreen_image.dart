import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';


void openWorkUpdateFullscreenImage(
  BuildContext context, {
  required String imageUrl,
  String title = '',
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder: (_, animation, secondaryAnimation) =>
          WorkUpdateFullscreenImagePage(
        imageUrl: imageUrl,
        title: title,
      ),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class WorkUpdateFullscreenImagePage extends StatelessWidget {
  const WorkUpdateFullscreenImagePage({
    super.key,
    required this.imageUrl,
    this.title = '',
  });

  final String imageUrl;
  final String title;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  cacheManager: WorkUpdateMediaCache.manager,
                  httpHeaders: WorkUpdateMediaCache.authHeaders(),
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: _shimmerBase,
                    highlightColor: _shimmerHighlight,
                    direction: ShimmerDirection.ltr,
                    child: const ColoredBox(color: _shimmerBase),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        ImageConstants.imageError,
                        width: 12.w,
                        height: 12.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white54,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        'Unable to load image',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 1.h,
              left: 2.w,
              right: 2.w,
              child: Row(
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 5.5.w,
                        ),
                      ),
                    ),
                  ),
                  if (title.trim().isNotEmpty) ...[
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
