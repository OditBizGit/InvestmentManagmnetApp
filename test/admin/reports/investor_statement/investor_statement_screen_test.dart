import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/investor_statement/investor_statement_screen.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

import '../../../core/fakes.dart';
import 'investor_statement_fakes.dart';

late FakeAdapter adapter;

Future<ResponseBody> _ok(RequestOptions o) async => jsonBody(
  o.path.endsWith('GetInvestors') ? investorsEnvelope() : statementEnvelope(),
);

Future<void> _pump(
  WidgetTester tester, {
  bool isActive = true,
  Size size = const Size(1500, 1000),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ToastificationWrapper(
      child: Sizer(
        builder: (context, orientation, screenType) => MaterialApp(
          home: Scaffold(body: InvestorStatementScreen(isActive: isActive)),
        ),
      ),
    ),
  );
}

Future<void> _pickAsha(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'asha');
  await tester.pumpAndSettle();
  await tester.tap(find.text('INV007 - Asha Rao'));
  await tester.pumpAndSettle();
}

bool _exportEnabled(WidgetTester tester) {
  final button = tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Export PDF'),
  );
  return button.onPressed != null;
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

  testWidgets('asks to select an investor first; export disabled', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Select an investor to view the statement'),
      findsOneWidget,
    );
    expect(adapter.investorRequests, hasLength(1));
    expect(adapter.statementRequests, isEmpty);
    expect(_exportEnabled(tester), isFalse);
  });

  testWidgets('does not fetch while inactive', (tester) async {
    await _pump(tester, isActive: false);
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
  });

  testWidgets('spinner while the statement loads (TC30)', (tester) async {
    final pending = Completer<ResponseBody>();
    adapter.onRequest = (o) => o.path.endsWith('GetInvestors')
        ? Future.value(jsonBody(investorsEnvelope()))
        : pending.future;

    await _pump(tester);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'asha');
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV007 - Asha Rao'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(jsonBody(statementEnvelope()));
    await tester.pumpAndSettle();
  });

  testWidgets('pick an investor: cards, header, tables, export (TC15)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    await _pickAsha(tester);

    expect(
      adapter.statementRequests.single.path,
      '/api/Report/InvestorStatement/7',
    );
    expect(adapter.statementRequests.single.queryParameters, isEmpty);

    for (final label in ['Commitment', 'Net Paid', 'Discount', 'Pending']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('Opening balance'), findsOneWidget);
    expect(find.text('Closing balance'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(120000)), findsWidgets);
    expect(find.text(CurrencyFormatter.format(69999.5)), findsWidgets);
    expect(find.text(CurrencyFormatter.format(69000)), findsWidgets);

    for (final header in [
      'Date',
      'Type',
      'Reference',
      'Description',
      'Method',
      'Charge',
      'Payment',
      'Balance',
      'No',
      'Due Date',
      'Amount',
      'Paid',
      'Days Overdue',
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text('PAY-9'), findsOneWidget);
    expect(find.text('Partially Completed'), findsOneWidget);
    expect(find.text('Select an investor to view the statement'), findsNothing);
    expect(_exportEnabled(tester), isTrue);
  });

  testWidgets('empty ledger and schedule say No records found (TC29)', (
    tester,
  ) async {
    adapter.onRequest = (o) async => jsonBody(
      o.path.endsWith('GetInvestors')
          ? investorsEnvelope()
          : statementEnvelope(ledger: [], schedule: []),
    );
    await _pump(tester);
    await tester.pumpAndSettle();

    await _pickAsha(tester);

    expect(find.text('No records found'), findsNWidgets(2));
  });

  testWidgets('error shows message, Retry refetches (TC21)', (tester) async {
    adapter.onRequest = (o) async => o.path.endsWith('GetInvestors')
        ? jsonBody(investorsEnvelope())
        : jsonBody({
            'success': false,
            'message': 'Investor not found',
          }, status: 404);
    await _pump(tester);
    await tester.pumpAndSettle();

    await _pickAsha(tester);

    expect(find.text('Investor not found'), findsWidgets);
    expect(find.textContaining('DioException'), findsNothing);
    expect(_exportEnabled(tester), isFalse);

    adapter.onRequest = _ok;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(adapter.statementRequests, hasLength(2));
    expect(find.text('PAY-9'), findsOneWidget);
    expect(_exportEnabled(tester), isTrue);
    await _drainToasts(tester);
  });

  testWidgets('picking a From date refetches with fromDate (TC16)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    await _pickAsha(tester);

    await tester.tap(find.text('Any').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final today = DateTime.now();
    final expected =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    expect(adapter.statementRequests, hasLength(2));
    expect(adapter.statementRequests.last.queryParameters, {
      'fromDate': expected,
    });
  });

  testWidgets('re-activation resets the selected investor (TC22)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    await _pickAsha(tester);
    expect(find.text('PAY-9'), findsOneWidget);

    await _pump(tester, isActive: false);
    await tester.pumpAndSettle();
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Select an investor to view the statement'),
      findsOneWidget,
    );
    expect(find.text('PAY-9'), findsNothing);
    expect(adapter.investorRequests, hasLength(2));
    expect(_exportEnabled(tester), isFalse);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('deleting the investor text clears selection and statement', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    await _pickAsha(tester);
    expect(find.text('PAY-9'), findsOneWidget);
    expect(_exportEnabled(tester), isTrue);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('PAY-9'), findsNothing);
    expect(
      find.text('Select an investor to view the statement'),
      findsOneWidget,
    );
    expect(_exportEnabled(tester), isFalse);
  });

  testWidgets('narrow layout does not overflow', (tester) async {
    await _pump(tester, size: const Size(500, 900));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('Select an investor to view the statement'),
      findsOneWidget,
    );
  });
}
