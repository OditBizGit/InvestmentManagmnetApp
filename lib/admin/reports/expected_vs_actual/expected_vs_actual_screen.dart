import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/month_range_picker.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';

import 'cubit/expected_vs_actual_cubit.dart';
import 'expected_vs_actual_details_screen.dart';
import 'model/expected_vs_actual_model.dart';
import 'repository/expected_vs_actual_repository.dart';
import 'widgets/expected_vs_actual_status_views.dart';
import 'widgets/expected_vs_actual_table_section.dart';

class ExpectedVsActualScreen extends StatefulWidget {
  const ExpectedVsActualScreen({super.key, this.isActive = false});

  /// True while this tab is visible in the admin IndexedStack.
  final bool isActive;

  @override
  State<ExpectedVsActualScreen> createState() => _ExpectedVsActualScreenState();
}

class _ExpectedVsActualScreenState extends State<ExpectedVsActualScreen> {
  late final ExpectedVsActualCubit _cubit;

  late DateTime _from;
  late DateTime _to;
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _cubit = ExpectedVsActualCubit(ExpectedVsActualRepository(getIt<Dio>()));
    _resetFilters();
    _refreshIfActive();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExpectedVsActualScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isActive && oldWidget.isActive && _selectedMonth != null) {
      _selectedMonth = null;
      _cubit.resetDetails();
    }

    // IndexedStack keeps this screen alive: reset and refetch on re-entry.
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _resetFilters();
        _selectedMonth = null;
      });
      _cubit.resetDetails();
      _refreshIfActive();
    }
  }

  void _resetFilters() {
    final range = defaultMonthRange();
    _from = range.from;
    _to = range.to;
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      _fetch();
    });
  }

  void _fetch() {
    _cubit.fetchReport(fromMonth: _from, toMonth: _to);
  }

  void _onRangeChanged(DateTime from, DateTime to) {
    setState(() {
      _from = from;
      _to = to;
    });
    _fetch();
  }

  void _openMonth(DateTime month) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedMonth = month);
  }

  void _backToList() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedMonth = null);
    _cubit.resetDetails();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedMonth;

    return BlocProvider.value(
      value: _cubit,
      child: selected != null
          ? ExpectedVsActualDetailsScreen(month: selected, onBack: _backToList)
          : _ExpectedVsActualContent(
              from: _from,
              to: _to,
              onRangeChanged: _onRangeChanged,
              onRetry: _fetch,
              onViewMonth: _openMonth,
            ),
    );
  }
}

class _ExpectedVsActualContent extends StatelessWidget {
  const _ExpectedVsActualContent({
    required this.from,
    required this.to,
    required this.onRangeChanged,
    required this.onRetry,
    required this.onViewMonth,
  });

  final DateTime from;
  final DateTime to;
  final void Function(DateTime from, DateTime to) onRangeChanged;
  final VoidCallback onRetry;
  final ValueChanged<DateTime> onViewMonth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocConsumer<ExpectedVsActualCubit, ExpectedVsActualState>(
            listenWhen: (previous, current) =>
                current.listStatus == ExpectedVsActualListStatus.failure &&
                previous.listStatus != ExpectedVsActualListStatus.failure &&
                current.listErrorMessage != null,
            listener: (context, state) {
              AppToast.error(state.listErrorMessage!, context: context);
            },
            buildWhen: (previous, current) =>
                previous.listStatus != current.listStatus ||
                previous.report != current.report ||
                previous.listErrorMessage != current.listErrorMessage,
            builder: (context, state) {
              final loading =
                  state.listStatus == ExpectedVsActualListStatus.loading ||
                  state.listStatus == ExpectedVsActualListStatus.initial;
              final hasData =
                  state.listStatus == ExpectedVsActualListStatus.success;
              final showRefetchProgress =
                  state.listStatus == ExpectedVsActualListStatus.loading &&
                  state.report.months.isNotEmpty;
              final error =
                  state.listStatus == ExpectedVsActualListStatus.failure
                  ? state.listErrorMessage
                  : null;

              return AdminMainScreenLayout(
                horizontalPadding: horizontalPadding,
                showRefetchProgress: showRefetchProgress,
                body: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const UserManagementSectionHeader(
                        title: 'Expected vs Actual',
                        subtitle: 'Expected versus collected amounts by month',
                      ),
                      const SizedBox(height: 16),
                      MonthRangePicker(
                        from: from,
                        to: to,
                        onChanged: onRangeChanged,
                        toastTitle: 'Expected vs Actual',
                      ),
                      const SizedBox(height: 16),
                      if (hasData) ...[
                        _StatCards(totals: state.report.totals),
                        const SizedBox(height: 18),
                      ],
                      ExpectedVsActualTableSection(
                        isLoading: loading,
                        errorMessage: error,
                        onRetry: onRetry,
                        months: state.report.months,
                        onViewMonth: (row) {
                          final month = row.month;
                          if (month != null) onViewMonth(month);
                        },
                      ),
                    ],
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

class _StatCards extends StatelessWidget {
  const _StatCards({required this.totals});

  final ExpectedVsActualRow totals;

  @override
  Widget build(BuildContext context) {
    return UserManagementStatCards(
      stats: [
        UserManagementStatCardData(
          label: 'Expected',
          value: CurrencyFormatter.format(totals.expectedAmount),
          icon: ImageConstants.amountReceivable,
          iconColor: const Color(0xFF9B7EBF),
          iconBg: const Color(0xFFF0EBF6),
        ),
        UserManagementStatCardData(
          label: 'Actual',
          value: CurrencyFormatter.format(totals.actualAmount),
          icon: ImageConstants.totalCollection,
          iconColor: const Color(0xFF2CB5A8),
          iconBg: const Color(0xFFE6F7F5),
        ),
        UserManagementStatCardData(
          label: 'Refunds',
          value: CurrencyFormatter.format(totals.refunds),
          icon: ImageConstants.amountRemaining,
          iconColor: const Color(0xFFE89A3C),
          iconBg: const Color(0xFFFFF3E8),
        ),
        UserManagementStatCardData(
          label: 'Collection Rate',
          value: formatCollectionRate(totals.collectionRate),
          icon: ImageConstants.investment,
          iconColor: const Color(0xFF9B7EBF),
          iconBg: const Color(0xFFF0EBF6),
        ),
      ],
    );
  }
}
