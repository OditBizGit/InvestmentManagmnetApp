import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

/// Collection rate with 1 decimal and `%`, or an em dash when null (R22).
String formatCollectionRate(double? rate) =>
    rate == null ? '—' : '${rate.toStringAsFixed(1)}%';

/// Centered spinner, same look as the Staff Report loading state.
class ExpectedVsActualLoadingBox extends StatelessWidget {
  const ExpectedVsActualLoadingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 260,
      child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

/// Error text with a Retry button, same look as the Staff Report error state.
class ExpectedVsActualErrorBox extends StatelessWidget {
  const ExpectedVsActualErrorBox({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
