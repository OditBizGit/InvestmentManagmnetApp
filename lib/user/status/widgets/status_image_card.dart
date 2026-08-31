import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_card_actions.dart';
import 'package:sizer/sizer.dart';

class StatusImageCard extends StatelessWidget {
  const StatusImageCard({
    super.key,
    required this.imageUrl,
    this.onCopy,
    this.onShare,
    this.onDownload,
    this.onView,
  });

  final String imageUrl;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onView;

  static const Color _label = Color(0xFFB0B0B0);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _accent = Color(0xFFA28CC1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: _accentSoft,
                  child: Icon(
                    Icons.image_outlined,
                    color: _accent,
                    size: 10.w,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: _accentSoft,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
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
