import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_card_actions.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class StatusImageCard extends StatelessWidget {
  const StatusImageCard({
    super.key,
    required this.imageUrl,
    this.title = '',
    this.description = '',
    this.onCopy,
    this.onShare,
    this.onDownload,
    this.onView,
  });

  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onView;

  static const Color _label = Color(0xFFB0B0B0);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _accent = Color(0xFFA28CC1);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                cacheManager: WorkUpdateMediaCache.manager,
                httpHeaders: WorkUpdateMediaCache.authHeaders(),
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (context, url, error) => Container(
                  color: _accentSoft,
                  child: Icon(
                    Icons.image_outlined,
                    color: _accent,
                    size: 10.w,
                  ),
                ),
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: _shimmerBase,
                  highlightColor: _shimmerHighlight,
                  direction: ShimmerDirection.ltr,
                  child: const ColoredBox(color: _shimmerBase),
                ),
              ),
            ),
          ),
          if (title.trim().isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
          if (description.trim().isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 1.4.h),
          Row(
            children: [
              Text(
                'IMAGE',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: _label,
                ),
              ),
              const Spacer(),
              StatusCardActions(
                onCopy: onCopy,
                onShare: onShare,
                onDownload: onDownload,
                onView: onView,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
