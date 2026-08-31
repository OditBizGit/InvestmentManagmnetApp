import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StatusCardActions extends StatelessWidget {
  const StatusCardActions({
    super.key,
    this.onCopy,
    this.onShare,
    this.onDownload,
    this.onView,
  });

  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onView;

  static const Color _iconMuted = Color(0xFF9E9E9E);
  static const Color _copyBg = Color(0xFFF0F0F0);
  static const Color _shareBg = Color(0xFFD4EDE0);
  static const Color _shareIcon = Color(0xFF4CAF7A);
  static const Color _downloadBg = Color(0xFFE8F4FC);
  static const Color _downloadIcon = Color(0xFF64B5F6);
  static const Color _viewBg = Color(0xFFF0EBF6);
  static const Color _viewIcon = Color(0xFFA28CC1);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.copy_rounded,
          background: _copyBg,
          iconColor: _iconMuted,
          onTap: onCopy,
        ),
        SizedBox(width: 2.w),
        _ActionButton(
          icon: Icons.share_rounded,
          background: _shareBg,
          iconColor: _shareIcon,
          onTap: onShare,
        ),
        SizedBox(width: 2.w),
        _ActionButton(
          icon: Icons.download_rounded,
          background: _downloadBg,
          iconColor: _downloadIcon,
          onTap: onDownload,
        ),
        SizedBox(width: 2.w),
        _ActionButton(
          icon: Icons.visibility_outlined,
          background: _viewBg,
          iconColor: _viewIcon,
          onTap: onView,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 9.w,
          height: 9.w,
          child: Icon(icon, size: 4.5.w, color: iconColor),
        ),
      ),
    );
  }
}
