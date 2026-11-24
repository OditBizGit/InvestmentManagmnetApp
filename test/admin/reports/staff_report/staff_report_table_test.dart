import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/cubit/staff_report_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/repository/staff_report_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_report_row_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

/// Never called: the table is fed through `items`, the cubit is only needed
/// so the section's BlocBuilder has a provider.
class _FakeStaffReportRepository extends StaffReportRepository {
  _FakeStaffReportRepository() : super(Dio());
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => StaffReportCubit(_FakeStaffReportRepository()),
            child: SingleChildScrollView(
              child: StaffReportTableSection(
                items: const [
                  StaffReportRowModel(
                    staffId: 1,
                    code: 'S001',
                    name: 'Asha',
                    mobileNumber: '9999',
                    totalAmount: 700,
                  ),
                ],
                onViewStaff: (staff, period, {customFromDate, customToDate}) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('list shows original columns and hides the new ones', (
    tester,
  ) async {
    await _pump(tester, const Size(1400, 900));

    expect(find.text('Staff Code'), findsOneWidget);
    expect(find.text('Staff Name'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Total Amount (This Month)'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);

    expect(find.text('Received (gross)'), findsNothing);
    expect(find.text('Allocated'), findsNothing);
    expect(find.text('Refunds'), findsNothing);
    expect(find.text('Investors'), findsNothing);

    expect(find.text(CurrencyFormatter.format(700)), findsOneWidget);
  });

  testWidgets('list stays usable on a narrow width (scrolls horizontally)', (
    tester,
  ) async {
    await _pump(tester, const Size(500, 900));

    expect(tester.takeException(), isNull);
    expect(find.text('Received (gross)'), findsNothing);
    expect(find.text(CurrencyFormatter.format(700)), findsOneWidget);
  });
}
