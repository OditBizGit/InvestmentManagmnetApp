import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/expected_vs_actual/expected_vs_actual_screen.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/month_range_picker.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

import '../../../core/fakes.dart';
import 'expected_vs_actual_fakes.dart';

const _monthNames = [
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

late FakeAdapter adapter;

int _reportCalls() =>
    adapter.requests.where((r) => r.path.endsWith('ExpectedVsActual')).length;

Future<ResponseBody> _ok(RequestOptions o) async =>
    jsonBody(o.path.endsWith('Details') ? detailsEnvelope() : reportEnvelope());

Future<void> _pump(
  WidgetTester tester, {
  bool isActive = true,
  Size size = const Size(1400, 900),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ToastificationWrapper(
      child: Sizer(
        builder: (context, orientation, screenType) => MaterialApp(
          home: Scaffold(body: ExpectedVsActualScreen(isActive: isActive)),
        ),
      ),
    ),
  );
}

/// Lets the error toast auto-close so no timer is left pending.
Future<void> _drainToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.init(secureStorage: FakeSecureStorage());
    await getIt.reset();
    getIt.registerSingleton<LocalStorage>(storage);
  });

  setUp(() {
    adapter = FakeAdapter(_ok);
    if (getIt.isRegistered<Dio>()) getIt.unregister<Dio>();
    getIt.registerSingleton<Dio>(dioWith(adapter));
  });

  testWidgets('shows a spinner while loading (TC30)', (tester) async {
    final pending = Completer<ResponseBody>();
    adapter.onRequest = (_) => pending.future;

    await _pump(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Expected vs Actual'), findsOneWidget);
    pending.complete(jsonBody(reportEnvelope()));
    await tester.pumpAndSettle();
  });

  testWidgets('default last 6 months, cards and table (TC09)', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    final range = defaultMonthRange();
    String param(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-01';
    expect(adapter.requests.single.queryParameters, {
      'fromDate': param(range.from),
      'toDate': param(range.to),
    });

    for (final label in ['Expected', 'Actual', 'Refunds', 'Collection Rate']) {
      expect(find.text(label), findsWidgets);
    }
    for (final header in [
      'Month',
      'Installments',
      'Payments',
      'Rate %',
      'View',
    ]) {
      expect(find.text(header), findsWidgets);
    }
    expect(find.text('Mar 2024'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(1000)), findsWidgets);
    expect(find.text('70.0%'), findsWidgets);
  });

  testWidgets('empty report says No records found (TC29)', (tester) async {
    adapter.onRequest = (_) async => jsonBody(reportEnvelope(months: []));

    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('No records found'), findsOneWidget);
  });

  testWidgets('null rate renders an em dash (TC11)', (tester) async {
    adapter.onRequest = (_) async =>
        jsonBody(reportEnvelope(months: [monthJson(expected: 0, rate: null)]));

    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('—'), findsWidgets);
    expect(find.text('0.0%'), findsNothing);
  });

  testWidgets('error shows server message and Retry refetches (TC21)', (
    tester,
  ) async {
    adapter.onRequest = (_) async =>
        jsonBody({'success': false, 'message': 'Server is down'}, status: 500);

    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Server is down'), findsWidgets);
    expect(find.textContaining('DioException'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);

    adapter.onRequest = _ok;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(_reportCalls(), 2);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Mar 2024'), findsOneWidget);
    await _drainToasts(tester);
  });

  testWidgets('View drills into a month and Back keeps the list (TC12)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Month Details'), findsOneWidget);
    expect(find.text('INV007'), findsOneWidget);
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(adapter.requests.last.queryParameters, {'month': '2024-03-01'});

    await tester.tap(find.text('Back to Expected vs Actual'));
    await tester.pumpAndSettle();

    expect(find.text('Month Details'), findsNothing);
    expect(find.text('Mar 2024'), findsOneWidget);
    expect(_reportCalls(), 1, reason: 'Back must not refetch the list');
  });

  testWidgets('changing the range refetches; re-activation resets (TC22)', (
    tester,
  ) async {
    await _pump(tester, isActive: false);
    await tester.pump();
    expect(adapter.requests, isEmpty, reason: 'no fetch while inactive');

    await _pump(tester);
    await tester.pumpAndSettle();
    expect(_reportCalls(), 1);

    final range = defaultMonthRange();
    final targetMonth = range.from.month > 1
        ? range.from.month - 1
        : range.from.month + 1;
    await tester.tap(
      find.widgetWithText(InkWell, MonthRangePicker.formatMonth(range.from)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(_monthNames[targetMonth - 1]));
    await tester.pumpAndSettle();

    expect(_reportCalls(), 2);
    final changed = adapter.requests.last.queryParameters['fromDate'];
    expect(
      changed,
      '${range.from.year}-'
      '${targetMonth.toString().padLeft(2, '0')}-01',
    );

    // Open a month, leave the tab and come back.
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Month Details'), findsOneWidget);

    await _pump(tester, isActive: false);
    await tester.pumpAndSettle();
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Month Details'), findsNothing);
    expect(_reportCalls(), 3);
    final reset = adapter.requests.last.queryParameters['fromDate'];
    expect(
      reset,
      '${range.from.year}-${range.from.month.toString().padLeft(2, '0')}-01',
    );
  });

  testWidgets('narrow layout does not overflow', (tester) async {
    await _pump(tester, size: const Size(500, 900));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Mar 2024'), findsOneWidget);
  });
}
