
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
import 'package:maribel_wellness_centre_application/core/utils/admin_main_screen_layout.dart';

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

  /// Bumped when the tab becomes active so the list table remounts with
  /// default period/search in sync with the refresh fetch.
  int _listResetKey = 0;

  @override
  void initState() {
    super.initState();
    _cubit = StaffReportCubit(
      StaffReportRepository(getIt<Dio>()),
    );
    _refreshIfActive();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StaffReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Leaving Staff Report (IndexedStack) must drop the detail screen so
    // returning always lands on the list until a staff is selected again.
    if (!widget.isActive &&
        oldWidget.isActive &&
        _selectedStaff != null) {
      _selectedStaff = null;
      _cubit.resetDetails();
    }

    // IndexedStack keeps this screen alive — refresh whenever Staff Report
    // is opened again.
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _listResetKey++;
        _period = StaffReportPeriod.thisMonth;
        _customFromDate = null;
        _customToDate = null;
      });
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      if (_selectedStaff != null) return;
      _cubit.fetchStaffReport(period: 'ThisMonth');
    });
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
          : _StaffReportContent(
              listResetKey: _listResetKey,
              onViewStaff: _openStaff,
            ),
    );
  }
}

class _StaffReportContent extends StatelessWidget {
  const _StaffReportContent({
    required this.listResetKey,
    required this.onViewStaff,
  });

  final int listResetKey;

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

          return BlocBuilder<StaffReportCubit, StaffReportState>(
            buildWhen: (previous, current) =>
                previous.listStatus != current.listStatus ||
                previous.staffList != current.staffList,
            builder: (context, state) {
              final showRefetchProgress =
                  state.listStatus == StaffReportListStatus.loading &&
                      state.staffList.isNotEmpty;

              return AdminMainScreenLayout(
                horizontalPadding: horizontalPadding,
                showRefetchProgress: showRefetchProgress,
                body: SingleChildScrollView(
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
                        key: ValueKey(listResetKey),
                        onViewStaff: onViewStaff,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
