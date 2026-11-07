import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

enum PaymentStatus {
  pending,
  approved,
  rejected,
}

class MonthlyPayment {
  const MonthlyPayment({
    required this.id,
    required this.investorName,
    required this.investorCode,
    required this.contact,
    required this.staff,
    required this.method,
    required this.amount,
    required this.paidOn,
    this.status = PaymentStatus.pending,
  });

  final int id;
  final String investorName;
  final String investorCode;
  final String contact;
  final String staff;
  final String method;
  final double amount;
  final DateTime paidOn;
  final PaymentStatus status;

  static const _months = [
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

  String get date =>
      '${_months[paidOn.month - 1]} ${paidOn.day}, ${paidOn.year}';

  MonthlyPayment copyWith({
    PaymentStatus? status,
  }) {
    return MonthlyPayment(
      id: id,
      investorName: investorName,
      investorCode: investorCode,
      contact: contact,
      staff: staff,
      method: method,
      amount: amount,
      paidOn: paidOn,
      status: status ?? this.status,
    );
  }
}

class MonthlyPaymentTable extends StatefulWidget {
  const MonthlyPaymentTable({
    super.key,
    required this.payments,
    required this.selectedIds,
    required this.searchController,
    required this.fromDate,
    required this.toDate,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onSelectionChanged,
    required this.onSelectAllChanged,
    required this.onApprove,
    required this.onReject,
    required this.onApproveAll,
  });

  final List<MonthlyPayment> payments;
  final Set<int> selectedIds;
  final TextEditingController searchController;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;

  final void Function(int id, bool selected) onSelectionChanged;
  final ValueChanged<bool> onSelectAllChanged;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;
  final VoidCallback onApproveAll;

