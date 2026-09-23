import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/cubit/funding_payments_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/transaction_details/widgets/investor_profile_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/transaction_details/widgets/investor_profile_overview.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/transaction_details/widgets/transaction_payment_history_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import '../funding&payents/widgets/funding_transactions_table.dart';

/// Detail page shown when a transaction row is selected.
/// Keeps the admin side drawer visible (in-shell navigation).
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.onBack,
  });

  final FundingTransaction transaction;
  final VoidCallback? onBack;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FundingPaymentsCubit>().fetchInvestorDetails(
            widget.transaction.userId,
          );
    });
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
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

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
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

  @override
  Widget build(BuildContext context) {
    final partyName = widget.transaction.party;

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
                child: _BackHeader(
                  partyName: partyName,
                  onBack: () => _handleBack(context),
                ),
              ),
              Expanded(
                child: BlocConsumer<FundingPaymentsCubit, FundingPaymentsState>(
                  listenWhen: (previous, current) =>
                      current is InvestorDetailsFailure,
                  buildWhen: (previous, current) =>
                      current is InvestorDetailsLoading ||
                      current is InvestorDetailsSuccess ||
                      current is InvestorDetailsFailure,
                  listener: (context, state) {
                    if (state is InvestorDetailsFailure) {
                      AppToast.error(state.message, context: context);
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<FundingPaymentsCubit>();
                    final details = state is InvestorDetailsSuccess
                        ? state.details
                        : cubit.investorDetails;
                    final isLoading = state is InvestorDetailsLoading &&
                        details == null;
                    final errorMessage = state is InvestorDetailsFailure &&
                            details == null
                        ? state.message
                        : null;

                    if (isLoading) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    }

                    if (errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context
                                    .read<FundingPaymentsCubit>()
                                    .fetchInvestorDetails(
                                      widget.transaction.userId,
                                    ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (details == null) {
                      return Center(
                        child: Text(
                          'No investor details found',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InvestorProfileOverview(
                            details: details,
                            formatCurrency: _formatCurrency,
                            formatDate: _formatDate,
                          ),
                          const SizedBox(height: 16),
                          InvestorProfileDetailsSection(
                            details: details,
                            formatCurrency: _formatCurrency,
                            formatDate: _formatDate,
                          ),
                          const SizedBox(height: 16),
                          TransactionPaymentHistorySection(
                            dueDates: details.dueDates,
                            formatCurrency: _formatCurrency,
                            formatDate: _formatDate,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader({
    required this.partyName,
    required this.onBack,
  });

  final String partyName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final breadcrumbAndName = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Funding & Payments',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    partyName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );

        final backButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.newBorder,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.newBorder, width: 1),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Funding',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndName,
              const SizedBox(height: 8),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: breadcrumbAndName),
            backButton,
          ],
        );
      },
    );
  }
}
