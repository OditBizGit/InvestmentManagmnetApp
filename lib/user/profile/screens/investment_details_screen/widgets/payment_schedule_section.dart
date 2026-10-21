import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investment_due_date_model.dart';
import 'package:sizer/sizer.dart';

const Color _greenSoft = Color(0xFFE6F6EC);
const Color _teal = Color(0xFF2BB8A8);
const Color _cardBorder = Color(0xFFE8E4EE);

/// Fixed card height so completed / pending / next-due cards stay aligned.
const double _cardMinHeight = 100;

class PaymentScheduleSection extends StatelessWidget {
  const PaymentScheduleSection({
    super.key,
    required this.dueDates,
    required this.investmentDate,
    required this.advanceAmount,
    required this.commitment,
    required this.installmentCount,
    required this.durationInterval,
    required this.paymentFrequency,
  });

  final List<InvestmentDueDateModel> dueDates;
  final DateTime? investmentDate;
  final double advanceAmount;
  final double commitment;
  final int installmentCount;
  final int durationInterval;
  final String paymentFrequency;

  bool get _hasAdvance => advanceAmount > 0;

  @override
  Widget build(BuildContext context) {
    final payments = _buildPaymentSchedule();

    return Column(
      children: [
        for (var i = 0; i < payments.length; i++) ...[
          _PaymentCard(item: payments[i]),
          if (i != payments.length - 1) SizedBox(height: 1.4.h),
        ],
      ],
    );
  }

  List<_PaymentScheduleItem> _buildPaymentSchedule() {
    if (dueDates.isNotEmpty) {
      return _buildFromApiDueDates(dueDates);
    }
    return _buildGeneratedSchedule();
  }

  List<_PaymentScheduleItem> _buildFromApiDueDates(
    List<InvestmentDueDateModel> apiDueDates,
  ) {
    final schedule = <_PaymentScheduleItem>[];
    final start = investmentDate ?? DateTime.now();

    if (_hasAdvance) {
      schedule.add(
        _PaymentScheduleItem(
          date: _formatDate(start),
          label: 'Advance Payment',
          amount: _formatCurrency(advanceAmount),
          status: _PaymentStatus.completed,
          paymentLines: const ['Advance'],
        ),
      );
    }

    var markedNextDue = false;
    for (final due in apiDueDates) {
      final date = due.dueDate ?? start;
      final label = _installmentLabel(due.installmentNumber);
      final paymentLines = _formatPaymentLines(
        due.payments,
        showAmountForSingle: due.isPartiallyPaid,
      );

      if (due.isFullyPaid) {
        schedule.add(
          _PaymentScheduleItem(
            date: _formatDate(date),
            label: label,
            amount: _formatCurrency(due.installmentAmount),
            status: _PaymentStatus.completed,
            paymentLines: paymentLines,
          ),
        );
        continue;
      }

      final status =
          markedNextDue ? _PaymentStatus.pending : _PaymentStatus.nextDue;
      markedNextDue = true;

      final displayAmount = due.isPartiallyPaid && due.pendingAmount > 0
          ? due.pendingAmount
          : due.installmentAmount;

      schedule.add(
        _PaymentScheduleItem(
          date: _formatDate(date),
          label: label,
          amount: _formatCurrency(displayAmount),
          status: status,
          paymentLines: paymentLines,
          isPartiallyPaid: due.isPartiallyPaid,
        ),
      );
    }

    return schedule;
  }

  List<String> _formatPaymentLines(
    List<InvestmentPaymentModel> payments, {
    bool showAmountForSingle = false,
  }) {
    if (payments.length == 1 && !showAmountForSingle) {
      final method = payments.first.paymentMethod?.trim();
      if (method != null && method.isNotEmpty) {
        return [method.toUpperCase()];
      }
      return const [];
    }

    return payments.map((payment) {
      final amount = _formatCurrency(payment.amount);
      final method = payment.paymentMethod?.trim();
      if (method != null && method.isNotEmpty) {
        return '$amount · ${method.toUpperCase()}';
      }
      return amount;
    }).toList();
  }

