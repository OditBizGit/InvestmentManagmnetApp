import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
    EdgeInsetsGeometry? margin,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: margin,
          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
          content: _AppSnackBarContent(
            message: message,
            icon: icon,
          ),
        ),
      );
  }

  /// Shows a floating progress snackbar. Call [AppSnackBarProgressController.update]
  /// as bytes arrive, then [AppSnackBarProgressController.close] when finished.
  /// Set [onCancel] to show a Cancel action while the download is running.
  static AppSnackBarProgressController showProgress(
    BuildContext context, {
    String message = 'Downloading...',
    IconData icon = Icons.download_rounded,
    EdgeInsetsGeometry? margin,
    VoidCallback? onCancel,
  }) {
    final controller = AppSnackBarProgressController._(onCancel: onCancel);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(days: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: margin,
          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
          dismissDirection: DismissDirection.none,
          content: _AppSnackBarProgressContent(
            controller: controller,
            message: message,
            icon: icon,
          ),
        ),
      );

    return controller;
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

class AppSnackBarProgressController {
  AppSnackBarProgressController._({this.onCancel})
      : canCancel = ValueNotifier<bool>(onCancel != null);

  final VoidCallback? onCancel;
  final ValueNotifier<double?> progress = ValueNotifier<double?>(null);
  final ValueNotifier<String?> label = ValueNotifier<String?>(null);
  final ValueNotifier<bool> canCancel;
  bool _closed = false;
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  /// [value] is 0.0–1.0. Pass `null` for an indeterminate bar.
  void update(double? value, {String? message}) {
    if (_closed) return;
    if (value != null) {
      progress.value = value.clamp(0.0, 1.0);
    } else {
      progress.value = null;
    }
    if (message != null) {
      label.value = message;
    }
  }

  /// Hides the Cancel action (e.g. while writing to gallery after download).
  void setCancelEnabled(bool enabled) {
    if (_closed || _cancelled) return;
    canCancel.value = enabled && onCancel != null;
  }

  void cancel() {
    if (_closed || _cancelled || onCancel == null) return;
    _cancelled = true;
    canCancel.value = false;
    label.value = 'Cancelling...';
    onCancel!();
  }

  void close() {
    if (_closed) return;
    _closed = true;
    canCancel.value = false;
    // SnackBar reverse animation keeps content mounted briefly.
    Future.delayed(const Duration(milliseconds: 500), () {
      progress.dispose();
      label.dispose();
      canCancel.dispose();
    });
  }
}

class _AppSnackBarContent extends StatelessWidget {
  const _AppSnackBarContent({
    required this.message,
    this.icon,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 5.w,
              color: AppColors.accent,
            ),
            SizedBox(width: 2.5.w),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppSnackBarProgressContent extends StatelessWidget {
  const _AppSnackBarProgressContent({
    required this.controller,
    required this.message,
    required this.icon,
  });

  final AppSnackBarProgressController controller;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ValueListenableBuilder<String?>(
        valueListenable: controller.label,
        builder: (context, label, _) {
          return ValueListenableBuilder<double?>(
            valueListenable: controller.progress,
            builder: (context, progress, _) {
              final percent = progress == null
                  ? null
                  : (progress * 100).clamp(0, 100).round();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 5.w,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Text(
                          label ?? message,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        percent == null ? '...' : '$percent%',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.canCancel,
                        builder: (context, showCancel, _) {
                          if (!showCancel || controller.onCancel == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: TextButton(
                              onPressed: controller.cancel,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.4.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 0.7.h,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
