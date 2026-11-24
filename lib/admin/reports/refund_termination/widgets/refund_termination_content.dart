import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../cubit/refund_termination_cubit.dart';
import '../model/refund_termination_model.dart';

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
  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} ${date.year}';
}

String _formatIso(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Stat cards + toolbar + the Refunds and Terminated Investors tables. Owns
/// the period and the search text; the screen remounts it to reset them.
class RefundTerminationContent extends StatefulWidget {
  const RefundTerminationContent({super.key});

  @override
  State<RefundTerminationContent> createState() =>
      _RefundTerminationContentState();
}

class _RefundTerminationContentState extends State<RefundTerminationContent> {
  static const double _searchFieldMaxWidth = 260;

  final TextEditingController _searchController = TextEditingController();
  StaffReportPeriod _period = StaffReportPeriod.thisMonth;
  DateTime? _customFrom;
  DateTime? _customTo;
  String? _lastToastedMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<RefundTerminationCubit>().load(
      period: _period,
      customFrom: _customFrom,
      customTo: _customTo,
    );
  }

  Future<void> _onPeriodSelected(StaffReportPeriod period) async {
    if (period == StaffReportPeriod.custom) {
      final range = await showStaffReportCustomDateRangeDialog(
        context: context,
        initialRange: _customFrom != null && _customTo != null
            ? DateTimeRange(start: _customFrom!, end: _customTo!)
            : null,
      );
      if (!mounted || range == null) return;
      setState(() {
        _period = StaffReportPeriod.custom;
        _customFrom = range.start;
        _customTo = range.end;
      });
      _fetch();
      return;
    }

    setState(() {
      _period = period;
      _customFrom = null;
      _customTo = null;
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RefundTerminationCubit, RefundTerminationState>(
      listener: (context, state) {
        if (state is RefundTerminationError) {
          if (state.message != _lastToastedMessage) {
            _lastToastedMessage = state.message;
            AppToast.error(state.message, context: context);
          }
        } else if (state is RefundTerminationLoaded) {
          _lastToastedMessage = null;
        }
      },
      child: BlocBuilder<RefundTerminationCubit, RefundTerminationState>(
        builder: (context, state) {
          final totals = state is RefundTerminationLoaded
              ? state.report.totals
              : null;
          String count(int? v) => totals == null ? '—' : '${v ?? 0}';
          String money(double? v) =>
              totals == null ? '—' : CurrencyFormatter.format(v ?? 0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserManagementStatCards(
                stats: [
                  UserManagementStatCardData(
                    label: 'Refunds',
                    value: count(totals?.refundCount),
                    icon: ImageConstants.reports,
                    iconColor: const Color(0xFF5B8DEF),
                    iconBg: const Color(0xFFEAF1FC),
                  ),
                  UserManagementStatCardData(
                    label: 'Refunded Amount',
                    value: money(totals?.refundAmount),
                    icon: ImageConstants.totalFunding,
                    iconColor: const Color(0xFF9B7EBF),
                    iconBg: const Color(0xFFF0EBF6),
                  ),
                  UserManagementStatCardData(
                    label: 'Terminated',
                    value: count(totals?.terminatedCount),
                    icon: ImageConstants.totalInvestors,
                    iconColor: const Color(0xFFE5645F),
                    iconBg: const Color(0xFFFDECEB),
                  ),
                  UserManagementStatCardData(
                    label: 'Remaining Refundable',
                    value: money(totals?.remainingRefundable),
                    icon: ImageConstants.workProgress,
                    iconColor: const Color(0xFFE89A3C),
                    iconBg: const Color(0xFFFFF3E8),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              UserManagementTableCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Toolbar(
                      searchController: _searchController,
                      period: _period,
                      searchFieldMaxWidth: _searchFieldMaxWidth,
                      onPeriodSelected: _onPeriodSelected,
                    ),
                    if (_period == StaffReportPeriod.custom &&
                        _customFrom != null &&
                        _customTo != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_formatIso(_customFrom!)} - '
                          '${_formatIso(_customTo!)}',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, _, _) => _buildBody(state),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _match(String query, String name, String code) =>
      name.toLowerCase().contains(query) || code.toLowerCase().contains(query);

  Widget _buildBody(RefundTerminationState state) {
    if (state is RefundTerminationLoading ||
        state is RefundTerminationInitial) {
      return const Padding(
        padding: EdgeInsets.only(top: 14),
        child: SizedBox(
          height: 260,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    if (state is RefundTerminationError) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SizedBox(
          height: 260,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _fetch,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final report = (state as RefundTerminationLoaded).report;
    final query = _searchController.text.trim().toLowerCase();
    final refunds = query.isEmpty
        ? report.refunds
        : report.refunds
              .where((r) => _match(query, r.name, r.investorCode))
              .toList();
    final terminated = query.isEmpty
        ? report.terminated
        : report.terminated
              .where((t) => _match(query, t.name, t.investorCode))
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        _SectionTitle('Refunds (${refunds.length})'),
        const SizedBox(height: 8),
        UserManagementTableFrame(
          minTableWidth: 1100,
          header: const UserManagementHeaderRow(
            children: [
              UserManagementHeaderCell('Date', flex: 2),
              UserManagementHeaderCell('Code', flex: 2),
              UserManagementHeaderCell('Name', flex: 3),
              UserManagementHeaderCell('Amount', flex: 3),
              UserManagementHeaderCell('Method', flex: 2),
              UserManagementHeaderCell('Remarks', flex: 4),
            ],
          ),
          rowCount: refunds.length,
          emptyMessage: 'No records found',
          rowBuilder: (context, index) =>
              _RefundRow(index: index, row: refunds[index]),
        ),
        const SizedBox(height: 22),
        _SectionTitle('Terminated Investors (${terminated.length})'),
        const SizedBox(height: 8),
        UserManagementTableFrame(
          minTableWidth: 1400,
          header: const UserManagementHeaderRow(
            children: [
              UserManagementHeaderCell('Code', flex: 2),
              UserManagementHeaderCell('Name', flex: 3),
              UserManagementHeaderCell('Terminated On', flex: 3),
              UserManagementHeaderCell('Paid', flex: 3),
              UserManagementHeaderCell('Refunded', flex: 3),
              UserManagementHeaderCell('Pending Requests', flex: 3),
              UserManagementHeaderCell('Remaining Refundable', flex: 3),
            ],
          ),
          rowCount: terminated.length,
          emptyMessage: 'No records found',
          rowBuilder: (context, index) =>
              _TerminatedRow(index: index, row: terminated[index]),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _RefundRow extends StatelessWidget {
  const _RefundRow({required this.index, required this.row});

  final int index;
  final RefundRowModel row;

  @override
  Widget build(BuildContext context) {
    final date = row.refundDate;
    return ColoredBox(
      color: index.isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              UserManagementDataCell(
                date == null ? '—' : _formatDate(date),
                flex: 2,
              ),
              Expanded(
                flex: 2,
                child: Text(
                  row.investorCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              UserManagementDataCell(row.name, flex: 3),
              UserManagementDataCell(
                CurrencyFormatter.format(row.refundAmount),
                flex: 3,
              ),
              UserManagementDataCell(row.paymentMethod, flex: 2),
              UserManagementDataCell(row.remarks, flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerminatedRow extends StatelessWidget {
  const _TerminatedRow({required this.index, required this.row});

  final int index;
  final TerminatedInvestorModel row;

  @override
  Widget build(BuildContext context) {
    final date = row.terminatedDate;
    final dateText = date == null
        ? '—'
        : row.isApproximateDate
        ? '${_formatDate(date)} (approx.)'
        : _formatDate(date);

    return ColoredBox(
      color: index.isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  row.investorCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              UserManagementDataCell(row.name, flex: 3),
              UserManagementDataCell(dateText, flex: 3),
              UserManagementDataCell(
                CurrencyFormatter.format(row.totalPaid),
                flex: 3,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(row.totalRefunded),
                flex: 3,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(row.pendingRefundRequests),
                flex: 3,
              ),
              UserManagementDataCell(
                CurrencyFormatter.format(row.remainingRefundable),
                flex: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.period,
    required this.searchFieldMaxWidth,
    required this.onPeriodSelected,
  });

  final TextEditingController searchController;
  final StaffReportPeriod period;
  final double searchFieldMaxWidth;
  final ValueChanged<StaffReportPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final searchField = SizedBox(
          width: isCompact ? double.infinity : searchFieldMaxWidth,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, value, _) {
              return TextField(
                controller: searchController,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name or code',
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
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          onPressed: searchController.clear,
                          splashRadius: 18,
                          tooltip: 'Clear search',
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        )
                      : null,
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
              );
            },
          ),
        );

        final periodButton = PopupMenuButton<StaffReportPeriod>(
          initialValue: period,
          onSelected: onPeriodSelected,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (context) => [
            for (final option in StaffReportPeriod.values)
              PopupMenuItem(
                value: option,
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: option == period
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
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
                  period.label,
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
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: periodButton),
            ],
          );
        }

        return Row(children: [searchField, const Spacer(), periodButton]);
      },
    );
  }
}
