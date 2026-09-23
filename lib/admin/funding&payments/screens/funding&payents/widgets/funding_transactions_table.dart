import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

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
  static const double _minTableWidth = 900;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  String _query = '';

  List<FundingTransaction> get _filteredTransactions {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.transactions;

    return widget.transactions.where((t) {
      return t.party.toLowerCase().contains(query) ||
          t.totalInvestmentAmount.toLowerCase().contains(query) ||
          t.totalPaidAmount.toLowerCase().contains(query) ||
          t.pendingAmount.toLowerCase().contains(query) ||
          t.date.toLowerCase().contains(query);
    }).toList();
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
            onSearchChanged: (value) => setState(() => _query = value),
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
    required this.onSearchChanged,
  });

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final title = Text(
          'All Transactions',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        );

        final filters = isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _DateRangeButton(onTap: () {}),
                  ),
                  const SizedBox(height: 10),
                  _ToolbarSearchField(onChanged: onSearchChanged),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DateRangeButton(onTap: () {}),
                  const SizedBox(width: 10),
                  _ToolbarSearchField(onChanged: onSearchChanged),
                ],
              );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              filters,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            filters,
          ],
        );
      },
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

class _ToolbarSearchField extends StatelessWidget {
  const _ToolbarSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: TextStyle(
            fontSize: 10.sp,
            color: AppColors.hint,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              ImageConstants.search,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.hint,
                BlendMode.srcIn,
              ),
            ),
          ),
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.accent),
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
          _HeaderCell('Investor / Vendor', flex: 4),
          _HeaderCell('Total Investment', flex: 3),
          _HeaderCell('Total Paid', flex: 3),
          _HeaderCell('Pending', flex: 3),
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
                _Cell(transaction.party, flex: 4),
                _Cell(transaction.totalInvestmentAmount, flex: 3),
                _Cell(transaction.totalPaidAmount, flex: 3),
                _Cell(transaction.pendingAmount, flex: 3),
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

class FundingTransaction {
  const FundingTransaction({
    required this.userId,
    required this.date,
    required this.type,
    required this.party,
    required this.totalInvestmentAmount,
    required this.totalPaidAmount,
    required this.pendingAmount,
    required this.status,
    this.description = '',
    this.amount = '',
  });

  final int userId;
  final String date;
  final String type;
  final String party;
  final String totalInvestmentAmount;
  final String totalPaidAmount;
  final String pendingAmount;
  final String status;

  /// Kept for detail screens that still read these fields.
  final String description;
  final String amount;
}
