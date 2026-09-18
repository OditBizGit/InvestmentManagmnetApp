import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class ReportsRecentTransactionsTable extends StatelessWidget {
  const ReportsRecentTransactionsTable({super.key});

  static const _transactions = [
    _RecentTransaction(
      date: '03 Jun, 2026',
      type: 'Received',
      party: 'Corey Heriwitz',
      description: 'Foundation work - Phase 1',
      amount: '₹20,00,000',
    ),
    _RecentTransaction(
      date: '03 Jun, 2026',
      type: 'Received',
      party: 'ABC Constructions',
      description: 'Investment - Phase 2',
      amount: '₹20,00,000',
    ),
    _RecentTransaction(
      date: '01 Jun, 2026',
      type: 'Received',
      party: 'Alferdo Curtise',
      description: 'Electrical work payment',
      amount: '₹15,00,000',
    ),
    _RecentTransaction(
      date: '28 May, 2026',
      type: 'Received',
      party: 'Talan Baptista',
      description: 'Investment received',
      amount: '₹25,00,000',
    ),
    _RecentTransaction(
      date: '25 May, 2026',
      type: 'Received',
      party: 'Alfonso Herwitz',
      description: 'Plumbing materials',
      amount: '₹8,50,000',
    ),
  ];

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
          LayoutBuilder(
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
                    for (var i = 0; i < _transactions.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.border,
                        ),
                      _TransactionRow(
                        index: i,
                        transaction: _transactions[i],
                      ),
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
          ),
        ],
      ),
    );
  }
}

class _RecentTransaction {
  const _RecentTransaction({
    required this.date,
    required this.type,
    required this.party,
    required this.description,
    required this.amount,
  });

  final String date;
  final String type;
  final String party;
  final String description;
  final String amount;
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
          _HeaderCell('Type', flex: 2),
          _HeaderCell('Investor / Vendor', flex: 4),
          _HeaderCell('Description', flex: 4),
          _HeaderCell('Amount', flex: 3),
          _HeaderCell('Status', flex: 2),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.title, {
    required this.flex,
  });

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
  const _TransactionRow({
    required this.index,
    required this.transaction,
  });

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
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _TypeBadge(type: transaction.type),
              ),
            ),
            _Cell(transaction.party, flex: 4),
            _Cell(transaction.description, flex: 4),
            _Cell(transaction.amount, flex: 3),
            const Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusBadge(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
    this.text, {
    required this.flex,
  });

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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final isPayment = type.toLowerCase() == 'payment';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPayment
            ? const Color(0xFFFDECEE)
            : const Color(0xFFE8F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: isPayment ? AppColors.error : AppColors.green,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Completed',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.green,
        ),
      ),
    );
  }
}
