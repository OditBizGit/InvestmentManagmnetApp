import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/staff_details_screen.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';

import 'model/staff_report_row_model.dart';

class StaffReportScreen extends StatefulWidget {
  const StaffReportScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  State<StaffReportScreen> createState() => _StaffReportScreenState();
}

class _StaffReportScreenState extends State<StaffReportScreen> {
  static const _sampleItems = <StaffReportRowModel>[
    StaffReportRowModel(
      code: 'SM-001',
      name: 'Rashid K',
      mobileNumber: '+91 98456 12345',
      totalAmount: 840000,
    ),
    StaffReportRowModel(
      code: 'SM-002',
      name: 'Anitha R',
      mobileNumber: '+91 98765 43210',
      totalAmount: 615000,
    ),
    StaffReportRowModel(
      code: 'SM-003',
      name: 'Faizal M',
      mobileNumber: '+91 99001 11223',
      totalAmount: 490000,
    ),
  ];

  StaffReportRowModel? _selectedStaff;
  StaffReportPeriod _period = StaffReportPeriod.thisMonth;

  @override
  void didUpdateWidget(covariant StaffReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive && _selectedStaff != null) {
      _selectedStaff = null;
    }
  }

  void _openStaff(StaffReportRowModel staff, StaffReportPeriod period) {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        setState(() {
          _selectedStaff = staff;
          _period = period;
        });
      });
    });
  }

  void _backToList() {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        setState(() => _selectedStaff = null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedStaff;
    if (selected != null) {
      return StaffDetailsScreen(
        staff: selected,
        period: _period,
        onBack: _backToList,
        onPeriodChanged: (period) {
          setState(() => _period = period);
        },
      );
    }

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
                      const UserManagementSectionHeader(
                        title: 'Staff Report',
                        subtitle: 'List of all staff',
                      ),
                      const SizedBox(height: 18),
                      StaffReportTableSection(
                        items: _sampleItems,
                        onViewStaff: _openStaff,
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
