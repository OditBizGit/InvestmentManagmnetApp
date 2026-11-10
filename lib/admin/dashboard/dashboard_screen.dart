import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/cubit/dashboard_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/widgets/dashboard_overview.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.isActive) {
        context.read<DashboardCubit>().loadDashboard();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AdminHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // IndexedStack keeps this screen alive — refresh when Dashboard is opened again.
    if (widget.isActive && !oldWidget.isActive) {
      context.read<DashboardCubit>().loadDashboard();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() {
    return context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocBuilder<DashboardCubit, DashboardState>(
            buildWhen: (previous, current) =>
                previous.dashboardLoading != current.dashboardLoading ||
                previous.dashboardLoaded != current.dashboardLoaded ||
                previous.dashboard != current.dashboard,
            builder: (context, state) {
              final showRefetchProgress = state.dashboardLoading &&
                  (state.dashboard != null || state.dashboardLoaded);

              return AdminMainScreenLayout(
                horizontalPadding: horizontalPadding,
                showRefetchProgress: showRefetchProgress,
                body: RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: _onRefresh,
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: const DashboardOverview(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
