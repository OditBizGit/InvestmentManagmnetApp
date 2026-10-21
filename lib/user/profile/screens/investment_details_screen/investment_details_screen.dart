import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/go_to_top_button.dart';
import 'package:maribel_wellness_centre_application/user/profile/cubit/profile_cubit.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investment_due_date_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/investment_details_screen/widgets/investment_summary_section.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/investment_details_screen/widgets/payment_schedule_section.dart';
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

  @override
  Widget build(BuildContext context) {
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
                        InvestmentSummarySection(
                          fullName: _resolvedFullName,
                          investorCode: _resolvedInvestorCode,
                          profileImageUrl: _resolvedProfileImageUrl,
                          commitment: _resolvedCommitment,
                          isFullyPaid: _isFullyPaid,
                          pendingAmount: details?.totalPendingAmount ?? 0,
                          discountAmount: details?.discountAmount ?? 0,
                          lastPaymentAmount: details?.lastPaymentAmount ?? 0,
                          lastPaymentDate: details?.lastPaymentDate,
                          installmentCount: _resolvedInstallmentCount,
                          paymentFrequency: _resolvedPaymentFrequency,
                          durationInterval: _resolvedDurationInterval,
                        ),
                        SizedBox(height: 2.h),
                        PaymentScheduleSection(
                          dueDates: _resolvedDueDates,
                          investmentDate: _resolvedInvestmentDate,
                          advanceAmount: _resolvedAdvance,
                          commitment: _resolvedCommitment,
                          installmentCount: _resolvedInstallmentCount,
                          durationInterval: _resolvedDurationInterval,
                          paymentFrequency: _resolvedPaymentFrequency,
                        ),
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
