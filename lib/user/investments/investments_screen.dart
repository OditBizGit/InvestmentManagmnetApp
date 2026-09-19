import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/core/utils/go_to_top_button.dart';
import 'package:maribel_wellness_centre_application/user/investments/cubit/investments_cubit.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_history_data_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/widgets/recent_transactions_section.dart';
import 'package:maribel_wellness_centre_application/user/investments/widgets/work_progress_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UserInvestmentsScreen extends StatelessWidget {
  const UserInvestmentsScreen({super.key});

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _accent = Color(0xFFA28CC1);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _green = Color(0xFF1BA752);
  static const Color _greenSoft = Color(0xFFE6F6EC);
  static const Color _red = Color(0xFFE05A4F);
  static const Color _border = Color(0xFFE8E4EE);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InvestmentsCubit>()..loadInvestments(),
      child: const _UserInvestmentsView(),
    );
  }

  static String formatCurrency(double amount) => CurrencyFormatter.format(amount);

  static String investorCodeLabel(String? code) {
    if (code == null || code.isEmpty) return '—';
    final trimmed = code.trim();
    if (trimmed.toUpperCase().startsWith('INV')) return trimmed;
    return 'INV-$trimmed';
  }

  static String formatNextPaymentDate(DateTime? date) => formatDate(date);

  /// Format: DD-MMM-YYYY h:mm AM/PM (e.g. 18-SEP-2026 2:30 PM).
  static String formatTransactionDate(DateTime? date) {
    if (date == null) return '—';
    return '${formatDate(date)} ${formatTransactionTime(date)}';
  }

  /// Format: h:mm AM/PM (e.g. 2:30 PM).
  static String formatTransactionTime(DateTime? date) {
    if (date == null) return '';
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  /// Format: DD-MMM-YYYY (e.g. 18-SEP-2026).
  static String formatDate(DateTime? date) {
    if (date == null) return '—';
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
    final day = date.day.toString().padLeft(2, '0');
    return '$day-${months[date.month - 1]}-${date.year}';
  }
}

class _UserInvestmentsView extends StatefulWidget {
  const _UserInvestmentsView();

  @override
  State<_UserInvestmentsView> createState() => _UserInvestmentsViewState();
}

class _UserInvestmentsViewState extends State<_UserInvestmentsView> {
  static const _silentRefreshInterval = Duration(seconds: 5);

  final ScrollController _scrollController = ScrollController();
  Timer? _silentRefreshTimer;
  bool _isSilentRefreshing = false;
  bool _showGoToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _silentRefreshTimer = Timer.periodic(
      _silentRefreshInterval,
      (_) => _silentRefresh(),
    );
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

    final state = context.read<InvestmentsCubit>().state;
    final transactionCount = state is InvestmentsSuccess
        ? state.data.transactions.length
        : 0;

    final position = _scrollController.position;
    final shouldShow = transactionCount > 3 &&
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

    _isSilentRefreshing = true;
    try {
      await context.read<InvestmentsCubit>().loadInvestments(silent: true);
    } finally {
      _isSilentRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: BlocConsumer<InvestmentsCubit, InvestmentsState>(
          listener: (context, state) {
            if (state is InvestmentsFailure) {
              AppSnackBar.show(
                context,
                message: state.message,
                icon: Icons.error_outline_rounded,
              );
            }
          },
          builder: (context, state) {
            // Full-page shimmer only on first open / explicit refresh —
            // silent refresh keeps showing the last successful data.
            final isLoading =
                state is InvestmentsInitial || state is InvestmentsLoading;
            final data = state is InvestmentsSuccess ? state.data : null;
            final transactionCount = data?.transactions.length ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0.8.h),
                  child: _InvestmentsHeader(
                    investorCode: data?.investorCode,
                    isLoading: isLoading,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: () =>
                            context.read<InvestmentsCubit>().loadInvestments(),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.5.h),
                          child: isLoading
                              ? const _InvestmentsShimmer()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _ProjectHeroCard(data: data),
                                    SizedBox(height: 1.8.h),
                                    _InvestmentAmountCard(
                                      amount: data?.totalInvestmentAmount ?? 0,
                                    ),
                                    SizedBox(height: 1.5.h),
                                    _NextPaymentCard(
                                      date: data?.nextDueDate,
                                      amount: data?.nextDueAmount ?? 0,
                                    ),
                                    SizedBox(height: 1.5.h),
                                    _CapitalAllocationCard(
                                      totalPaid: data?.totalPaidAmount ?? 0,
                                      totalBalance:
                                          data?.totalPendingAmount ?? 0,
                                    ),
                                    SizedBox(height: 1.5.h),
                                    const WorkProgressCard(),
                                    SizedBox(height: 2.5.h),
                                    RecentTransactionsSection(
                                      projectName: data?.projectName ?? '',
                                      transactions:
                                          data?.transactions ?? const [],
                                    ),
                                    SizedBox(height: 2.h),
                                  ],
                                ),
                        ),
                      ),
                      GoToTopOverlay(
                        visible: _showGoToTop && transactionCount > 3,
                        onTap: _scrollToTop,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InvestmentsHeader extends StatelessWidget {
  const _InvestmentsHeader({
    this.investorCode,
    this.isLoading = false,
  });

  final String? investorCode;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Investment',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: UserInvestmentsScreen._textPrimary,
          ),
        ),
        SizedBox(height: 1.2.h),
        if (isLoading)
          const _HeaderChipsShimmer()
        else
          Row(
            children: [
              _StatusChip(
                background: UserInvestmentsScreen._accentSoft,
                iconPath: ImageConstants.investors,
                iconColor: UserInvestmentsScreen._accent,
                label:
                    'Investor ID: ${UserInvestmentsScreen.investorCodeLabel(investorCode)}',
                labelColor: UserInvestmentsScreen._accent,
              ),
              const Spacer(),
              _StatusChip(
                background: UserInvestmentsScreen._greenSoft,
                iconPath: ImageConstants.active,
                iconColor: UserInvestmentsScreen._green,
                label: 'Active',
                labelColor: UserInvestmentsScreen._green,
              ),
            ],
          ),
      ],
    );
  }
}

