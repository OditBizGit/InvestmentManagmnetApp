import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_nav_permissions.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/repository/pending_request_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_requests_list_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_requests_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/review_request_screen.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import '../../cubit/pending_requests_cubit.dart';
import '../../model/pending_request_model.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final role = getIt<LocalStorage>().getUserRole();
    if (!AdminNavPermissions.canAccessPendingRequests(role)) {
      return const _PendingRequestsAccessDenied();
    }

    return RepositoryProvider(
      create: (_) => PaymentRequestRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => PendingRequestsCubit(
          repository: context.read<PaymentRequestRepository>(),
          paymentRepository: getIt<InvestorPaymentRepository>(),
        ),
        child: _PendingRequestsView(isActive: isActive),
      ),
    );
  }
}

class _PendingRequestsView extends StatefulWidget {
  const _PendingRequestsView({required this.isActive});

  final bool isActive;

  @override
  State<_PendingRequestsView> createState() => _PendingRequestsViewState();
}

class _PendingRequestsViewState extends State<_PendingRequestsView> {
  static const _silentRefreshInterval = Duration(minutes: 1);

  String? _selectedRequestId;
  Timer? _silentRefreshTimer;
  bool _isSilentRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshIfActive();
    if (widget.isActive) {
      _startSilentRefresh();
    }
  }

  @override
  void didUpdateWidget(covariant _PendingRequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;

    if (widget.isActive) {
      _refreshIfActive();
      _startSilentRefresh();
    } else {
      _stopSilentRefresh();
    }
  }

  @override
  void dispose() {
    _stopSilentRefresh();
    super.dispose();
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      context.read<PendingRequestsCubit>().loadRequests();
    });
  }

  void _startSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = Timer.periodic(
      _silentRefreshInterval,
      (_) => _silentRefresh(),
    );
  }

  void _stopSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = null;
  }

  Future<void> _silentRefresh() async {
    if (!mounted ||
        !widget.isActive ||
        _selectedRequestId != null ||
        _isSilentRefreshing) {
      return;
    }

    _isSilentRefreshing = true;
    try {
      await context.read<PendingRequestsCubit>().loadRequests(silent: true);
    } finally {
      _isSilentRefreshing = false;
    }
  }

  void _manualRefresh() {
    context.read<PendingRequestsCubit>().loadRequests();
  }

  void _openRequest(PendingRequestModel request) {
    setState(() => _selectedRequestId = request.id);
  }

  void _backToRequests() {
    setState(() => _selectedRequestId = null);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRequestId = _selectedRequestId;
    if (selectedRequestId != null) {
      return ReviewRequestScreen(
        requestId: selectedRequestId,
        onBack: _backToRequests,
      );
    }

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocBuilder<PendingRequestsCubit, PendingRequestsState>(
            builder: (context, state) {
              final overview = switch (state) {
                PendingRequestsSuccess(:final overview) => overview,
                PendingRequestsFailure(:final overview) => overview,
                _ => PendingRequestsOverviewStats.empty,
              };
              final showOverview = state is PendingRequestsSuccess ||
                  state is PendingRequestsFailure;
              final isRefreshing = state is PendingRequestsLoading ||
                  (state is PendingRequestsSuccess && state.isListLoading);

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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showOverview)
                            PendingRequestsOverviewSection(
                              overview: overview,
                              onRefresh: isRefreshing ? null : _manualRefresh,
                              isRefreshing: isRefreshing,
                            )
                          else
                            UserManagementSectionHeader(
                              title: 'Pending Requests',
                              subtitle:
                                  'Review and approve investor payment requests',
                              trailing: _RefreshButton(
                                onPressed:
                                    isRefreshing ? null : _manualRefresh,
                                isRefreshing: isRefreshing,
                              ),
                            ),
                          const SizedBox(height: 20),
                          PendingRequestsListSection(onReview: _openRequest),
                        ],
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

class _PendingRequestsAccessDenied extends StatelessWidget {
  const _PendingRequestsAccessDenied();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'Access restricted',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pending Requests is available only for Marketing Manager accounts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({
    required this.onPressed,
    required this.isRefreshing,
  });

  final VoidCallback? onPressed;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh',
      onPressed: onPressed,
      icon: isRefreshing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.accent,
              ),
            )
          : const Icon(
              Icons.refresh_rounded,
              color: AppColors.accent,
            ),
    );
  }
}
