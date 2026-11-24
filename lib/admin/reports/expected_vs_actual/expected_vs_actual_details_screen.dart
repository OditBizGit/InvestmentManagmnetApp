import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/month_range_picker.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import 'cubit/expected_vs_actual_cubit.dart';
import 'widgets/expected_vs_actual_investors_section.dart';

/// In-place drill-down of one month (like the Staff Details screen).
class ExpectedVsActualDetailsScreen extends StatefulWidget {
  const ExpectedVsActualDetailsScreen({
    super.key,
    required this.month,
    required this.onBack,
  });

  final DateTime month;
  final VoidCallback onBack;

  @override
  State<ExpectedVsActualDetailsScreen> createState() =>
      _ExpectedVsActualDetailsScreenState();
}

class _ExpectedVsActualDetailsScreenState
    extends State<ExpectedVsActualDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void didUpdateWidget(covariant ExpectedVsActualDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) _load();
  }

  void _load() {
    context.read<ExpectedVsActualCubit>().fetchDetails(widget.month);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpectedVsActualCubit, ExpectedVsActualState>(
      listenWhen: (previous, current) =>
          current.detailsStatus == ExpectedVsActualDetailsStatus.failure &&
          previous.detailsStatus != ExpectedVsActualDetailsStatus.failure &&
          current.detailsErrorMessage != null,
      listener: (context, state) {
        AppToast.error(state.detailsErrorMessage!, context: context);
      },
      buildWhen: (previous, current) =>
          previous.detailsStatus != current.detailsStatus ||
          previous.details != current.details ||
          previous.detailsErrorMessage != current.detailsErrorMessage,
      builder: (context, state) {
        final isLoading =
            state.detailsStatus == ExpectedVsActualDetailsStatus.loading ||
            state.detailsStatus == ExpectedVsActualDetailsStatus.initial;
        final errorMessage =
            state.detailsStatus == ExpectedVsActualDetailsStatus.failure
            ? state.detailsErrorMessage
            : null;

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 600
                  ? 16.0
                  : 24.0;

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
                          _DetailsTitle(onBack: widget.onBack),
                          const SizedBox(height: 16),
                          ExpectedVsActualInvestorsSection(
                            monthLabel: MonthRangePicker.formatMonth(
                              widget.month,
                            ),
                            isLoading: isLoading,
                            errorMessage: errorMessage,
                            onRetry: _load,
                            details: state.details,
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

class _DetailsTitle extends StatelessWidget {
  const _DetailsTitle({required this.onBack});

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
              'Month Details',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Investors expected and collected in this month',
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
                    'Back to Expected vs Actual',
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
            children: [titleBlock, const SizedBox(height: 12), backButton],
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
