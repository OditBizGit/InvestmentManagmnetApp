import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/core/utils/go_to_top_button.dart';
import 'package:maribel_wellness_centre_application/user/profile/cubit/profile_cubit.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investment_due_date_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:sizer/sizer.dart';

class InvestmentDetailsScreen extends StatefulWidget {
  const InvestmentDetailsScreen({
    super.key,
    this.details,
    this.fullName = 'Investor',
    this.investorCode = 'INV - 0000',
    this.profileImageUrl,
    this.totalCommitment = 000000,
    this.advanceAmount = 0,
    this.installmentCount = 0,
    this.paymentFrequency = '-',
    this.durationInterval = 1,
    this.investmentDate,
    this.dueDates = const [],
  });

  /// When provided, all investment fields are taken from this model.
  final InvestorDetailsModel? details;

  final String fullName;
  final String investorCode;
  final String? profileImageUrl;

  /// Total investment commitment amount.
  final double totalCommitment;

  /// Optional advance deducted before installment split.
  final double advanceAmount;

  /// Number of installments after advance.
  final int installmentCount;

  /// Payment frequency: `Month`, `Week`, or `Day`.
  final String paymentFrequency;

  /// Gap between payments (used for Week/Day; Month uses 1).
  final int durationInterval;

  final DateTime? investmentDate;

  final List<InvestmentDueDateModel> dueDates;

  static const Color _greenSoft = Color(0xFFE6F6EC);
  static const Color _teal = Color(0xFF2BB8A8);
  static const Color _cardBorder = Color(0xFFE8E4EE);

  /// Fixed card height so completed / pending / next-due cards stay aligned.
  static const double _cardMinHeight = 100;

  @override
  State<InvestmentDetailsScreen> createState() =>
      _InvestmentDetailsScreenState();
}

class _InvestmentDetailsScreenState extends State<InvestmentDetailsScreen> {
  static const _silentRefreshInterval = Duration(seconds: 5);

  final ScrollController _scrollController = ScrollController();
  Timer? _silentRefreshTimer;
  InvestorDetailsModel? _details;
  bool _isSilentRefreshing = false;
  bool _showGoToTop = false;

