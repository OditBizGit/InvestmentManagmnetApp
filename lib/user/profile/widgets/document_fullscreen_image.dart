import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class DocumentFullscreenImage extends StatelessWidget {
  const DocumentFullscreenImage({
    super.key,
    required this.imageUrl,
    this.title = '',
  });

  final String imageUrl;
  final String title;

  static Future<void> open(
    BuildContext context, {
    required String imageUrl,
    String title = '',
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, animation, secondaryAnimation) =>
            DocumentFullscreenImage(
          imageUrl: imageUrl,
          title: title,
        ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, _, _) => Column(
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
