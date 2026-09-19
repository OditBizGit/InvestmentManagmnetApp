import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

/// Shared “Go to top” FAB used on user scroll screens.
class GoToTopButton extends StatelessWidget {
  const GoToTopButton({super.key, required this.onTap});

  static const double nearTopOffset = 60;
  static const double nearBottomRemaining = 380;
  static const Duration scrollToTopDuration = Duration(milliseconds: 450);
  static const Duration fabAnimDuration = Duration(milliseconds: 260);

  final VoidCallback onTap;

  static bool shouldShow({
    required double offset,
    required double maxExtent,
  }) {
    if (maxExtent <= 0) return false;
    final nearTop = offset <= nearTopOffset;
    final nearBottom = maxExtent - offset <= nearBottomRemaining ||
        offset / maxExtent >= 0.8;
    return nearBottom && !nearTop;
  }

  static Future<void> animateToTop(ScrollController controller) {
    if (!controller.hasClients) return Future<void>.value();
    return controller.animateTo(
      0,
      duration: scrollToTopDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = 11.5.w;

    return Tooltip(
      message: 'Go to top',
      child: Material(
        color: AppColors.accent,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: AppColors.accent.withValues(alpha: 0.45),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Colors.white,
              size: 7.w,
            ),
          ),
        ),
      ),
    );
  }
}

class GoToTopOverlay extends StatelessWidget {
  const GoToTopOverlay({
    super.key,
    required this.visible,
    required this.onTap,
    this.right,
    this.bottom,
  });

  final bool visible;
  final VoidCallback onTap;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right ?? 4.w,
      bottom: bottom ?? 0.5.h,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedScale(
          scale: visible ? 1 : 0.86,
          duration: GoToTopButton.fabAnimDuration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: GoToTopButton.fabAnimDuration,
            curve: Curves.easeOutCubic,
            child: GoToTopButton(onTap: onTap),
          ),
        ),
      ),
    );
  }
}
