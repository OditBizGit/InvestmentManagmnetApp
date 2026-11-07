
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_report_row_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/repository/staff_report_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/staff_details_screen.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';

import '../../../core/network/service_locator.dart';
import 'cubit/staff_report_cubit.dart';

class StaffReportScreen extends StatefulWidget {
  const StaffReportScreen({
    super.key,
    this.isActive = false,
  });

  // When true, this tab is visible in the admin IndexedStack.
  final bool isActive;

  @override
  State<StaffReportScreen> createState() => _StaffReportScreenState();
}

class _StaffReportScreenState extends State<StaffReportScreen> {
  late final StaffReportCubit _cubit;

  StaffReportRowModel? _selectedStaff;

  StaffReportPeriod _period = StaffReportPeriod.thisMonth;
  DateTime? _customFromDate;
  DateTime? _customToDate;

  @override
  void initState() {
    super.initState();
    _cubit = StaffReportCubit(
      StaffReportRepository(getIt<Dio>()),
    )..fetchStaffReport(period: 'ThisMonth');
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StaffReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isActive &&
        oldWidget.isActive &&
        _selectedStaff != null) {
      _selectedStaff = null;
      _cubit.resetDetails();
    }
  }

  void _openStaff(
    StaffReportRowModel staff,
    StaffReportPeriod period, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();

    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;

        setState(() {
          _selectedStaff = staff;
          _period = period;
          _customFromDate = customFromDate;
          _customToDate = customToDate;
        });
      });
    });
  }

  void _backToList() {
    FocusManager.instance.primaryFocus?.unfocus();

    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;

        setState(() {
          _selectedStaff = null;
        });
        _cubit.resetDetails();
      });
    });
  }

  void _onDetailsPeriodChanged(
    StaffReportPeriod period, {
    DateTime? customFromDate,
    DateTime? customToDate,
    bool clearCustomDates = false,
  }) {
    setState(() {
      _period = period;
      if (clearCustomDates) {
        _customFromDate = null;
        _customToDate = null;
      } else {
        _customFromDate = customFromDate;
        _customToDate = customToDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedStaff;

    return BlocProvider.value(
      value: _cubit,
      child: selected != null
          ? StaffDetailsScreen(
              staff: selected,
              period: _period,
              customFromDate: _customFromDate,
              customToDate: _customToDate,
              onBack: _backToList,
              onPeriodChanged: _onDetailsPeriodChanged,
            )
          : _StaffReportContent(onViewStaff: _openStaff),
    );
  }
}

class _StaffReportContent extends StatelessWidget {
  const _StaffReportContent({required this.onViewStaff});

  final void Function(
    StaffReportRowModel staff,
    StaffReportPeriod period, {
    DateTime? customFromDate,
    DateTime? customToDate,
  }) onViewStaff;

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
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const UserManagementSectionHeader(
                        title: 'Staff Report',
                        subtitle: 'List of all staff',
                      ),
                      const SizedBox(height: 18),
                      StaffReportTableSection(
                        onViewStaff: onViewStaff,
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
