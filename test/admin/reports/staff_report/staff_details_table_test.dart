import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/model/staff_investor_amount_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_details_investors_section.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

Future<void> _pump(
  WidgetTester tester,
  List<StaffInvestorAmountModel> items,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1500, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StaffDetailsInvestorsSection(
              period: StaffReportPeriod.thisMonth,
              isLoading: false,
              errorMessage: null,
              onRetry: () {},
              items: items,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('details rows show original columns and no new ones', (
    tester,
  ) async {
    await _pump(tester, const [
      StaffInvestorAmountModel(
        investorCode: 'INV01',
        investorName: 'Ravi',
        amountReceived: 540,
        refundAmount: 60,
      ),
    ]);

    expect(find.text('Investor Code'), findsOneWidget);
    expect(find.text('Investor Name'), findsOneWidget);
    expect(find.text('Amount Received'), findsOneWidget);
    expect(find.text('Refund Amnt'), findsOneWidget);
    expect(find.text('Amount Received Date'), findsOneWidget);

    expect(find.text('Allocation %'), findsNothing);
    expect(find.text('Allocated'), findsNothing);
    expect(find.text('Net'), findsNothing);

    expect(find.text(CurrencyFormatter.format(540)), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(60)), findsOneWidget);
  });
}
