import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:toastification/toastification.dart';

/// App-wide toast helpers built on [toastification].
class AppToast {
  AppToast._();

  static const Duration _duration = Duration(seconds: 3);

  static void success(
    String message, {
    String title = 'Success',
    BuildContext? context,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: _duration,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12),
      primaryColor: AppColors.accent,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }

  static void error(
    String message, {
    String title = 'Error',
    BuildContext? context,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: _duration,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12),
      primaryColor: AppColors.error,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }

  static void info(
    String message, {
    String title = 'Info',
    BuildContext? context,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: _duration,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12),
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }
}
