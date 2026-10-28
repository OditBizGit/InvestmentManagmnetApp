import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/repository/pending_request_repository.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_requests_list_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/pending_requests/widgets/pending_requests_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/review_request_screen.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
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
  String? _selectedRequestId;

  @override
  void initState() {
    super.initState();
    _refreshIfActive();
  }

  @override
  void didUpdateWidget(covariant _PendingRequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      context.read<PendingRequestsCubit>().loadRequests();
    });
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
                            PendingRequestsOverviewSection(overview: overview)
                          else
                            const UserManagementSectionHeader(
                              title: 'Pending Requests',
                              subtitle:
                                  'Review and approve investor payment requests',
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