  List<_PaymentScheduleItem> _buildGeneratedSchedule() {
    final advance = advanceAmount < 0 ? 0.0 : advanceAmount;
    final count = installmentCount;
    final interval = durationInterval;

    if (commitment <= 0 || count <= 0 || advance > commitment) {
      return const [];
    }

    final start = investmentDate ?? DateTime.now();
    final schedule = <_PaymentScheduleItem>[];

    if (advance > 0) {
      schedule.add(
        _PaymentScheduleItem(
          date: _formatDate(start),
          label: 'Advance Payment',
          amount: _formatCurrency(advance),
          status: _PaymentStatus.completed,
          paymentLines: const ['Advance'],
        ),
      );
    }

    final remaining = _roundToTwoDecimals(commitment - advance);
    if (remaining <= 0) return schedule;

    final baseAmount = _roundToTwoDecimals(remaining / count);

    for (var i = 0; i < count; i++) {
      final isLast = i == count - 1;
      final installmentAmount = isLast
          ? _roundToTwoDecimals(remaining - (baseAmount * (count - 1)))
          : baseAmount;

      final dueDate = _dueDateForInstallment(
        start: start,
        installmentIndex: i,
        interval: interval,
      );

      final status = i == 0 ? _PaymentStatus.nextDue : _PaymentStatus.pending;

      schedule.add(
        _PaymentScheduleItem(
          date: _formatDate(dueDate),
          label: _installmentLabel(i + 1),
          amount: _formatCurrency(installmentAmount),
          status: status,
        ),
      );
    }

    return schedule;
  }

  DateTime _dueDateForInstallment({
    required DateTime start,
    required int installmentIndex,
    required int interval,
  }) {
    final step = installmentIndex + 1;
    switch (paymentFrequency) {
      case 'Week':
        return start.add(Duration(days: interval * 7 * step));
      case 'Day':
        return start.add(Duration(days: interval * step));
      case 'Month':
      default:
        return _addMonthsKeepingDay(start, step * interval);
    }
  }

  static DateTime _addMonthsKeepingDay(DateTime date, int months) {
    final totalMonths = date.month - 1 + months;
    final year = date.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
    return DateTime(year, month, day);
  }

  static double _roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static String _installmentLabel(int number) {
    return 'Installment $number';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dd = date.day.toString().padLeft(2, '0');
    return '$dd-${months[date.month - 1]}-${date.year}';
  }

  static String _formatCurrency(double amount) =>
      CurrencyFormatter.format(amount);
}

enum _PaymentStatus { completed, nextDue, pending }

class _PaymentScheduleItem {
  const _PaymentScheduleItem({
    required this.date,
    required this.label,
    required this.amount,
    required this.status,
    this.paymentLines = const [],
    this.isPartiallyPaid = false,
  });

  final String date;
  final String label;
  final String amount;
  final _PaymentStatus status;
  final List<String> paymentLines;
  final bool isPartiallyPaid;
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.item});

  final _PaymentScheduleItem item;

  bool get _isCompleted => item.status == _PaymentStatus.completed;
  bool get _isNextDue => item.status == _PaymentStatus.nextDue;

  @override
  Widget build(BuildContext context) {
    final paymentLines = item.paymentLines;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: _isCompleted ? _greenSoft : AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(
          color: _isCompleted ? _greenSoft : _cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 0.6.h),
              _PaymentLabelBadge(label: item.label, isCompleted: _isCompleted),
              SizedBox(height: 0.8.h),
              if (paymentLines.isEmpty)
                Text(
                  ' ',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                )
              else
                ...[
                  for (var i = 0; i < paymentLines.length; i++) ...[
                    Text(
                      paymentLines[i],
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (i != paymentLines.length - 1) SizedBox(height: 0.25.h),
                  ],
                ],
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _isCompleted ? AppColors.green : AppColors.textPrimary,
                  ),
                ),
              ),
              if (_isCompleted)
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 3.5.w,
                  ),
                )
              else if (_isNextDue)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.isPartiallyPaid) ...[
                      const _StatusChip(
                        label: 'Partially Completed',
                        color: Color(0xFFE6A817),
                      ),
                      SizedBox(height: 0.5.h),
                    ],
                    const _StatusChip(
                      label: 'Next Due',
                      color: AppColors.error,
                    ),
                  ],
                )
              else
                const _StatusChip(
                  label: 'Pending',
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentLabelBadge extends StatelessWidget {
  const _PaymentLabelBadge({
    required this.label,
    required this.isCompleted,
  });

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.45.h),
      decoration: BoxDecoration(
        color: isCompleted ? _teal : Colors.transparent,
        borderRadius: BorderRadius.circular(1.w),
        border: isCompleted ? null : Border.all(color: _cardBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: isCompleted ? AppColors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