  @override
  State<MonthlyPaymentTable> createState() => _MonthlyPaymentTableState();
}

class _MonthlyPaymentTableState extends State<MonthlyPaymentTable> {
  static const double _minTableWidth = 1040;
  static const double _tableBodyHeight = 540;
  static const double _rowHeight = 54;
  static const double _actionsWidth = 84;
  static const double _actionsLeadingGap = 16;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  String _formatPickerDate(DateTime? value) {
    if (value == null) return '—';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  Future<void> _pickDate({
    required bool isFrom,
    required DateTime? initial,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (!mounted || picked == null) return;

    if (isFrom) {
      widget.onFromDateChanged(picked);
    } else {
      widget.onToDateChanged(picked);
    }
  }

  Widget _iconAction({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: onTap == null ? AppColors.border : color.withValues(alpha: 0.45),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 18,
              color: onTap == null ? AppColors.textMuted : color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatPickerDate(value),
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (value != null && onClear != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  UserManagementBadgeTone _statusTone(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.pending => UserManagementBadgeTone.warning,
      PaymentStatus.approved => UserManagementBadgeTone.success,
      PaymentStatus.rejected => UserManagementBadgeTone.danger,
    };
  }

  Widget _dataCell(String text, double width, {bool bold = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _headerCell(String title, double? width) {
    final label = Text(
      title,
      overflow: TextOverflow.ellipsis,
      textAlign: width == null ? TextAlign.right : TextAlign.left,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
      ),
    );

    if (width == null) return label;

    return SizedBox(width: width, child: label);
  }

  Widget _tableRow(MonthlyPayment payment) {
    final isPending = payment.status == PaymentStatus.pending;
    final initial = payment.investorName.isEmpty
        ? '?'
        : payment.investorName[0].toUpperCase();

    return Container(
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.white,
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Checkbox(
              value: widget.selectedIds.contains(payment.id),
              onChanged: isPending
                  ? (value) =>
                      widget.onSelectionChanged(payment.id, value ?? false)
                  : null,
              activeColor: AppColors.accent,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          _dataCell('${payment.id}', 40),
          SizedBox(
            width: 132,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.cardBg,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    payment.investorName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _dataCell(payment.investorCode, 88),
          _dataCell(payment.contact, 118),
          _dataCell(payment.staff, 92),
          _dataCell(payment.method, 96),
          _dataCell(CurrencyFormatter.format(payment.amount), 100, bold: true),
          _dataCell(payment.date, 100),
          SizedBox(
            width: 88,
            child: UserManagementStatusBadge(
              label: payment.status.name[0].toUpperCase() +
                  payment.status.name.substring(1),
              tone: _statusTone(payment.status),
            ),
          ),
          const SizedBox(width: _actionsLeadingGap),
          SizedBox(
            width: _actionsWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: isPending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconAction(
                          tooltip: 'Approve',
                          icon: Icons.check_rounded,
                          color: AppColors.green,
                          onTap: () => widget.onApprove(payment.id),
                        ),
                        const SizedBox(width: 4),
                        _iconAction(
                          tooltip: 'Reject',
                          icon: Icons.close_rounded,
                          color: AppColors.error,
                          onTap: () => widget.onReject(payment.id),
                        ),
                      ],
                    )
                  : Icon(
                      payment.status == PaymentStatus.approved
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackToolbar = constraints.maxWidth < 900;

        final hasSearchText = widget.searchController.text.isNotEmpty;

        final search = SizedBox(
          width: 200,
          child: TextField(
            controller: widget.searchController,
            onChanged: widget.onSearchChanged,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search investor, code...',
              hintStyle: TextStyle(
                fontSize: 10.sp,
                color: AppColors.hint,
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
              suffixIcon: hasSearchText
                  ? IconButton(
                      onPressed: widget.onClearSearch,
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
          ),
        );

        final dates = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dateField(
              label: 'From',
              value: widget.fromDate,
              onTap: () => _pickDate(isFrom: true, initial: widget.fromDate),
              onClear: widget.fromDate == null
                  ? null
                  : () => widget.onFromDateChanged(null),
            ),
            const SizedBox(width: 10),
            _dateField(
              label: 'To',
              value: widget.toDate,
              onTap: () => _pickDate(isFrom: false, initial: widget.toDate),
              onClear:
                  widget.toDate == null ? null : () => widget.onToDateChanged(null),
            ),
          ],
        );

        final approveAll = FilledButton.icon(
          onPressed: widget.onApproveAll,
          icon: const Icon(Icons.done_all_rounded, size: 18),
          label: Text(
            'Approve All',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        final title = Text(
          'Monthly Payments',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        );

        if (stackToolbar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: search),
              const SizedBox(height: 12),
              dates,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: approveAll),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            search,
            const SizedBox(width: 12),
            dates,
            const Spacer(),
            approveAll,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingIds = widget.payments
        .where((p) => p.status == PaymentStatus.pending)
        .map((p) => p.id)
        .toSet();

    final allPendingSelected = pendingIds.isNotEmpty &&
        pendingIds.every(widget.selectedIds.contains);

    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolbar(),
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
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child: Checkbox(
                                  value: allPendingSelected,
                                  onChanged: (value) => widget.onSelectAllChanged(
                                    value ?? false,
                                  ),
                                  activeColor: AppColors.accent,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              _headerCell('#', 40),
                              _headerCell('Investor Name', 132),
                              _headerCell('Investor Code', 88),
                              _headerCell('Contact No.', 118),
                              _headerCell('Staff', 92),
                              _headerCell('Method', 96),
                              _headerCell('Paid Amount', 100),
                              _headerCell('Payment Date', 100),
                              _headerCell('Status', 88),
                              const SizedBox(width: _actionsLeadingGap),
                              SizedBox(
                                width: _actionsWidth,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _headerCell('Actions', null),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.screenBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBg),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: _tableBodyHeight,
                            child: widget.payments.isEmpty
                                ? Center(
                                    child: Text(
                                      'No payments match your search or date range',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    controller: _verticalController,
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      controller: _verticalController,
                                      padding: EdgeInsets.zero,
                                      itemCount: widget.payments.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.cardBg,
                                      ),
                                      itemBuilder: (context, index) =>
                                          _tableRow(widget.payments[index]),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.payments.length} payment${widget.payments.length == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