  @override
  void initState() {
    super.initState();
    _details = widget.details;
    _scrollController.addListener(_handleScroll);
    // Fetch latest data as soon as the screen opens (periodic timer waits
    // until the first interval, which left users on stale profile data).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _silentRefresh();
    });
    _silentRefreshTimer = Timer.periodic(
      _silentRefreshInterval,
      (_) => _silentRefresh(),
    );
  }

  @override
  void didUpdateWidget(covariant InvestmentDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.details != oldWidget.details && !_isSilentRefreshing) {
      _details = widget.details;
    }
  }

  @override
  void dispose() {
    _silentRefreshTimer?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final shouldShow = _resolvedInstallmentCount > 8 &&
        GoToTopButton.shouldShow(
          offset: position.pixels,
          maxExtent: position.maxScrollExtent,
        );
    if (shouldShow == _showGoToTop) return;
    setState(() => _showGoToTop = shouldShow);
  }

  Future<void> _scrollToTop() => GoToTopButton.animateToTop(_scrollController);

  Future<void> _silentRefresh() async {
    if (!mounted || _isSilentRefreshing) return;

    final cubit = context.read<ProfileCubit>();
    _isSilentRefreshing = true;
    try {
      await cubit.loadProfile(silent: true);
      if (!mounted) return;
      final state = cubit.state;
      if (state is ProfileSuccess) {
        setState(() => _details = state.details);
      }
    } finally {
      _isSilentRefreshing = false;
    }
  }

  InvestorDetailsModel? get details => _details;

  String get fullName => widget.fullName;
  String get investorCode => widget.investorCode;
  String? get profileImageUrl => widget.profileImageUrl;
  double get totalCommitment => widget.totalCommitment;
  double get advanceAmount => widget.advanceAmount;
  int get installmentCount => widget.installmentCount;
  String get paymentFrequency => widget.paymentFrequency;
  int get durationInterval => widget.durationInterval;
  DateTime? get investmentDate => widget.investmentDate;
  List<InvestmentDueDateModel> get dueDates => widget.dueDates;

  String get _resolvedFullName {
    final name = details?.fullName.trim();
    if (name != null && name.isNotEmpty) return name;
    return fullName;
  }

  String get _resolvedInvestorCode {
    final code = details?.investorCode?.trim();
    if (code == null || code.isEmpty) return investorCode;
    if (code.toUpperCase().startsWith('INV')) return code;
    return 'INV - $code';
  }

  String? get _resolvedProfileImageUrl =>
      details?.profileImageUrl ?? profileImageUrl;

  double get _resolvedCommitment {
    final amount = details?.investmentAmount ?? totalCommitment;
    return amount > 0 ? amount : totalCommitment;
  }

  double get _resolvedAdvance =>
      details?.investmentAdvanceAmount ?? advanceAmount;

  int get _resolvedInstallmentCount {
    final fromDetails = details?.investmentSplitMonths ?? 0;
    if (fromDetails > 0) return fromDetails;
    final fromDueDates =
        (details?.dueDates.isNotEmpty == true ? details!.dueDates : dueDates)
            .length;
    if (fromDueDates > 0) return fromDueDates;
    return installmentCount > 0 ? installmentCount : 0;
  }

  String get _resolvedPaymentFrequency {
    final type = details?.investmentSplitType ?? paymentFrequency;
    return type.trim().isEmpty ? 'Month' : type.trim();
  }

  int get _resolvedDurationInterval {
    final gap = details?.investmentSplitGap ?? durationInterval;
    return gap <= 0 ? 1 : gap;
  }

  DateTime? get _resolvedInvestmentDate =>
      details?.investmentDate ?? investmentDate;

  List<InvestmentDueDateModel> get _resolvedDueDates =>
      details?.dueDates.isNotEmpty == true ? details!.dueDates : dueDates;

  bool get _hasAdvance => _resolvedAdvance > 0;

  bool get _isFullyPaid {
    final commitment = _resolvedCommitment;
    if (commitment <= 0) return false;

    final pending = details?.totalPendingAmount;
    if (pending != null) {
      return pending <= 0;
    }

    final dues = _resolvedDueDates;
    if (dues.isNotEmpty) {
      return dues.every((due) => due.isFullyPaid);
    }

    return false;
  }

  String get installmentDurationLabel {
    final interval = _resolvedDurationInterval;
    switch (_resolvedPaymentFrequency) {
      case 'Week':
        return interval == 1 ? 'Weekly' : 'Every $interval Weeks';
      case 'Day':
        return interval == 1 ? 'Daily' : 'Every $interval Days';
      case 'Month':
      default:
        return interval == 1 ? 'Monthly' : 'Every $interval Months';
    }
  }

  List<_PaymentScheduleItem> get _payments => _buildPaymentSchedule();

  List<_PaymentScheduleItem> _buildPaymentSchedule() {
    final apiDueDates = _resolvedDueDates;
    if (apiDueDates.isNotEmpty) {
      return _buildFromApiDueDates(apiDueDates);
    }
    return _buildGeneratedSchedule();
  }

  List<_PaymentScheduleItem> _buildFromApiDueDates(
    List<InvestmentDueDateModel> apiDueDates,
  ) {
    final schedule = <_PaymentScheduleItem>[];
    final start = _resolvedInvestmentDate ?? DateTime.now();

    if (_hasAdvance) {
      schedule.add(
        _PaymentScheduleItem(
          date: _formatDate(start),
          label: 'Advance Payment',
          amount: _formatCurrency(_resolvedAdvance),
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

      final status = markedNextDue
          ? _PaymentStatus.pending
          : _PaymentStatus.nextDue;
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
    final commitment = _resolvedCommitment;
    final advance = _resolvedAdvance < 0 ? 0.0 : _resolvedAdvance;
    final count = _resolvedInstallmentCount;
    final interval = _resolvedDurationInterval;

    if (commitment <= 0 || count <= 0 || advance > commitment) {
      return const [];
    }

    final start = _resolvedInvestmentDate ?? DateTime.now();
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
    switch (_resolvedPaymentFrequency) {
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

  @override
  Widget build(BuildContext context) {
    final payments = _payments;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 5.5.w,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Investment Details',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeader(
                          fullName: _resolvedFullName,
                          investorCode: _resolvedInvestorCode,
                          profileImageUrl: _resolvedProfileImageUrl,
                        ),
                        SizedBox(height: 2.5.h),
                        Text(
                          'Total Commitment',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 0.1.h),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: _isFullyPaid ? 3.w : 0,
                              ),
                              child: Text(
                                _formatCurrency(_resolvedCommitment),
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_isFullyPaid)
                              Positioned(
                                top: 0.2.h,
                                right: 0,
                                child: SizedBox(
                                  width: 3.2.w,
                                  height: 3.2.w,
                                  child: SvgPicture.asset(
                                    ImageConstants.tick,
                                    width: 2.2.w,
                                    height: 2.2.w,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.green,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          (details?.totalPendingAmount ?? 0) <= 0
                              ? 'Commitment completed'
                              : 'Balance: ${_formatCurrency(details?.totalPendingAmount ?? 0)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: (details?.totalPendingAmount ?? 0) <= 0
                                ? AppColors.green
                                : AppColors.error,
                          ),
                        ),
                        SizedBox(height: 0.1.h),
                        _InvestmentMetaRow(
                          installmentCount: _resolvedInstallmentCount,
                          durationLabel: installmentDurationLabel,
                        ),
                        SizedBox(height: 2.h),
                        for (var i = 0; i < payments.length; i++) ...[
                          _PaymentCard(item: payments[i]),
                          if (i != payments.length - 1) SizedBox(height: 1.4.h),
                        ],
                        // SizedBox(height: 2.8.h),
                        // Text(
                        //   'Recent Transaction',
                        //   style: TextStyle(
                        //     fontSize: 15.5.sp,
                        //     fontWeight: FontWeight.w700,
                        //     color: AppColors.textPrimary,
                        //   ),
                        // ),
                        // SizedBox(height: 1.5.h),
                        // // Dummy UI — replace with dedicated recent-transaction API later.
                        // _RecentTransactionCard(
                        //   amount: _formatCurrency(
                        //     _hasAdvance ? _resolvedAdvance : 5000,
                        //   ),
                        //   label: _hasAdvance ? 'Advance Payment' : 'Installment 1',
                        //   date: _formatDate(
                        //     _resolvedInvestmentDate ?? DateTime.now(),
                        //   ),
                        //   paymentMethod: 'Bank Transfer',
                        // ),
                      ],
                    ),
                  ),
                  GoToTopOverlay(
                    visible: _showGoToTop && _resolvedInstallmentCount > 8,
                    onTap: _scrollToTop,
                    bottom: 2.5.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _InvestmentMetaRow extends StatelessWidget {
  const _InvestmentMetaRow({
    required this.installmentCount,
    required this.durationLabel,
  });

  final int installmentCount;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetaItem(
            label: 'No. of Installments',
            value: '$installmentCount',
            alignEnd: false,
          ),
        ),
        Expanded(
          child: _MetaItem(
            label: 'Installment Duration',
            value: durationLabel,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final alignment =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 0.1.h),
        Text(
          value,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.investorCode,
    this.profileImageUrl,
  });

  final String fullName;
  final String investorCode;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        profileImageUrl != null && profileImageUrl!.isNotEmpty;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(0.2.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 8.w,
            backgroundColor: AppColors.cardBg,
            backgroundImage:
                hasImage ? NetworkImage(profileImageUrl!) : null,
            child: hasImage
                ? null
                : Icon(
                    Icons.person_rounded,
                    size: 8.w,
                    color: AppColors.accent,
                  ),
          ),
        ),
        SizedBox(width: 3.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 0.6.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.45.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  investorCode,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
      constraints: const BoxConstraints(
        minHeight: InvestmentDetailsScreen._cardMinHeight,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: _isCompleted
            ? InvestmentDetailsScreen._greenSoft
            : AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(
          color: _isCompleted
              ? InvestmentDetailsScreen._greenSoft
              : InvestmentDetailsScreen._cardBorder,
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
                    color: _isCompleted
                        ? AppColors.green
                        : AppColors.textPrimary,
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
        color: isCompleted ? InvestmentDetailsScreen._teal : Colors.transparent,
        borderRadius: BorderRadius.circular(1.w),
        border: isCompleted
            ? null
            : Border.all(color: InvestmentDetailsScreen._cardBorder),
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

class _RecentTransactionCard extends StatelessWidget {
  const _RecentTransactionCard({
    required this.amount,
    required this.label,
    required this.date,
    required this.paymentMethod,
  });

  final String amount;
  final String label;
  final String date;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: InvestmentDetailsScreen._cardBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maribel Investment',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 0.35.h),
                    Text(
                      paymentMethod,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                ImageConstants.print,
                width: 5.5.w,
                height: 5.5.w,
              ),
            ],
          ),
          SizedBox(height: 1.6.h),
          Row(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
