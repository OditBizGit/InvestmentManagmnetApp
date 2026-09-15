import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/add_new_investor.dart';
import 'package:maribel_wellness_centre_application/admin/investors/cubit/investors_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/success_screen.dart';

class AdminInvestorsScreen extends StatelessWidget {
  const AdminInvestorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InvestorsCubit>()..fetchInvestors(),
      child: const _AdminInvestorsView(),
    );
  }
}

class _AdminInvestorsView extends StatefulWidget {
  const _AdminInvestorsView();

  @override
  State<_AdminInvestorsView> createState() => _AdminInvestorsViewState();
}

class _AdminInvestorsViewState extends State<_AdminInvestorsView> {
  bool _showAddInvestor = false;

  void _openAddInvestor() {
    setState(() => _showAddInvestor = true);
  }

  void _backToInvestors() {
    setState(() => _showAddInvestor = false);
  }

  Future<void> _showAddSuccess() async {
    setState(() => _showAddInvestor = false);
    await context.read<InvestorsCubit>().fetchInvestors();

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

  @override
  Widget build(BuildContext context) {
    if (_showAddInvestor) {
      return AddNewInvestorScreen(
        onBack: _backToInvestors,
        onAddSuccess: _showAddSuccess,
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
              }
            },
            builder: (context, state) {
              final investors = state is InvestorsSuccess
                  ? state.investors
                  : <InvestorModel>[];
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
                    child: const InvestorsTopBar(),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: () =>
                          context.read<InvestorsCubit>().fetchInvestors(),
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
                            ),
                            const SizedBox(height: 20),
                            InvestorsTableSection(
                              investors: investors,
                              isLoading: isLoading,
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
