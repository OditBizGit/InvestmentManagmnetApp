import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/widgets/funding_limit_warning_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/add_new_investor.dart';
import 'package:maribel_wellness_centre_application/admin/investors/cubit/investors_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/investors_screen/widgets/investors_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/investors_screen/widgets/investors_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/repository/create_project_repository.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/success_screen.dart';

class AdminInvestorsScreen extends StatelessWidget {
  const AdminInvestorsScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InvestorsCubit>()..fetchInvestors(),
      child: _AdminInvestorsView(isActive: isActive),
    );
  }
}

class _AdminInvestorsView extends StatefulWidget {
  const _AdminInvestorsView({required this.isActive});

  final bool isActive;

  @override
  State<_AdminInvestorsView> createState() => _AdminInvestorsViewState();
}

class _AdminInvestorsViewState extends State<_AdminInvestorsView> {
  bool _showAddInvestor = false;
  InvestorModel? _editingInvestor;
  bool _limitDialogShownForVisit = false;
  double? _projectTotalFund;

  @override
  void initState() {
    super.initState();
    _loadProjectTotalFund();
  }

  @override
  void didUpdateWidget(covariant _AdminInvestorsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _limitDialogShownForVisit = false;
      context.read<InvestorsCubit>().fetchInvestors();
      _loadProjectTotalFund();
    }
  }

  Future<void> _loadProjectTotalFund() async {
    try {
      final response =
          await ProjectRepository(dio: getIt<Dio>()).getProjects();
      if (!mounted) return;
      final projects = response?.data ?? [];
      final fund = projects.isEmpty ? null : projects.first.totalFund;
      setState(() {
        _projectTotalFund = fund != null && fund > 0 ? fund : null;
      });

      final state = context.read<InvestorsCubit>().state;
      if (state is InvestorsSuccess) {
        final totalInvestment = state.total.totalInvestmentAmount > 0
            ? state.total.totalInvestmentAmount
            : state.investors.fold<double>(
                0,
                (sum, investor) => sum + investor.totalInvestmentAmount,
              );
        await _maybeShowFundingLimitDialog(
          totalInvestment: totalInvestment,
        );
      }
    } catch (_) {
      // Keep last known project fund.
    }
  }

  Future<void> _maybeShowFundingLimitDialog({
    required double totalInvestment,
  }) async {
    if (!widget.isActive ||
        _showAddInvestor ||
        _limitDialogShownForVisit) {
      return;
    }

    final kind = FundingLimitWarningDialog.resolveKind(
      projectAmount: _projectTotalFund,
      totalInvestment: totalInvestment,
    );
    if (kind == null) return;

    _limitDialogShownForVisit = true;
    await Future<void>.delayed(Duration.zero);
    if (!mounted || !widget.isActive || _showAddInvestor) return;

    await FundingLimitWarningDialog.showIfNeeded(
      context,
      projectAmount: _projectTotalFund,
      totalInvestment: totalInvestment,
    );
  }

  void _openAddInvestor() {
    setState(() {
      _editingInvestor = null;
      _showAddInvestor = true;
    });
  }

  void _openEditInvestor(InvestorModel investor) {
    setState(() {
      _editingInvestor = investor;
      _showAddInvestor = true;
    });
  }

  void _backToInvestors() {
    setState(() {
      _showAddInvestor = false;
      _editingInvestor = null;
    });
  }

  Future<void> _showAddSuccess() async {
    setState(() {
      _showAddInvestor = false;
      _editingInvestor = null;
    });
    _limitDialogShownForVisit = false;
    await context.read<InvestorsCubit>().fetchInvestors();
    await _loadProjectTotalFund();

    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SuccessScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _showUpdateSuccess() async {
    setState(() {
      _showAddInvestor = false;
      _editingInvestor = null;
    });
    _limitDialogShownForVisit = false;
    await context.read<InvestorsCubit>().fetchInvestors();
    await _loadProjectTotalFund();
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddInvestor) {
      return AddNewInvestorScreen(
        investorToEdit: _editingInvestor,
        onBack: _backToInvestors,
        onAddSuccess: _showAddSuccess,
        onUpdateSuccess: _showUpdateSuccess,
      );
    }

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocConsumer<InvestorsCubit, InvestorsState>(
            listener: (context, state) {
              if (state is InvestorsFailure) {
                AppToast.error(state.message, context: context);
                return;
              }
              if (state is InvestorsSuccess) {
                final totalInvestment = state.total.totalInvestmentAmount > 0
                    ? state.total.totalInvestmentAmount
                    : state.investors.fold<double>(
                        0,
                        (sum, investor) =>
                            sum + investor.totalInvestmentAmount,
                      );
                _maybeShowFundingLimitDialog(
                  totalInvestment: totalInvestment,
                );
              }
            },
            builder: (context, state) {
              final investors = state is InvestorsSuccess
                  ? state.investors
                  : <InvestorModel>[];
              final totals = state is InvestorsSuccess
                  ? state.total
                  : const InvestorTotalsModel();
              final isLoading = state is InvestorsLoading ||
                  state is InvestorsInitial;
              final totalCount = investors.length;
              final activeCount =
                  investors.where((investor) => investor.isActive).length;

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
                      onRefresh: () async {
                        _limitDialogShownForVisit = false;
                        await Future.wait([
                          context.read<InvestorsCubit>().fetchInvestors(),
                          _loadProjectTotalFund(),
                        ]);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            InvestorsOverviewSection(
                              onAddInvestor: _openAddInvestor,
                              totalInvestors: totalCount,
                              activeInvestors: activeCount,
                              totalProjectInvestment:
                                  totals.totalInvestmentAmount,
                              totalPaidAmount: totals.totalPaidAmount,
                            ),
                            const SizedBox(height: 20),
                            InvestorsTableSection(
                              investors: investors,
                              isLoading: isLoading,
                              onEditInvestor: _openEditInvestor,
                            ),
                          ],
                        ),
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
