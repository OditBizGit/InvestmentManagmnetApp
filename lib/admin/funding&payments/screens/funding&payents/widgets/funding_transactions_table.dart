import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum _TransactionTab { all, received, pending }

class FundingTransactionsTable extends StatefulWidget {
  const FundingTransactionsTable({
    super.key,
    this.transactions = const [],
    this.isLoading = false,
    this.isEmpty = false,
    this.errorMessage,
    this.onRetry,
    this.onTransactionTap,
  });

  final List<FundingTransaction> transactions;
  final bool isLoading;
  final bool isEmpty;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<FundingTransaction>? onTransactionTap;

  @override
  State<FundingTransactionsTable> createState() =>
      _FundingTransactionsTableState();
}

class _FundingTransactionsTableState extends State<FundingTransactionsTable> {
  static const double _minTableWidth = 1040;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  _TransactionTab _selectedTab = _TransactionTab.all;

  List<FundingTransaction> get _filteredTransactions {
    switch (_selectedTab) {
      case _TransactionTab.all:
        return widget.transactions;
      case _TransactionTab.received:
        return widget.transactions
            .where((t) => t.type.toLowerCase() == 'received')
            .toList();
      case _TransactionTab.pending:
        return widget.transactions
            .where((t) => t.status.toLowerCase().contains('pending'))
            .toList();
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Widget _buildTableBody(List<FundingTransaction> rows) {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.error,
                ),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onRetry,
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
            ],
          ),
        ),
      );
    }

    if (widget.isEmpty || rows.isEmpty) {
      return Center(
        child: Text(
          'No transactions found',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _verticalController,
        padding: EdgeInsets.zero,
        itemCount: rows.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.cardBg,
        ),
        itemBuilder: (context, index) {
          return _TransactionRow(
            index: index,
            transaction: rows[index],
            onTap: widget.onTransactionTap == null
                ? null
                : () => widget.onTransactionTap!(rows[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filteredTransactions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TableToolbar(
            selectedTab: _selectedTab,
            onTabSelected: (tab) => setState(() => _selectedTab = tab),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < _minTableWidth
                  ? _minTableWidth
                  : constraints.maxWidth;

              return Scrollbar(
                controller: _horizontalController,
                thumbVisibility: tableWidth > constraints.maxWidth,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        const _TableHeader(),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.screenBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBg),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 480,
                            child: _buildTableBody(rows),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TableToolbar extends StatelessWidget {
  const _TableToolbar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final _TransactionTab selectedTab;
  final ValueChanged<_TransactionTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final tabs = Row(
          children: [
            _TabItem(
              label: 'All Transactions',
              selected: selectedTab == _TransactionTab.all,
              onTap: () => onTabSelected(_TransactionTab.all),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Received',
              selected: selectedTab == _TransactionTab.received,
              onTap: () => onTabSelected(_TransactionTab.received),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Pending',
              selected: selectedTab == _TransactionTab.pending,
              onTap: () => onTabSelected(_TransactionTab.pending),
            ),
          ],
        );

        final filters = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DateRangeButton(onTap: () {}),
            const SizedBox(width: 10),
            _ExportButton(onTap: () {}),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tabs,
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: filters),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tabs,
              ),
            ),
            const SizedBox(width: 12),
            filters,
          ],
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              width: label.length * 7.2,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ImageConstants.calender,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.textMuted,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '01 Jan, 2026–30 Jun, 2026',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ImageConstants.search,
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  AppColors.accent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Export',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          _HeaderCell('Action', flex: 1, align: TextAlign.center),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.title, {
    required this.flex,
    this.align = TextAlign.left,
  });

  final String title;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
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
    this.onTap,
  });

  final int index;
  final FundingTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;

    return Material(
      color: isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
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
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _StatusBadge(status: transaction.status),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: IconButton(
                      onPressed: onTap,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      visualDensity: VisualDensity.compact,
                      splashRadius: 16,
                      icon: const Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final isPayment = type == 'Payment';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPayment
            ? AppColors.error.withValues(alpha: 0.10)
            : AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: isPayment ? AppColors.error : AppColors.green,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final isCompleted = lower.contains('complete') ||
        lower.contains('paid') ||
        lower.contains('success') ||
        lower.contains('received');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.green.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: isCompleted ? AppColors.green : AppColors.error,
        ),
      ),
    );
  }
}

class FundingTransaction {
  const FundingTransaction({
    required this.date,
    required this.type,
    required this.party,
    required this.description,
    required this.amount,
    required this.status,
  });

  final String date;
  final String type;
  final String party;
  final String description;
  final String amount;
  final String status;
}
