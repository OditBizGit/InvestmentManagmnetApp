import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/monthly_payment_list/screen/widgets/montly_payment_table.dart';
import 'package:sizer/sizer.dart';

class _Calls {
  final List<String> log = [];
}

List<MonthlyPayment> _payments() => [
      MonthlyPayment(
        id: 1,
        investorName: 'Jane Doe',
        investorCode: 'INV-1',
        contact: '9999',
        staff: 'Asha',
        method: 'Cash',
        amount: 1000,
        paidOn: DateTime(2026, 11, 3),
      ),
      MonthlyPayment(
        id: 2,
        investorName: 'John Roe',
        investorCode: 'INV-2',
        contact: '8888',
        staff: 'Ravi',
        method: 'UPI',
        amount: 2500,
        paidOn: DateTime(2026, 11, 4),
        status: PaymentStatus.approved,
      ),
      MonthlyPayment(
        id: 3,
        investorName: 'Mary Major',
        investorCode: 'INV-3',
        contact: '7777',
        staff: 'Asha',
        method: 'Cash',
        amount: 500,
        paidOn: DateTime(2026, 11, 5),
        status: PaymentStatus.rejected,
      ),
    ];

Future<void> _pumpTable(
  WidgetTester tester, {
  required bool readOnly,
  required _Calls calls,
  double width = 1400,
  Map<int, PaymentReviewIntent> intents = const {},
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1400);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final searchController = TextEditingController();
  addTearDown(searchController.dispose);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MonthlyPaymentTable(
              readOnly: readOnly,
              payments: _payments(),
              reviewIntents: intents,
              searchController: searchController,
              fromDate: DateTime(2026, 11, 1),
              toDate: DateTime(2026, 11, 25),
              onSearchChanged: (_) {},
              onClearSearch: () {},
              onFromDateChanged: (_) {},
              onToDateChanged: (_) {},
              onApproveIntentChanged: (id, s) =>
                  calls.log.add('approveIntent $id $s'),
              onRejectIntentChanged: (id, s) =>
                  calls.log.add('rejectIntent $id $s'),
              onSelectAllApproveChanged: (s) => calls.log.add('selectAll $s'),
              onApproveAll: () => calls.log.add('approveAll'),
              onSaveRow: (id) => calls.log.add('save $id'),
              onViewHistory: () => calls.log.add('history'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('MonthlyPaymentTable readOnly: true (W1)', () {
    testWidgets('hides every modify control and keeps read controls',
        (tester) async {
      final calls = _Calls();
      await _pumpTable(
        tester,
        readOnly: true,
        calls: calls,
        // Even a stale intent must not surface a Save button.
        intents: const {1: PaymentReviewIntent.approve},
      );

      expect(find.byType(Checkbox), findsNothing);
      expect(find.text('Approve All'), findsNothing);
      expect(find.byTooltip('Approve'), findsNothing);
      expect(find.byTooltip('Reject'), findsNothing);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Actions'), findsNothing);

      expect(find.text('View history'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);

      expect(calls.log, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('View history still fires', (tester) async {
      final calls = _Calls();
      await _pumpTable(tester, readOnly: true, calls: calls);

      await tester.tap(find.text('View history'));
      await tester.pump();

      expect(calls.log, ['history']);
    });
  });

  group('MonthlyPaymentTable readOnly: false (W2 regression)', () {
    testWidgets('shows checkboxes, row actions and Approve All',
        (tester) async {
      final calls = _Calls();
      await _pumpTable(
        tester,
        readOnly: false,
        calls: calls,
        intents: const {1: PaymentReviewIntent.approve},
      );

      // Header select-all + one per row.
      expect(find.byType(Checkbox), findsNWidgets(4));
      expect(find.text('Approve All'), findsOneWidget);
      expect(find.byTooltip('Approve'), findsOneWidget);
      expect(find.byTooltip('Reject'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('View history'), findsOneWidget);

      await tester.tap(find.text('Approve All'));
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(calls.log, ['approveAll', 'save 1']);
      expect(tester.takeException(), isNull);
    });
  });

  group('MonthlyPaymentTable readOnly: true layout (W3)', () {
    for (final width in [800.0, 1400.0]) {
      testWidgets('no overflow at width $width', (tester) async {
        final calls = _Calls();
        await _pumpTable(tester, readOnly: true, calls: calls, width: width);

        expect(tester.takeException(), isNull);
        expect(find.text('Jane Doe'), findsOneWidget);
        expect(find.text('Status'), findsOneWidget);
      });
    }

    testWidgets('header and row cells stay aligned', (tester) async {
      final calls = _Calls();
      await _pumpTable(tester, readOnly: true, calls: calls, width: 1400);

      final headerX = tester.getTopLeft(find.text('#ID')).dx;
      final rowX = tester.getTopLeft(find.text('1').first).dx;
      // The body container draws a 1px border, so rows start 1px right of
      // the header.
      expect(rowX - headerX, closeTo(1, 0.01));

      final headerStatusX = tester.getTopLeft(find.text('Status')).dx;
      final badgeX = tester.getTopLeft(find.text('Pending')).dx;
      // Badge sits inside the 88px status column, never left of its header.
      expect(badgeX, greaterThanOrEqualTo(headerStatusX));
      expect(badgeX - headerStatusX, lessThan(88));
    });
  });
}
