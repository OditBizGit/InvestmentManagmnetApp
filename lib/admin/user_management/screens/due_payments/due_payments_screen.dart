import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/cubit/due_payments_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/repository/due_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/due_payments_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/due_payments_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';

class DuePaymentsScreen extends StatelessWidget {
  const DuePaymentsScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => PaymentStatusReportRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => DuePaymentsCubit(
          context.read<PaymentStatusReportRepository>(),
        ),
        child: _DuePaymentsView(isActive: isActive),
      ),
    );
  }
}

class _DuePaymentsView extends StatefulWidget {
  const _DuePaymentsView({required this.isActive});

  final bool isActive;

  @override
  State<_DuePaymentsView> createState() => _DuePaymentsViewState();
}

class _DuePaymentsViewState extends State<_DuePaymentsView> {
  @override
  void initState() {
    super.initState();
    _refreshIfActive();
  }

  @override
  void didUpdateWidget(covariant _DuePaymentsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      context.read<DuePaymentsCubit>().fetchPaymentStatusReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocBuilder<DuePaymentsCubit, DuePaymentsState>(
            builder: (context, state) {
              final overview = switch (state) {
                DuePaymentsSuccess(:final overview) => overview,
                DuePaymentsEmpty(:final overview) => overview,
                DuePaymentsFailure(:final overview) => overview,
                _ => null,
              };
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
                          if (overview != null)
                            DuePaymentsOverviewSection(
                              totalOutstandingDues:
                                  overview.totalOutstandingDues,
                              usersWithPendingDues:
                                  overview.usersWithPendingDues,
                              partiallyPaidUsers:
                                  overview.partiallyPaidUsers,
                              fullyPaidUsers: overview.fullyPaidUsers,
                            )
                          else
                            const UserManagementSectionHeader(
                              title: 'Due Payments',
                              subtitle:
                                  'Track outstanding dues and follow up with payment reminders',
                            ),
                          const SizedBox(height: 20),
                          const DuePaymentsTableSection(),
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