class _HeaderChipsShimmer extends StatelessWidget {
  const _HeaderChipsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: UserInvestmentsScreen._shimmerBase,
      highlightColor: UserInvestmentsScreen._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: Row(
        children: [
          _StatusChipShimmer(sample: 'Investor ID: INV-0000'),
          const Spacer(),
          _StatusChipShimmer(sample: 'Active'),
        ],
      ),
    );
  }
}

/// Matches [_StatusChip] padding / radius so shimmer height matches the chip.
class _StatusChipShimmer extends StatelessWidget {
  const _StatusChipShimmer({required this.sample});

  final String sample;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4.2.w, height: 4.2.w),
          SizedBox(width: 1.5.w),
          Text(
            sample,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.background,
    required this.iconPath,
    required this.iconColor,
    required this.label,
    required this.labelColor,
  });

  final Color background;
  final String iconPath;
  final Color iconColor;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 4.2.w,
            height: 4.2.w,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: 1.5.w),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeroCard extends StatelessWidget {
  const _ProjectHeroCard({this.data});

  final InvestorTransactionHistoryDataModel? data;

  @override
  Widget build(BuildContext context) {
    final imageUrl = data?.projectImageUrl;
    final projectName = (data?.projectName.trim().isNotEmpty ?? false)
        ? data!.projectName
        : '—';
    final projectDescription =
        (data?.projectDescription.trim().isNotEmpty ?? false)
            ? data!.projectDescription
            : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _ProjectImageFallback(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: UserInvestmentsScreen._accentSoft,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            else
              const _ProjectImageFallback(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x99000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.45, 0.75, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (projectDescription.isNotEmpty)
                    Text(
                      projectDescription,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
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

class _ProjectImageFallback extends StatelessWidget {
  const _ProjectImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UserInvestmentsScreen._accentSoft,
      child: Icon(
        Icons.apartment_outlined,
        color: UserInvestmentsScreen._accent,
        size: 12.w,
      ),
    );
  }
}

class _InfoCardShell extends StatelessWidget {
  const _InfoCardShell({
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = UserInvestmentsScreen._border,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _InvestmentAmountCard extends StatelessWidget {
  const _InvestmentAmountCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Commitment',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: UserInvestmentsScreen._textSecondary,
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            UserInvestmentsScreen.formatCurrency(amount),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: UserInvestmentsScreen._green,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPaymentCard extends StatelessWidget {
  const _NextPaymentCard({
    required this.date,
    required this.amount,
  });

  final DateTime? date;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final isCompleted = date == null;

    if (isCompleted) {
      return _InfoCardShell(
        backgroundColor: UserInvestmentsScreen._green,
        borderColor: UserInvestmentsScreen._greenSoft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Commitment Completed',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SvgPicture.asset(
              ImageConstants.tick,
              width: 5.w,
              height: 5.w,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      );
    }

    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Payment',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: UserInvestmentsScreen._textSecondary,
            ),
          ),
          SizedBox(height: 0.6.h),
          Row(
            children: [
              SvgPicture.asset(
                ImageConstants.calender,
                width: 4.w,
                height: 4.w,
                colorFilter: const ColorFilter.mode(
                  UserInvestmentsScreen._accent,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  UserInvestmentsScreen.formatNextPaymentDate(date),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: UserInvestmentsScreen._textPrimary,
                  ),
                ),
              ),
              Text(
                UserInvestmentsScreen.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: UserInvestmentsScreen._accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapitalAllocationCard extends StatelessWidget {
  const _CapitalAllocationCard({
    required this.totalPaid,
    required this.totalBalance,
  });

  final double totalPaid;
  final double totalBalance;

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capital Allocation',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: UserInvestmentsScreen._textPrimary,
            ),
          ),
          SizedBox(height: 1.4.h),
          _AllocationRow(
            label: 'Total Paid',
            amount: UserInvestmentsScreen.formatCurrency(totalPaid),
            amountColor: UserInvestmentsScreen._green,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: UserInvestmentsScreen._border,
            ),
          ),
          _AllocationRow(
            label: 'Total Balance',
            amount: UserInvestmentsScreen.formatCurrency(totalBalance),
            amountColor: UserInvestmentsScreen._red,
          ),
        ],
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  const _AllocationRow({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: UserInvestmentsScreen._textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

class _InvestmentsShimmer extends StatelessWidget {
  const _InvestmentsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProjectHeroShimmer(),
        SizedBox(height: 1.8.h),
        const _InvestmentAmountCardShimmer(),
        SizedBox(height: 1.5.h),
        const _NextPaymentCardShimmer(),
        SizedBox(height: 1.5.h),
        const _CapitalAllocationCardShimmer(),
        SizedBox(height: 1.5.h),
        const WorkProgressCardShimmer(),
        SizedBox(height: 2.5.h),
        const RecentTransactionsSectionShimmer(),
        SizedBox(height: 1.h),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = 4,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Line placeholder sized from sample text so it matches real typography.
///
/// When [widthFactor] is set, width is a fraction of the parent; otherwise
/// the box sizes intrinsically to [sample].
class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.sample,
    required this.style,
    this.widthFactor,
  });

  final String sample;
  final TextStyle style;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        sample,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: style.copyWith(color: Colors.transparent),
      ),
    );

    if (widthFactor == null) return line;

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor!.clamp(0.0, 1.0),
        child: line,
      ),
    );
  }
}

