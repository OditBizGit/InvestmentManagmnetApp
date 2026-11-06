import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_investor_amount_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_report_row_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_details_investors_section.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({
    super.key,
    required this.staff,
    required this.period,
    required this.onBack,
    required this.onPeriodChanged,
  });

  final StaffReportRowModel staff;
  final StaffReportPeriod period;
  final VoidCallback onBack;
  final ValueChanged<StaffReportPeriod> onPeriodChanged;

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  static final _sampleInvestors = <StaffInvestorAmountModel>[
    StaffInvestorAmountModel(
      investorCode: 'INV-1160',
      investorName: 'Ashraf Ali',
      amountReceived: 180000,
      amountReceivedDate: DateTime(2026, 10, 4),
    ),
    StaffInvestorAmountModel(
      investorCode: 'INV-1184',
      investorName: 'Noorjahan',
      amountReceived: 155000,
      amountReceivedDate: DateTime(2026, 10, 8),
    ),
    StaffInvestorAmountModel(
      investorCode: 'INV-1201',
      investorName: 'Zainab T',
      amountReceived: 210000,
      amountReceivedDate: DateTime(2026, 10, 12),
    ),
    StaffInvestorAmountModel(
      investorCode: 'INV-1215',
      investorName: 'Muhammed S',
      amountReceived: 120000,
      amountReceivedDate: DateTime(2026, 10, 18),
    ),
    StaffInvestorAmountModel(
      investorCode: 'INV-1232',
      investorName: 'Amina R',
      amountReceived: 175000,
      amountReceivedDate: DateTime(2026, 10, 22),
    ),
  ];

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
      StaffReportPeriod.thisYear => 'This Year (${now.year})',
      StaffReportPeriod.allTime => 'All Time',
    };
  }

  @override
  Widget build(BuildContext context) {
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
                        period: widget.period,
                        onPeriodChanged: widget.onPeriodChanged,
                      ),
                      const SizedBox(height: 18),
                      StaffDetailsInvestorsSection(
                        period: widget.period,
                        items: _sampleInvestors,
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
    required this.period,
    required this.onPeriodChanged,
  });

  final StaffReportRowModel staff;
  final String periodLabel;
  final StaffReportPeriod period;
  final ValueChanged<StaffReportPeriod> onPeriodChanged;

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
                initialValue: period,
                onSelected: onPeriodChanged,
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
                            fontWeight: option == period
                                ? FontWeight.w600
                                : FontWeight.w400,
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
                value: CurrencyFormatter.format(staff.totalAmount),
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
  });

  final IconData icon;
  final String label;
  final String value;

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
