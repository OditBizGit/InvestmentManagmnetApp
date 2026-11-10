import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/cubit/payment_list_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/model/payment_verification_history_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

enum VerificationHistoryStatus { approved, rejected }

class PaymentVerificationHistoryRow {
  const PaymentVerificationHistoryRow({
    required this.transactionId,
    required this.investorName,
    required this.investorCode,
    required this.staff,
    required this.paymentDate,
    required this.amount,
    required this.method,
    required this.status,
    required this.verifiedBy,
    required this.verifiedDate,
    this.rejectReason,
  });

  final int transactionId;
  final String investorName;
  final String investorCode;
  final String staff;
  final DateTime? paymentDate;
  final double amount;
  final String method;
  final VerificationHistoryStatus status;
  final String verifiedBy;
  final DateTime? verifiedDate;
  final String? rejectReason;
}

List<PaymentVerificationHistoryRow> mapVerificationHistoryRows(
  List<PaymentVerificationHistoryTransactionModel> transactions,
) {
  return transactions.map((transaction) {
    final statusLabel = transaction.verificationStatus.toLowerCase();
    final status = statusLabel.contains('reject')
        ? VerificationHistoryStatus.rejected
        : VerificationHistoryStatus.approved;

    return PaymentVerificationHistoryRow(
      transactionId: transaction.transactionId,
      investorName: transaction.investorName,
      investorCode: transaction.investorCode,
      staff: transaction.staffName,
      paymentDate: transaction.paymentDate,
      amount: transaction.paidAmount,
      method: transaction.paymentMethod,
      status: status,
      verifiedBy: transaction.verifiedByName ?? '—',
      verifiedDate: transaction.verifiedDate,
      rejectReason:
          status == VerificationHistoryStatus.rejected ? transaction.remarks : null,
    );
  }).toList(growable: false);
}

