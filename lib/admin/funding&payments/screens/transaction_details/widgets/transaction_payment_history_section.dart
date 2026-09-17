import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

enum _HistoryTab { all, completed, pending }

class TransactionPaymentHistorySection extends StatefulWidget {
  const TransactionPaymentHistorySection({super.key});

  @override
  State<TransactionPaymentHistorySection> createState() =>
      _TransactionPaymentHistorySectionState();
}

class _TransactionPaymentHistorySectionState
    extends State<TransactionPaymentHistorySection> {
  static const double _minTableWidth = 1080;
  static const int _pageSize = 4;

  final ScrollController _horizontalController = ScrollController();

  _HistoryTab _selectedTab = _HistoryTab.all;
  String _query = '';
  int _page = 1;

  static const List<_LedgerTransaction> _transactions = [
    _LedgerTransaction(
      id: '#TXN-8901',
      date: '03 Jun, 2026',
      title: 'Investment - Phase 2',
      subtitle: 'Tranche A (Oncology Diagnostics)',
      paymentMode: 'Wire Transfer / NEFT',
      paymentModeDetail: '',
      amount: '₹20,00,000',
      status: 'Pending',
    ),
    _LedgerTransaction(
      id: '#TXN-8452',
      date: '18 Apr, 2026',
      title: 'Investment - Phase 1',
      subtitle: 'Final Settlement Tranche',
      paymentMode: 'RTGS (UTR:',
      paymentModeDetail: 'HDFC9283401)',
      amount: '₹20,00,000',
      status: 'Completed',
    ),
    _LedgerTransaction(
      id: '#TXN-7910',
      date: '02 Mar, 2026',
      title: 'Investment - Phase 1',
      subtitle: 'Tranche B (Structural Foundation)',
      paymentMode: 'Cheque #492810',
      paymentModeDetail: '(Cleared)',
      amount: '₹20,00,000',
      status: 'Completed',
    ),
    _LedgerTransaction(
      id: '#TXN-7104',
      date: '15 Jan, 2026',
      title: 'Initial Commitment Advance',
      subtitle: 'Phase 1 Induction Security',
      paymentMode: 'RTGS Transfer',
      paymentModeDetail: '',
      amount: '₹20,00,000',
      status: 'Completed',
    ),
    _LedgerTransaction(
      id: '#TXN-6628',
      date: '10 Dec, 2025',
      title: 'Investment - Phase 1',
      subtitle: 'Civil Works Tranche',
      paymentMode: 'Wire Transfer / NEFT',
      paymentModeDetail: '',
      amount: '₹20,00,000',
      status: 'Completed',
    ),
    _LedgerTransaction(
      id: '#TXN-9012',
      date: '15 Jul, 2026',
      title: 'Investment - Phase 2',
      subtitle: 'Tranche C (Medical Equipment)',
      paymentMode: 'Scheduled RTGS',
      paymentModeDetail: '',
      amount: '₹20,00,000',
      status: 'Scheduled',
    ),
  ];

  bool _isPendingOrScheduled(_LedgerTransaction t) =>
      t.status == 'Pending' || t.status == 'Scheduled';

  List<_LedgerTransaction> get _tabFiltered {
    switch (_selectedTab) {
      case _HistoryTab.all:
        return _transactions;
      case _HistoryTab.completed:
        return _transactions.where((t) => t.status == 'Completed').toList();
      case _HistoryTab.pending:
        return _transactions.where(_isPendingOrScheduled).toList();
    }
  }

  List<_LedgerTransaction> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _tabFiltered;
    return _tabFiltered.where((t) {
      return t.id.toLowerCase().contains(query) ||
          t.title.toLowerCase().contains(query) ||
          t.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  int get _pageCount {
    final count = _filtered.length;
    if (count == 0) return 1;
    return (count / _pageSize).ceil();
  }

  List<_LedgerTransaction> get _paged {
    final start = (_page - 1) * _pageSize;
    if (start >= _filtered.length) return const [];
    final end = (start + _pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  int get _allCount => _transactions.length;
  int get _completedCount =>
      _transactions.where((t) => t.status == 'Completed').length;
  int get _pendingCount => _transactions.where(_isPendingOrScheduled).length;

  void _selectTab(_HistoryTab tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
      _page = 1;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _page = 1;
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _paged;
    final total = _filtered.length;
    final from = total == 0 ? 0 : ((_page - 1) * _pageSize) + 1;
    final to = total == 0 ? 0 : ((_page - 1) * _pageSize) + rows.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderBar(),
          const SizedBox(height: 16),
          _TabsSearchRow(
            selectedTab: _selectedTab,
            allCount: _allCount,
            completedCount: _completedCount,
            pendingCount: _pendingCount,
            onTabSelected: _selectTab,
            onSearchChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
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
                        if (rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        else
                          for (var i = 0; i < rows.length; i++)
                            _HistoryRow(
                              index: from + i,
                              transaction: rows[i],
                              showDivider: i < rows.length - 1,
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _PaginationBar(
            from: from,
            to: to,
            total: total,
            page: _page,
            onPrevious: _page > 1
                ? () => setState(() => _page -= 1)
                : null,
            onNext: _page < _pageCount
                ? () => setState(() => _page += 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction & Payment History',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete ledger of recorded wire transfers, checks, and pending notices',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DateRangeButton(),
            const SizedBox(width: 10),
            const _ExportButton(),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {},
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
                  AppColors.accent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '01 Jan, 2026 – 30 Jun, 2026',
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
  const _ExportButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {},
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
              const Icon(
                Icons.file_download_outlined,
                size: 16,
                color: AppColors.accent,
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

class _TabsSearchRow extends StatelessWidget {
  const _TabsSearchRow({
    required this.selectedTab,
    required this.allCount,
    required this.completedCount,
    required this.pendingCount,
    required this.onTabSelected,
    required this.onSearchChanged,
  });

  final _HistoryTab selectedTab;
  final int allCount;
  final int completedCount;
  final int pendingCount;
  final ValueChanged<_HistoryTab> onTabSelected;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;

        final tabs = Row(
          children: [
            _TabItem(
              label: 'All Transactions',
              count: allCount,
              selected: selectedTab == _HistoryTab.all,
              onTap: () => onTabSelected(_HistoryTab.all),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Completed',
              count: completedCount,
              selected: selectedTab == _HistoryTab.completed,
              onTap: () => onTabSelected(_HistoryTab.completed),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Pending / Scheduled',
              count: pendingCount,
              selected: selectedTab == _HistoryTab.pending,
              onTap: () => onTabSelected(_HistoryTab.pending),
            ),
          ],
        );

        final search = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isCompact ? double.infinity : 240,
          ),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by ID, tranche...',
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
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
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
              search,
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
            search,
          ],
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              width: (label.length + 4) * 6.4,
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          _HeaderCell('#', flex: 1),
          _HeaderCell('TRANSACTION ID', flex: 3),
          _HeaderCell('DATE', flex: 3),
          _HeaderCell('TRANCHE / DESCRIPTION', flex: 5),
          _HeaderCell('PAYMENT MODE', flex: 4),
          _HeaderCell('AMOUNT', flex: 3),
          _HeaderCell('STATUS', flex: 2),
          _HeaderCell('ACTION', flex: 2, align: TextAlign.center),
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.index,
    required this.transaction,
    required this.showDivider,
  });

  final int index;
  final _LedgerTransaction transaction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF0ECF4)),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PlainCell('$index', flex: 1),
          Expanded(
            flex: 3,
            child: Text(
              transaction.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          _PlainCell(transaction.date, flex: 3, muted: true),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.paymentMode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (transaction.paymentModeDetail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.paymentModeDetail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              transaction.amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: transaction.status),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Material(
                color: const Color(0xFFF6F4F8),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.file_download_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainCell extends StatelessWidget {
  const _PlainCell(
    this.text, {
    required this.flex,
    this.muted = false,
  });

  final String text;
  final int flex;
  final bool muted;

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
          color: muted ? AppColors.textMuted : AppColors.textPrimary,
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
    final isCompleted = status == 'Completed';
    final isScheduled = status == 'Scheduled';

    final Color bg;
    final Color fg;
    if (isCompleted) {
      bg = const Color(0xFFE6F6EC);
      fg = AppColors.green;
    } else if (isScheduled) {
      bg = const Color(0xFFEAF1FC);
      fg = const Color(0xFF5B8DEF);
    } else {
      bg = const Color(0xFFFDECEE);
      fg = const Color(0xFFE06B7A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.from,
    required this.to,
    required this.total,
    required this.page,
    required this.onPrevious,
    required this.onNext,
  });

  final int from;
  final int to;
  final int total;
  final int page;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 560;

        final summary = Text(
          'Showing $from to $to of $total active entries',
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        );

        final controls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageChip(
              label: 'Previous',
              enabled: onPrevious != null,
              onTap: onPrevious,
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _PageChip(
              label: 'Next',
              enabled: onNext != null,
              onTap: onNext,
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summary,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: controls),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: summary),
            controls,
          ],
        );
      },
    );
  }
}

class _PageChip extends StatelessWidget {
  const _PageChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w500,
              color: enabled ? AppColors.textPrimary : AppColors.hint,
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerTransaction {
  const _LedgerTransaction({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.paymentMode,
    required this.paymentModeDetail,
    required this.amount,
    required this.status,
  });

  final String id;
  final String date;
  final String title;
  final String subtitle;
  final String paymentMode;
  final String paymentModeDetail;
  final String amount;
  final String status;
}
