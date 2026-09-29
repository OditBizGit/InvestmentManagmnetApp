import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/cubit/report__cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/repository/report_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_overview_cards.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_recent_transactions_table.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AddPhaseRepository>(
          create: (_) => AddPhaseRepository(dio: getIt<Dio>()),
        ),
        RepositoryProvider<InvestorPaymentRepository>(
          create: (_) => InvestorPaymentRepository(dio: getIt<Dio>()),
        ),
        RepositoryProvider<ReportRepository>(
          create: (_) => ReportRepository(dio: getIt<Dio>()),
        ),
      ],
      child: BlocProvider(
        create: (context) => ReportCubit(
          phaseRepository: context.read<AddPhaseRepository>(),
          paymentRepository: context.read<InvestorPaymentRepository>(),
          overviewRepository:
              context.read<ReportRepository>(),
        )..loadReports(),
        child: _AdminReportsView(isActive: isActive),
      ),
    );
  }
}

class _AdminReportsView extends StatefulWidget {
  const _AdminReportsView({required this.isActive});

  final bool isActive;

  @override
  State<_AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<_AdminReportsView> {
  String? _lastWorkProgressError;
  String? _lastTransactionsError;
  String? _lastFundingOverviewError;

  @override
  void didUpdateWidget(covariant _AdminReportsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // IndexedStack keeps this screen alive — refresh whenever Reports is opened.
    if (widget.isActive && !oldWidget.isActive) {
      context.read<ReportCubit>().loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportCubit, ReportState>(
      listener: (context, state) {
        final workError = state.workProgressError;
        if (workError != null &&
            workError.isNotEmpty &&
            workError != _lastWorkProgressError) {
          _lastWorkProgressError = workError;
          AppToast.error(
            workError,
            title: 'Work Progress',
            context: context,
          );
        } else if (workError == null) {
          _lastWorkProgressError = null;
        }

        final txError = state.transactionsError;
        if (txError != null &&
            txError.isNotEmpty &&
            txError != _lastTransactionsError) {
          _lastTransactionsError = txError;
          AppToast.error(
            txError,
            title: 'Recent Transactions',
            context: context,
          );
        } else if (txError == null) {
          _lastTransactionsError = null;
        }

        final overviewError = state.fundingOverviewError;
        if (overviewError != null &&
            overviewError.isNotEmpty &&
            overviewError != _lastFundingOverviewError) {
          _lastFundingOverviewError = overviewError;
          AppToast.error(
            overviewError,
            title: 'Funding & Payments Overview',
            context: context,
          );
        } else if (overviewError == null) {
          _lastFundingOverviewError = null;
        }
      },
      child: ColoredBox(
        color: AppColors.screenBg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < 600 ? 16.0 : 24.0;

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
                  child: RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () => context.read<ReportCubit>().loadReports(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReportsOverviewCards(),
                          SizedBox(height: 20),
                          ReportsDetailsSection(),
                          SizedBox(height: 20),
                          ReportsRecentTransactionsTable(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
