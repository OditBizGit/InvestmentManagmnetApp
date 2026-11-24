import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/investor_statement_pdf.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import 'cubit/investor_statement_cubit.dart';
import 'model/investor_option.dart';
import 'model/investor_statement_model.dart';
import 'repository/investor_statement_repository.dart';
import 'widgets/investor_statement_filters.dart';
import 'widgets/investor_statement_header_card.dart';
import 'widgets/investor_statement_status_views.dart';
import 'widgets/investor_statement_tables.dart';

class InvestorStatementScreen extends StatefulWidget {
  const InvestorStatementScreen({super.key, this.isActive = false});

  /// True while this tab is visible in the admin IndexedStack.
  final bool isActive;

  @override
  State<InvestorStatementScreen> createState() =>
      _InvestorStatementScreenState();
}

class _InvestorStatementScreenState extends State<InvestorStatementScreen> {
  late final InvestorStatementCubit _cubit;

  InvestorOption? _selected;
  DateTime? _from;
  DateTime? _to;

  /// Bumped on re-activation so the picker remounts with an empty field.
  int _filtersResetKey = 0;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final dio = getIt<Dio>();
    _cubit = InvestorStatementCubit(
      repository: InvestorStatementRepository(dio),
      investorsRepository: getIt.isRegistered<InvestorsRepository>()
          ? getIt<InvestorsRepository>()
          : InvestorsRepository(dio: dio),
    );
    _refreshIfActive();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InvestorStatementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // IndexedStack keeps this screen alive: reset and refetch on re-entry.
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _selected = null;
        _from = null;
        _to = null;
        _filtersResetKey++;
      });
      _cubit.clearStatement();
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      _cubit.loadInvestors();
    });
  }

  void _fetchStatement() {
    final selected = _selected;
    if (selected == null) return;
    _cubit.fetchStatement(
      userId: selected.userId,
      fromDate: _from,
      toDate: _to,
    );
  }

  void _onSelected(InvestorOption option) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selected = option);
    _fetchStatement();
  }

  void _onCleared() {
    setState(() => _selected = null);
    _cubit.clearStatement();
  }

  void _onFromChanged(DateTime? value) {
    setState(() {
      _from = value;
      if (value != null && _to != null && value.isAfter(_to!)) _to = value;
    });
    _fetchStatement();
  }

  void _onToChanged(DateTime? value) {
    setState(() {
      _to = value;
      if (value != null && _from != null && value.isBefore(_from!)) {
        _from = value;
      }
    });
    _fetchStatement();
  }

  Future<void> _export(InvestorStatement statement) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final result = await InvestorStatementPdf.generateAndSave(statement);
      if (!mounted) return;
      AppToast.success(
        result.message,
        title: 'Investor Statement',
        context: context,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.error(
        'Could not export the statement. Please try again.',
        title: 'Investor Statement',
        context: context,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ColoredBox(
        color: AppColors.screenBg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;

            return MultiBlocListener(
              listeners: [
                BlocListener<InvestorStatementCubit, InvestorStatementState>(
                  listenWhen: (p, c) =>
                      c.statementStatus == InvestorStatementStatus.failure &&
                      p.statementStatus != InvestorStatementStatus.failure &&
                      c.statementErrorMessage != null,
                  listener: (context, state) => AppToast.error(
                    state.statementErrorMessage!,
                    context: context,
                  ),
                ),
                BlocListener<InvestorStatementCubit, InvestorStatementState>(
                  listenWhen: (p, c) =>
                      c.investorsStatus ==
                          InvestorStatementInvestorsStatus.failure &&
                      p.investorsStatus !=
                          InvestorStatementInvestorsStatus.failure &&
                      c.investorsErrorMessage != null,
                  listener: (context, state) => AppToast.error(
                    state.investorsErrorMessage!,
                    context: context,
                  ),
                ),
              ],
              child: BlocBuilder<InvestorStatementCubit, InvestorStatementState>(
                builder: (context, state) {
                  final loaded =
                      state.statementStatus == InvestorStatementStatus.success;

                  return AdminMainScreenLayout(
                    horizontalPadding: horizontalPadding,
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
                          UserManagementSectionHeader(
                            title: 'Investor Statement',
                            subtitle:
                                'Ledger and installment schedule per investor',
                            trailing: _ExportButton(
                              enabled: loaded && !_exporting,
                              onPressed: () => _export(state.statement),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Filters(
                            key: ValueKey(_filtersResetKey),
                            state: state,
                            from: _from,
                            to: _to,
                            onSelected: _onSelected,
                            onCleared: _onCleared,
                            onFromChanged: _onFromChanged,
                            onToChanged: _onToChanged,
                            onRetryInvestors: _cubit.loadInvestors,
                          ),
                          const SizedBox(height: 16),
                          _Body(state: state, onRetry: _fetchStatement),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
        label: Text(
          'Export PDF',
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    super.key,
    required this.state,
    required this.from,
    required this.to,
    required this.onSelected,
    required this.onCleared,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onRetryInvestors,
  });

  final InvestorStatementState state;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<InvestorOption> onSelected;
  final VoidCallback onCleared;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;
  final VoidCallback onRetryInvestors;

  @override
  Widget build(BuildContext context) {
    final investorsFailed =
        state.investorsStatus == InvestorStatementInvestorsStatus.failure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InvestorStatementPicker(
              investors: state.investors,
              isLoading:
                  state.investorsStatus ==
                  InvestorStatementInvestorsStatus.loading,
              onSelected: onSelected,
              onCleared: onCleared,
            ),
            InvestorStatementDateField(
              label: 'From',
              value: from,
              onChanged: onFromChanged,
            ),
            InvestorStatementDateField(
              label: 'To',
              value: to,
              onChanged: onToChanged,
            ),
          ],
        ),
        if (investorsFailed) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  state.investorsErrorMessage ?? '',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: onRetryInvestors,
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onRetry});

  final InvestorStatementState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (state.statementStatus) {
      case InvestorStatementStatus.initial:
        return const InvestorStatementPlaceholder();
      case InvestorStatementStatus.loading:
        return const InvestorStatementLoadingBox();
      case InvestorStatementStatus.failure:
        return InvestorStatementErrorBox(
          message: state.statementErrorMessage ?? '',
          onRetry: onRetry,
        );
      case InvestorStatementStatus.success:
        final header = state.statement.header;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserManagementStatCards(
              stats: [
                UserManagementStatCardData(
                  label: 'Commitment',
                  value: CurrencyFormatter.format(header.commitmentAmount),
                  icon: ImageConstants.investment,
                  iconColor: const Color(0xFF9B7EBF),
                  iconBg: const Color(0xFFF0EBF6),
                ),
                UserManagementStatCardData(
                  label: 'Net Paid',
                  value: CurrencyFormatter.format(header.netPaid),
                  icon: ImageConstants.totalCollection,
                  iconColor: const Color(0xFF2CB5A8),
                  iconBg: const Color(0xFFE6F7F5),
                ),
                UserManagementStatCardData(
                  label: 'Discount',
                  value: CurrencyFormatter.format(header.discount),
                  icon: ImageConstants.amountReceivable,
                  iconColor: const Color(0xFF9B7EBF),
                  iconBg: const Color(0xFFF0EBF6),
                ),
                UserManagementStatCardData(
                  label: 'Pending',
                  value: CurrencyFormatter.format(header.pending),
                  icon: ImageConstants.amountRemaining,
                  iconColor: const Color(0xFFE89A3C),
                  iconBg: const Color(0xFFFFF3E8),
                ),
              ],
            ),
            const SizedBox(height: 18),
            InvestorStatementHeaderCard(header: header),
            const SizedBox(height: 18),
            InvestorStatementLedgerSection(entries: state.statement.ledger),
            const SizedBox(height: 18),
            InvestorStatementScheduleSection(items: state.statement.schedule),
          ],
        );
    }
  }
}
