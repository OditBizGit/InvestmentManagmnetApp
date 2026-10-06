import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_card_actions.dart';
import 'package:maribel_wellness_centre_application/user/updates/widgets/work_update_inline_video.dart';
import 'package:sizer/sizer.dart';

class StatusVideoCard extends StatefulWidget {
  const StatusVideoCard({
    super.key,
    required this.videoUrl,
    this.title = '',
    this.description = '',
    this.isActive = true,
    this.onCopy,
    this.onShare,
    this.onDownload,
    this.onView,
  });

  final String videoUrl;
  final String title;
  final String description;
  final bool isActive;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onView;

  @override
  State<StatusVideoCard> createState() => _StatusVideoCardState();
}

class _StatusVideoCardState extends State<StatusVideoCard> {
  static const Color _videoAccent = Color(0xFF7EC8D4);
  static const Color _label = Color(0xFF7EC8D4);

  final GlobalKey<WorkUpdateInlineVideoState> _videoKey =
      GlobalKey<WorkUpdateInlineVideoState>();

  Future<void> _openFullscreen() async {
    await _videoKey.currentState?.openFullscreen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _videoAccent.withValues(alpha: 0.55)),
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
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.isActive
                  ? WorkUpdateInlineVideo(
                      key: _videoKey,
                      videoUrl: widget.videoUrl,
                      title: widget.title,
                    )
                  : ColoredBox(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.videocam_rounded,
                        color: Colors.grey.shade600,
                        size: 10.w,
                      ),
                    ),
            ),
          ),
          if (widget.title.trim().isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
          if (widget.description.trim().isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Text(
              widget.description,
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
                'VIDEO',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: _label,
                ),
              ),
              const Spacer(),
              StatusCardActions(
                onCopy: widget.onCopy,
                onShare: widget.onShare,
                onDownload: widget.onDownload,
                onView: widget.isActive ? _openFullscreen : widget.onView,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