class _InfoCardShellShimmer extends StatelessWidget {
  const _InfoCardShellShimmer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UserInvestmentsScreen._border),
      ),
      child: child,
    );
  }
}

class _ProjectHeroShimmer extends StatelessWidget {
  const _ProjectHeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: UserInvestmentsScreen._shimmerBase,
      highlightColor: UserInvestmentsScreen._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.white),
              Positioned(
                left: 4.w,
                right: 4.w,
                bottom: 2.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerLine(
                      sample: 'Project Name Placeholder',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      widthFactor: 0.55,
                    ),
                    SizedBox(height: 0.4.h),
                    _ShimmerLine(
                      sample: 'Short project description',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      widthFactor: 0.75,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestmentAmountCardShimmer extends StatelessWidget {
  const _InvestmentAmountCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: UserInvestmentsScreen._shimmerBase,
      highlightColor: UserInvestmentsScreen._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: _InfoCardShellShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerLine(
              sample: 'Total Commitment',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              widthFactor: 0.42,
            ),
            SizedBox(height: 0.2.h),
            _ShimmerLine(
              sample: '₹00,00,000',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
              widthFactor: 0.48,
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPaymentCardShimmer extends StatelessWidget {
  const _NextPaymentCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: UserInvestmentsScreen._shimmerBase,
      highlightColor: UserInvestmentsScreen._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: _InfoCardShellShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerLine(
              sample: 'Next Payment',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              widthFactor: 0.36,
            ),
            SizedBox(height: 0.6.h),
            Row(
              children: [
                _ShimmerBox(width: 4.w, height: 4.w, borderRadius: 2),
                SizedBox(width: 2.w),
                Expanded(
                  child: _ShimmerLine(
                    sample: '18-SEP-2026',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    widthFactor: 0.55,
                  ),
                ),
                _ShimmerLine(
                  sample: '₹00,000',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CapitalAllocationCardShimmer extends StatelessWidget {
  const _CapitalAllocationCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: UserInvestmentsScreen._shimmerBase,
      highlightColor: UserInvestmentsScreen._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      period: const Duration(milliseconds: 1400),
      child: _InfoCardShellShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerLine(
              sample: 'Capital Allocation',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
              widthFactor: 0.5,
            ),
            SizedBox(height: 1.4.h),
            const _AllocationRowShimmer(
              labelSample: 'Total Paid',
              amountSample: '₹00,00,000',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: UserInvestmentsScreen._border,
              ),
            ),
            const _AllocationRowShimmer(
              labelSample: 'Total Balance',
              amountSample: '₹00,00,000',
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationRowShimmer extends StatelessWidget {
  const _AllocationRowShimmer({
    required this.labelSample,
    required this.amountSample,
  });

  final String labelSample;
  final String amountSample;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ShimmerLine(
          sample: labelSample,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        _ShimmerLine(
          sample: amountSample,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
