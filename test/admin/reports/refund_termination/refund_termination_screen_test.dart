import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/refund_termination_screen.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:toastification/toastification.dart';

import 'refund_termination_fakes.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Closes any toast and lets its auto-close timer run out.
Future<void> _flushToasts(WidgetTester tester) async {
  toastification.dismissAll(delayForAnimation: false);
  await tester.pump(const Duration(seconds: 4));
}

Future<void> _pump(WidgetTester tester, FakeAdapter adapter) async {
  useWideView(tester);
  await registerDeps(adapter);
  addTearDown(() => toastification.dismissAll(delayForAnimation: false));
  await tester.pumpWidget(
    sizerApp(const RefundTerminationScreen(isActive: true)),
  );
  await _settle(tester);
}

final _refunds = [
  refundRow(code: 'INV001', name: 'Asha Rao', amount: 2500),
  refundRow(code: 'INV002', name: 'Bala Kumar', amount: 4500),
];
final _terminated = [
  terminatedRow(code: 'INV010', name: 'Chitra Devi'),
  terminatedRow(code: 'INV011', name: 'Dev Anand', dateSource: 'ModifiedDate'),
];

Map<String, dynamic> _full() =>
    refundEnvelope(refunds: _refunds, terminated: _terminated);

void main() {
  testWidgets('shows a loading indicator while fetching', (tester) async {
    final adapter = FakeAdapter((_) => jsonBody(_full()))
      ..gate = Completer<void>();
    await _pump(tester, adapter);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    adapter.gate!.complete();
    await _settle(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows stat cards and both tables', (tester) async {
    final adapter = FakeAdapter((_) => jsonBody(_full()));
    await _pump(tester, adapter);

    expect(find.text('Refunds'), findsOneWidget);
    expect(find.text('Refunded Amount'), findsOneWidget);
    expect(find.text('Terminated'), findsOneWidget);
    expect(find.text('Remaining Refundable'), findsWidgets);
    expect(find.text(CurrencyFormatter.format(7000)), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(5500)), findsOneWidget);

    for (final header in [
      'Date',
      'Amount',
      'Method',
      'Remarks',
      'Terminated On',
      'Paid',
      'Refunded',
      'Pending Requests',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }

    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsNWidgets(2));
    expect(find.text(CurrencyFormatter.format(2500)), findsOneWidget);
    expect(find.text('Chitra Devi'), findsOneWidget);
    expect(find.text('05 Nov 2026'), findsOneWidget);
    expect(find.text('05 Nov 2026 (approx.)'), findsOneWidget);

    expect(adapter.requests, hasLength(1));
    final now = DateTime.now();
    expect(
      adapter.requests.single.queryParameters['fromDate'],
      '${now.year}-${now.month.toString().padLeft(2, '0')}-01',
    );
    expect(
      adapter.requests.single.queryParameters['toDate'],
      '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}',
    );
  });

  testWidgets('empty lists show "No records found" in both tables', (
    tester,
  ) async {
    await _pump(tester, FakeAdapter((_) => jsonBody(refundEnvelope())));

    expect(find.text('No records found'), findsNWidgets(2));
  });

  testWidgets('error shows the server message and Retry refetches', (
    tester,
  ) async {
    var fail = true;
    final adapter = FakeAdapter((_) {
      if (fail) {
        return jsonBody({'title': 'Invalid date range'}, status: 400);
      }
      return jsonBody(_full());
    });
    await _pump(tester, adapter);

    expect(find.text('Invalid date range'), findsWidgets);
    expect(find.textContaining('DioException'), findsNothing);

    fail = false;
    await tester.tap(find.text('Retry'));
    await _settle(tester);

    expect(adapter.requests, hasLength(2));
    expect(find.text('Asha Rao'), findsOneWidget);
    await _flushToasts(tester);
  });

  testWidgets('search filters both tables', (tester) async {
    await _pump(tester, FakeAdapter((_) => jsonBody(_full())));

    await tester.enterText(find.byType(TextField), 'bala');
    await tester.pump();
    expect(find.text('Bala Kumar'), findsOneWidget);
    expect(find.text('Asha Rao'), findsNothing);
    expect(find.text('Chitra Devi'), findsNothing);

    await tester.enterText(find.byType(TextField), 'inv011');
    await tester.pump();
    expect(find.text('Dev Anand'), findsOneWidget);
    expect(find.text('Chitra Devi'), findsNothing);
    expect(find.text('Asha Rao'), findsNothing);
  });

  testWidgets('period menu refetches with last month dates', (tester) async {
    final adapter = FakeAdapter((_) => jsonBody(_full()));
    await _pump(tester, adapter);

    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last Month').last);
    await _settle(tester);

    expect(adapter.requests, hasLength(2));
    final now = DateTime.now();
    final first = DateTime(now.year, now.month - 1, 1);
    final last = DateTime(now.year, now.month, 0);
    String iso(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    expect(adapter.requests.last.queryParameters['fromDate'], iso(first));
    expect(adapter.requests.last.queryParameters['toDate'], iso(last));
  });

  testWidgets('does not fetch while inactive; re-activation resets and '
      'refetches', (tester) async {
    final adapter = FakeAdapter((_) => jsonBody(_full()));
    final active = ValueNotifier<bool>(false);
    useWideView(tester);
    await registerDeps(adapter);
    addTearDown(() => toastification.dismissAll(delayForAnimation: false));

    await tester.pumpWidget(
      sizerApp(
        ValueListenableBuilder<bool>(
          valueListenable: active,
          builder: (_, value, _) => RefundTerminationScreen(isActive: value),
        ),
      ),
    );
    await _settle(tester);
    expect(adapter.requests, isEmpty);

    active.value = true;
    await _settle(tester);
    expect(adapter.requests, hasLength(1));

    await tester.enterText(find.byType(TextField), 'bala');
    await tester.pump();
    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last Month').last);
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(2));

    active.value = false;
    await _settle(tester);
    active.value = true;
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(3));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('This Month'), findsOneWidget);
    final now = DateTime.now();
    expect(
      adapter.requests.last.queryParameters['fromDate'],
      '${now.year}-${now.month.toString().padLeft(2, '0')}-01',
    );
    expect(find.text('Asha Rao'), findsOneWidget);
  });

  testWidgets('Custom period applies the chosen range and refetches', (
    tester,
  ) async {
    final adapter = FakeAdapter((_) => jsonBody(_full()));
    await _pump(tester, adapter);

    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom').last);
    await tester.pumpAndSettle();
    expect(find.text('Custom date range'), findsOneWidget);
    // The existing Staff Report dialog's date chips overflow by a few pixels
    // with the test font; that layout error is not part of this screen.
    tester.takeException();

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(const Duration(days: 30));
    String iso(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests.last.queryParameters['fromDate'], iso(from));
    expect(adapter.requests.last.queryParameters['toDate'], iso(today));
    expect(find.text('${iso(from)} - ${iso(today)}'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });
}
