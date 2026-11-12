import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/cubit/staff_report_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_investor_amount_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_report_details_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_report_row_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_details_investors_section.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({
    super.key,
    required this.staff,
    required this.period,
    this.customFromDate,
    this.customToDate,
    required this.onBack,
    required this.onPeriodChanged,
  });

  final StaffReportRowModel staff;
  final StaffReportPeriod period;
  final DateTime? customFromDate;
  final DateTime? customToDate;
  final VoidCallback onBack;
  final void Function(
    StaffReportPeriod period, {
    DateTime? customFromDate,
    DateTime? customToDate,
    bool clearCustomDates,
  }) onPeriodChanged;

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDetails();
      }
    });
  }

  @override
  void didUpdateWidget(covariant StaffDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.staff.staffId != widget.staff.staffId ||
        oldWidget.period != widget.period ||
        oldWidget.customFromDate != widget.customFromDate ||
        oldWidget.customToDate != widget.customToDate) {
      _loadDetails();
    }
  }

  String _formatApiDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _loadDetails() {
    if (widget.period == StaffReportPeriod.custom &&
        (widget.customFromDate == null || widget.customToDate == null)) {
      return;
    }

    context.read<StaffReportCubit>().fetchStaffReportDetails(
      staffId: widget.staff.staffId,
      period: widget.period.apiValue,
      fromDate: widget.period == StaffReportPeriod.custom &&
              widget.customFromDate != null
          ? _formatApiDate(widget.customFromDate!)
          : null,
      toDate: widget.period == StaffReportPeriod.custom &&
              widget.customToDate != null
          ? _formatApiDate(widget.customToDate!)
          : null,
    );
  }

  Future<void> _handlePeriodSelected(StaffReportPeriod period) async {
    if (period == StaffReportPeriod.custom) {
      final dateRange = await showStaffReportCustomDateRangeDialog(
        context: context,
        initialRange: widget.customFromDate != null &&
                widget.customToDate != null
            ? DateTimeRange(
                start: widget.customFromDate!,
                end: widget.customToDate!,
              )
            : null,
      );

      if (!mounted || dateRange == null) return;

      widget.onPeriodChanged(
        StaffReportPeriod.custom,
        customFromDate: dateRange.start,
        customToDate: dateRange.end,
      );
      return;
    }

    widget.onPeriodChanged(period, clearCustomDates: true);
  }

  void _handleBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        widget.onBack();
      });
    });
  }

  String get _periodChipLabel {
    final now = DateTime.now();
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

    return switch (widget.period) {
      StaffReportPeriod.thisMonth =>
        'This Month (${months[now.month - 1]} ${now.year})',
      StaffReportPeriod.lastMonth => () {
          final last = DateTime(now.year, now.month - 1);
          return 'Last Month (${months[last.month - 1]} ${last.year})';
        }(),
      StaffReportPeriod.custom => () {
          final from = widget.customFromDate;
          final to = widget.customToDate;
          if (from == null || to == null) {
            return 'Custom';
          }
          return 'Custom (${_formatApiDate(from)} - ${_formatApiDate(to)})';
        }(),
    };
  }

  double _totalAmountFromDetails(List<StaffReportDetailsModel> details) {
    return details.fold<double>(
      0,
      (sum, item) => sum + item.netAmount,
    );
  }

  List<StaffInvestorAmountModel> _mapInvestors(
    List<StaffReportDetailsModel> details,
  ) {
    return details
        .map(
          (item) => StaffInvestorAmountModel(
            investorCode: item.investorCode,
            investorName: item.investorName,
            amountReceived: item.netAmount,
            amountReceivedDate: item.paymentDate,
            refundAmount: item.refundAmount,

          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffReportCubit, StaffReportState>(
      listenWhen: (previous, current) =>
          current.detailsStatus == StaffReportDetailsStatus.failure &&
          current.detailsErrorMessage != null &&
          previous.detailsErrorMessage != current.detailsErrorMessage,
      listener: (context, state) {
        AppToast.error(state.detailsErrorMessage!, context: context);
      },
      buildWhen: (previous, current) =>
          previous.detailsStatus != current.detailsStatus ||
          previous.details != current.details ||
          previous.detailsErrorMessage != current.detailsErrorMessage,
      builder: (context, state) {
        final isLoading =
            state.detailsStatus == StaffReportDetailsStatus.loading;
        final errorMessage =
            state.detailsStatus == StaffReportDetailsStatus.failure
                ? state.detailsErrorMessage
                : null;
        final investors = _mapInvestors(state.details);
        final isTotalLoading =
            state.detailsStatus == StaffReportDetailsStatus.loading;
        final totalAmountLabel = switch (state.detailsStatus) {
          StaffReportDetailsStatus.success => CurrencyFormatter.format(
              _totalAmountFromDetails(state.details),
            ),
          StaffReportDetailsStatus.loading ||
          StaffReportDetailsStatus.initial =>
            CurrencyFormatter.format(widget.staff.totalAmount),
          StaffReportDetailsStatus.failure => state.details.isNotEmpty
              ? CurrencyFormatter.format(
                  _totalAmountFromDetails(state.details),
                )
              : CurrencyFormatter.format(widget.staff.totalAmount),
        };

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 16.0 : 24.0;

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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StaffDetailsTitle(onBack: _handleBack),
                          const SizedBox(height: 16),
                          _StaffProfileCard(
                            staff: widget.staff,
                            periodLabel: _periodChipLabel,
                            onPeriodSelected: _handlePeriodSelected,
                            totalAmountLabel: totalAmountLabel,
                            isTotalLoading: isTotalLoading,
                          ),
                          const SizedBox(height: 18),
                          StaffDetailsInvestorsSection(
                            period: widget.period,
                            isLoading: isLoading,
                            errorMessage: errorMessage,
                            onRetry: _loadDetails,
                            items: investors,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StaffDetailsTitle extends StatelessWidget {
  const _StaffDetailsTitle({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Details',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Investors and amounts for this staff',
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
                    'Back to Staff Report',
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

class _StaffProfileCard extends StatelessWidget {
  const _StaffProfileCard({
    required this.staff,
    required this.periodLabel,
    required this.onPeriodSelected,
    required this.totalAmountLabel,
    required this.isTotalLoading,
  });

  final StaffReportRowModel staff;
  final String periodLabel;
  final ValueChanged<StaffReportPeriod> onPeriodSelected;
  final String totalAmountLabel;
  final bool isTotalLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 820;

          final identity = Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  ImageConstants.username,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.accent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${staff.code}  |  Mobile: ${staff.mobileNumber}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final stats = Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<StaffReportPeriod>(
                onSelected: onPeriodSelected,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                itemBuilder: (context) {
                  return [
                    for (final option in StaffReportPeriod.values)
                      PopupMenuItem(
                        value: option,
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ];
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textMuted,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        periodLabel,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              _ProfileStat(
                icon: Icons.payments_outlined,
                label: 'Total Amount',
                value: totalAmountLabel,
                isLoading: isTotalLoading,
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: 16),
                stats,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            if (isLoading)
              SizedBox(
                height: 13.sp * 1.2,
                width: 13.sp * 1.2,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
