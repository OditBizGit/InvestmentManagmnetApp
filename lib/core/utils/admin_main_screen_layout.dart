import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';

/// Thin indeterminate bar shown under [AdminTopBar] while refetching with
/// cached content still on screen.
class AdminRefetchProgressBar extends StatelessWidget {
  const AdminRefetchProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: ClipRRect(
        child: LinearProgressIndicator(
          minHeight: 3,
          color: AppColors.accent,
          backgroundColor: Color(0xFFE8E6EC),
        ),
      ),
    );
  }
}

/// Standard admin tab shell: top bar, optional refetch progress, body.
class AdminMainScreenLayout extends StatelessWidget {
  const AdminMainScreenLayout({
    super.key,
    required this.horizontalPadding,
    required this.body,
    this.showRefetchProgress = false,
  });

  final double horizontalPadding;
  final Widget body;
  final bool showRefetchProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            16,
          ),
          child: const AdminTopBar(),
        ),
        if (showRefetchProgress) const AdminRefetchProgressBar(),
        Expanded(child: body),
      ],
    );
  }
}

/// Centered loader for first paint when there is no cached data yet.
class AdminInitialLoadingBody extends StatelessWidget {
  const AdminInitialLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.accent,
      ),
    );
  }
}
