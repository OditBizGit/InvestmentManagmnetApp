import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_transaction_history_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../../cubit/report__cubit.dart';

class ReportsRecentTransactionsTable extends StatelessWidget {
  const ReportsRecentTransactionsTable({super.key});

  static String _formatDate(DateTime date) {
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

  static _RecentTransaction _mapTransaction(
    InvestorTransactionHistoryModel item,
  ) {
    final paidAmount = item.paidAmount;

    final description = item.narration.trim().isNotEmpty
        ? item.narration.trim()
        : '-';

    return _RecentTransaction(
      date: _formatDate(item.date),
      party: item.fullName.trim().isNotEmpty ? item.fullName.trim() : 'Unknown',
      description: description,
      amount: CurrencyFormatter.format(paidAmount),
      status: item.status.trim().isNotEmpty ? item.status.trim() : 'Completed',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<ReportCubit, ReportState>(
            buildWhen: (previous, current) =>
                previous.transactionsLoading != current.transactionsLoading ||
                previous.transactionsError != current.transactionsError ||
                previous.transactions != current.transactions,
            builder: (context, state) {
              if (state.transactionsLoading && state.transactions.isEmpty) {
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                );
              }

              final error = state.transactionsError;
              if (error != null && state.transactions.isEmpty) {
                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context
                                .read<ReportCubit>()
                                .fetchRecentTransactions(),
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
                  ),
                );
              }

              final latestTransactions = state.transactions.take(10).toList();

              final rows = latestTransactions.map(_mapTransaction).toList();
              if (rows.isEmpty) {
                return SizedBox(
                  height: 140,
                  child: Center(
                    child: Text(
                      'No recent transactions',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  const minTableWidth = 900.0;
                  final tableWidth = constraints.maxWidth < minTableWidth
                      ? minTableWidth
                      : constraints.maxWidth;

                  final table = SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        const _TableHeader(),
                        const SizedBox(height: 4),
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.border,
                            ),
                          _TransactionRow(index: i, transaction: rows[i]),
                        ],
                      ],
                    ),
                  );

                  if (constraints.maxWidth < minTableWidth) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: table,
                    );
                  }

                  return table;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentTransaction {
  const _RecentTransaction({
    required this.date,
    required this.party,
    required this.description,
    required this.amount,
    required this.status,
  });

  final String date;
  final String party;
  final String description;
  final String amount;
  final String status;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          _HeaderCell('#', flex: 1),
          _HeaderCell('Date', flex: 3),
          _HeaderCell('Investor / Vendor', flex: 3),
          _HeaderCell('Description', flex: 4),
          // SizedBox(width: 1,),
          _HeaderCell('Amount', flex: 3),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.title, {required this.flex});

  final String title;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.index, required this.transaction});

  final int index;
  final _RecentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _Cell('${index + 1}', flex: 1),
            _Cell(transaction.date, flex: 3),
            _Cell(transaction.party, flex: 3),
            _Cell(transaction.description, flex: 4),
            _Cell(transaction.amount, flex: 3),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
