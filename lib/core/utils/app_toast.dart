import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:toastification/toastification.dart';

/// App-wide toast helpers built on [toastification].
class AppToast {
  AppToast._();

  static const Duration _duration = Duration(seconds: 3);

  /// Shows a toast after the current frame to avoid racing toastification's
  /// AnimatedList AnimationController dispose during rebuilds/dialog closes.
  static void _show({
    required ToastificationType type,
    required String title,
    required String message,
    required Color primaryColor,
    BuildContext? context,
  }) {
    void present() {
      try {
        toastification.dismissAll(delayForAnimation: false);
      } catch (_) {
        // Ignore dispose races while clearing previous toasts.
      }

      toastification.show(
        context: context,
        type: type,
        style: ToastificationStyle.flatColored,
        title: Text(title),
        description: Text(message),
        alignment: Alignment.topRight,
        autoCloseDuration: _duration,
        showProgressBar: false,
        borderRadius: BorderRadius.circular(12),
        primaryColor: primaryColor,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        closeOnClick: true,
        pauseOnHover: true,
      );
    }

    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      present();
    } else {
      scheduler.addPostFrameCallback((_) => present());
    }
  }

  static void success(
    String message, {
    String title = 'Success',
    BuildContext? context,
  }) {
    _show(
      type: ToastificationType.success,
      title: title,
      message: message,
      primaryColor: AppColors.accent,
      context: context,
    );
  }

  static void error(
    String message, {
    String title = 'Error',
    BuildContext? context,
  }) {
    _show(
      type: ToastificationType.error,
      title: title,
      message: message,
      primaryColor: AppColors.error,
      context: context,
    );
  }

  static void info(
    String message, {
    String title = 'Info',
    BuildContext? context,
  }) {
    _show(
      type: ToastificationType.info,
      title: title,
      message: message,
      primaryColor: AppColors.accent,
      context: context,
    );
  }
}