class PaymentVerificationHistoryScreen extends StatefulWidget {
  const PaymentVerificationHistoryScreen({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  State<PaymentVerificationHistoryScreen> createState() =>
      _PaymentVerificationHistoryScreenState();
}

class _PaymentVerificationHistoryScreenState
    extends State<PaymentVerificationHistoryScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  PaymentVerificationHistoryDataModel? _lastLoadedData;

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchHistory();
    });
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month, now.day);
  }

  DateTime get _fetchFromDate => DateTime(
        _fromDate.year,
        _fromDate.month,
        _fromDate.day,
      );

  DateTime get _fetchToDate => DateTime(
        _toDate.year,
        _toDate.month,
        _toDate.day,
      );

  void _fetchHistory() {
    context.read<PaymentListCubit>().fetchPaymentVerificationHistory(
          fromDate: _fetchFromDate,
          toDate: _fetchToDate,
        );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
      } else {
        _toDate = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }

  String _formatPickerDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _formatRowDate(DateTime? value) {
    if (value == null) return '—';
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
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocConsumer<PaymentListCubit, PaymentListState>(
            listenWhen: (previous, current) {
              if (current is! PaymentListLoaded) return false;
              if (current.historyActionMessage == null) return false;
              if (previous is! PaymentListLoaded) return true;
              return previous.historyActionMessage !=
                  current.historyActionMessage;
            },
            listener: (context, state) {
              if (state is! PaymentListLoaded) return;
              final message = state.historyActionMessage;
              if (message == null || message.isEmpty) return;
              AppToast.error(message, context: context);
              context.read<PaymentListCubit>().clearHistoryActionFeedback();
            },
            builder: (context, state) {
              final loaded =
                  state is PaymentListLoaded ? state : null;

              PaymentVerificationHistoryDataModel? data;
              String? errorMessage;

              if (loaded != null) {
                data = loaded.historyData ?? _lastLoadedData;
                if (loaded.historyData != null) {
                  _lastLoadedData = loaded.historyData;
                }
                errorMessage = loaded.historyErrorMessage;
              } else {
                data = _lastLoadedData;
              }

              final isInitialLoad = loaded != null &&
                  loaded.isHistoryRefreshing &&
                  data == null &&
                  errorMessage == null;

              final isHistoryError = errorMessage != null &&
                  data == null &&
                  !(loaded?.isHistoryRefreshing ?? false);

              final rows = data != null
                  ? mapVerificationHistoryRows(data.transactions)
                  : <PaymentVerificationHistoryRow>[];

              final showTopProgress = data != null &&
                  (loaded?.isHistoryRefreshing ?? false);

              final totalCount = data?.totalPayments ?? rows.length;

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
                    child: const AdminTopBar(),
                  ),
                  if (showTopProgress) const AdminRefetchProgressBar(),
                  Expanded(
                    child: isInitialLoad && data == null && !isHistoryError
                        ? const AdminInitialLoadingBody()
                        : SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _VerificationHistoryTitle(
                                  onBack: widget.onBack,
                                ),
                                const SizedBox(height: 16),
                                _DateFilterCard(
                                  fromDate: _fromDate,
                                  toDate: _toDate,
                                  onFromTap: () => _pickDate(isFrom: true),
                                  onToTap: () => _pickDate(isFrom: false),
                                  onApply: _fetchHistory,
                                  formatDate: _formatPickerDate,
                                  isBusy: showTopProgress,
                                ),
                                const SizedBox(height: 16),
                                if (isHistoryError)
                                  _VerificationHistoryError(
                                    message: errorMessage,
                                    onRetry: _fetchHistory,
                                  )
                                else
                                  UserManagementTableCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            4,
                                            4,
                                            4,
                                            12,
                                          ),
                                          child: Text(
                                            'Payment verification records',
                                            style: TextStyle(
                                              fontSize: 11.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                        _HistoryTable(
                                          rows: rows,
                                          formatDate: _formatRowDate,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Showing $totalCount record'
                                          '${totalCount == 1 ? '' : 's'}',
                                          style: TextStyle(
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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

class _VerificationHistoryError extends StatelessWidget {
  const _VerificationHistoryError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
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
      ),
    );
  }
}

class _VerificationHistoryTitle extends StatelessWidget {
  const _VerificationHistoryTitle({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Monthly Payment List',
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
                Text(
                  'Verification history',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Verification history',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All investors — reviewed payment verifications',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Material(
          color: AppColors.newBorder,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    'Back to Monthly Payment List',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            backButton,
          ],
        );
      },
    );
  }
}

class _DateFilterCard extends StatelessWidget {
  const _DateFilterCard({
    required this.fromDate,
    required this.toDate,
    required this.onFromTap,
    required this.onToTap,
    required this.onApply,
    required this.formatDate,
    this.isBusy = false,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onApply;
  final String Function(DateTime) formatDate;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack = constraints.maxWidth < 520;

          final dates = Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'From',
                  value: formatDate(fromDate),
                  onTap: onFromTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'To',
                  value: formatDate(toDate),
                  onTap: onToTap,
                ),
              ),
            ],
          );

          final apply = FilledButton(
            onPressed: isBusy ? null : onApply,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                dates,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: apply),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: dates),
              const SizedBox(width: 12),
              apply,
            ],
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
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
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({
    required this.rows,
    required this.formatDate,
  });

  static const _columnGap = 14.0;

  final List<PaymentVerificationHistoryRow> rows;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No records for this date range',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1280),
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
                  _header('#', 44),
                  _header('Investor', 120),
                  _header('Code', 80),
                  _header('Staff', 92),
                  _header('Payment date', 108),
                  _header('Amount', 100),
                  _header('Method', 96),
                  _header('Status', 112),
                  _header('Reject reason', 220),
                  _header('Verified by', 100),
                  _header('Verified on', 108, gapAfter: false),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...rows.map(
              (row) => Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 1),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: AppColors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cell('${row.transactionId}', 44),
                    _cell(row.investorName, 120),
                    _cell(row.investorCode, 80),
                    _cell(row.staff, 92),
                    _cell(formatDate(row.paymentDate), 108),
                    _cell(CurrencyFormatter.format(row.amount), 100, bold: true),
                    _cell(row.method, 96),
                    _statusCell(
                      label: row.status == VerificationHistoryStatus.approved
                          ? 'Accepted'
                          : 'Rejected',
                      tone: row.status == VerificationHistoryStatus.approved
                          ? UserManagementBadgeTone.success
                          : UserManagementBadgeTone.danger,
                    ),
                    _cell(
                      row.rejectReason ?? '—',
                      220,
                      muted: row.rejectReason == null,
                    ),
                    _cell(row.verifiedBy, 100),
                    _cell(
                      formatDate(row.verifiedDate),
                      108,
                      gapAfter: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    String text,
    double width, {
    bool gapAfter = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: gapAfter ? _columnGap : 0),
      child: SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _statusCell({
    required String label,
    required UserManagementBadgeTone tone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: _columnGap),
      child: SizedBox(
        width: 112,
        child: Align(
          alignment: Alignment.centerLeft,
          child: UserManagementStatusBadge(label: label, tone: tone),
        ),
      ),
    );
  }

  Widget _cell(
    String text,
    double width, {
    bool bold = false,
    bool muted = false,
    bool gapAfter = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: gapAfter ? _columnGap : 0),
      child: SizedBox(
        width: width,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: muted ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
