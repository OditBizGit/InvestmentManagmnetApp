import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/cubit/funding_payments_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/funding_investor_list_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/funding&payents/widgets/funding_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/funding&payents/widgets/funding_payments_top_bar.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/funding&payents/widgets/funding_transactions_table.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';

import '../add_fund/add_new_fund.dart';
import '../transaction_details/transaction_detail_screen.dart';

class AdminFundingPaymentsScreen extends StatelessWidget {
  const AdminFundingPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InvestorsRepository>.value(
          value: getIt<InvestorsRepository>(),
        ),
        RepositoryProvider<InvestorPaymentRepository>.value(
          value: getIt<InvestorPaymentRepository>(),
        ),
      ],
      child: BlocProvider(
        create: (context) => FundingPaymentsCubit(
          investorsRepository: context.read<InvestorsRepository>(),
          paymentRepository: context.read<InvestorPaymentRepository>(),
        )..fetchFundingInvestors(),
        child: const _AdminFundingPaymentsView(),
      ),
    );
  }
}

class _AdminFundingPaymentsView extends StatefulWidget {
  const _AdminFundingPaymentsView();

  @override
  State<_AdminFundingPaymentsView> createState() =>
      _AdminFundingPaymentsViewState();
}

class _AdminFundingPaymentsViewState extends State<_AdminFundingPaymentsView> {
  FundingTransaction? _selectedTransaction;
  bool _showAddFund = false;

  void _openTransaction(FundingTransaction transaction) {
    setState(() {
      _selectedTransaction = transaction;
      _showAddFund = false;
    });
  }

  void _openAddFund() {
    setState(() {
      _showAddFund = true;
      _selectedTransaction = null;
    });
  }

  void _backToFunding({bool addedSuccessfully = false}) {
    if (!mounted) return;
    context.read<FundingPaymentsCubit>().clearInvestorDetails();
    setState(() {
      _selectedTransaction = null;
      _showAddFund = false;
    });
    if (!addedSuccessfully) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FundingPaymentsCubit>().refreshSilently();
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatCurrency(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw =
        isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final withCommas = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }

  String _displayStatus(String status) {
    final normalized = status.trim();
    if (normalized.isEmpty) return 'Pending';
    final lower = normalized.toLowerCase();
    if (lower.contains('complete') ||
        lower.contains('paid') ||
        lower.contains('success') ||
        lower.contains('received')) {
      return 'Completed';
    }
    if (lower.contains('schedul')) return 'Scheduled';
    if (lower.contains('pending')) return 'Pending';
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _displayType(FundingInvestorModel item) {
    final status = item.status.toLowerCase();
    if (item.totalPaidAmount > 0 ||
        item.latestPaymentAmount > 0 ||
        status.contains('complete') ||
        status.contains('received') ||
        status.contains('paid')) {
      return 'Received';
    }
    return 'Payment';
  }

  FundingTransaction _mapToFundingTransaction(
    FundingInvestorModel item,
  ) {
    final date = item.modifiedDate ?? item.createdDate ?? DateTime.now();
    final paid = _formatCurrency(item.totalPaidAmount);
    final email = item.email.trim();

    return FundingTransaction(
      userId: item.userId,
      date: _formatDate(date),
      type: _displayType(item),
      party: item.fullName.trim().isNotEmpty ? item.fullName.trim() : 'Unknown',
      totalInvestmentAmount: _formatCurrency(item.totalInvestmentAmount),
      totalPaidAmount: paid,
      pendingAmount: _formatCurrency(item.totalPendingAmount),
      status: _displayStatus(item.status),
      description: email.isNotEmpty ? email : '-',
      amount: paid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(
          offstage: _showAddFund || _selectedTransaction != null,
          child: BlocConsumer<FundingPaymentsCubit, FundingPaymentsState>(
            listenWhen: (previous, current) =>
                current is TransactionHistoryFailure,
            buildWhen: (previous, current) =>
                current is FundingPaymentsInitial ||
                current is TransactionHistoryLoading ||
                current is TransactionHistorySuccess ||
                current is TransactionHistoryEmpty ||
                current is TransactionHistoryFailure,
            listener: (context, state) {
              if (state is TransactionHistoryFailure) {
                final cubit = context.read<FundingPaymentsCubit>();
                if (!cubit.hasFundingInvestors) {
                  AppToast.error(state.message, context: context);
                }
              }
            },
            builder: (context, state) {
              final cubit = context.read<FundingPaymentsCubit>();

              final isLoading = (state is TransactionHistoryLoading ||
                      state is FundingPaymentsInitial) &&
                  !cubit.hasFundingInvestors;

              final errorMessage =
                  state is TransactionHistoryFailure && !cubit.hasFundingInvestors
                      ? state.message
                      : null;

              final source = state is TransactionHistorySuccess
                  ? state.investors
                  : cubit.fundingInvestors;

              final transactions = isLoading || errorMessage != null
                  ? const <FundingTransaction>[]
                  : source.map(_mapToFundingTransaction).toList();

              final isEmpty = !isLoading &&
                  errorMessage == null &&
                  (state is TransactionHistoryEmpty ||
                      (!cubit.hasFundingInvestors && transactions.isEmpty));

              return ColoredBox(
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
                          child: const FundingPaymentsTopBar(),
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
                                FundingOverviewSection(
                                  transactions:
                                      isLoading || errorMessage != null
                                          ? const []
                                          : source,
                                  onAddFunding: _openAddFund,
                                ),
                                const SizedBox(height: 20),
                                FundingTransactionsTable(
                                  transactions: transactions,
                                  isLoading: isLoading,
                                  isEmpty: isEmpty,
                                  errorMessage: errorMessage,
                                  onRetry: () => context
                                      .read<FundingPaymentsCubit>()
                                      .fetchFundingInvestors(),
                                  onTransactionTap: _openTransaction,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (_showAddFund)
          AddNewFundScreen(
            onBack: () => _backToFunding(),
            onSaveSuccess: () => _backToFunding(addedSuccessfully: true),
          ),
        if (_selectedTransaction != null)
          TransactionDetailScreen(
            transaction: _selectedTransaction!,
            onBack: () => _backToFunding(),
          ),
      ],
    );
  }
}
