import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/collection_aging_screen.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/repository/collection_aging_repository.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:toastification/toastification.dart';

import 'collection_aging_fakes.dart';

const _footnote =
    'Some outstanding amounts (unpaid advance) are not in a due bucket.';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Closes any toast and lets its auto-close timer run out.
Future<void> _flushToasts(WidgetTester tester) async {
  toastification.dismissAll(delayForAnimation: false);
  await tester.pump(const Duration(seconds: 4));
}

Future<void> _pump(
  WidgetTester tester,
  FakeAdapter adapter, {
  bool isActive = true,
}) async {
  useWideView(tester);
  await registerDeps(adapter);
  addTearDown(() => toastification.dismissAll(delayForAnimation: false));
  await tester.pumpWidget(sizerApp(CollectionAgingScreen(isActive: isActive)));
  await _settle(tester);
}

String _asOfLabel(DateTime d) {
  const months = [
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
  return 'As of ${d.day.toString().padLeft(2, '0')} '
      '${months[d.month - 1]} ${d.year}';
}

final _rows = [
  agingRow(code: 'INV001', name: 'Asha Rao', phone: '9111111111'),
  agingRow(
    code: 'INV002',
    name: 'Bala Kumar',
    phone: '9222222222',
    isActive: false,
    outstanding: 1500,
  ),
];

void main() {
  testWidgets('shows a loading indicator while fetching', (tester) async {
    final adapter = FakeAdapter((_) => jsonBody(agingEnvelope()))
      ..gate = Completer<void>();
    await _pump(tester, adapter);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    adapter.gate!.complete();
    await _settle(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows stat cards, rows and requests today as of date', (
    tester,
  ) async {
    final adapter = FakeAdapter((_) => jsonBody(agingEnvelope(rows: _rows)));
    await _pump(tester, adapter);

    expect(find.text('Total Overdue'), findsOneWidget);
    expect(find.text('1–30 days'), findsOneWidget);
    expect(find.text('90+ days'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(10000)), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(4000)), findsOneWidget);

    for (final header in [
      'Code',
      'Name',
      'Status',
      'Outstanding',
      'Not yet due',
      'Oldest due',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('INV001'), findsOneWidget);
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('01 Nov 2026'), findsNWidgets(2));

    final now = DateTime.now();
    expect(adapter.requests, hasLength(1));
    expect(now, isNotNull);
    expect(
      adapter.requests.single.queryParameters.containsKey('asOfDate'),
      isFalse,
    );
  });

  testWidgets('empty list shows "No records found"', (tester) async {
    await _pump(tester, FakeAdapter((_) => jsonBody(agingEnvelope())));

    expect(find.text('No records found'), findsOneWidget);
  });

  testWidgets('error shows the server message, Retry refetches', (
    tester,
  ) async {
    var fail = true;
    final adapter = FakeAdapter((_) {
      if (fail) {
        return jsonBody({
          'success': false,
          'message': 'Server says no.',
        }, status: 400);
      }
      return jsonBody(agingEnvelope(rows: _rows));
    });
    await _pump(tester, adapter);

    expect(find.text('Server says no.'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('DioException'), findsNothing);

    fail = false;
    await tester.tap(find.text('Retry'));
    await _settle(tester);

    expect(adapter.requests, hasLength(2));
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    await _flushToasts(tester);
  });

  testWidgets('search filters by name, code and phone', (tester) async {
    await _pump(
      tester,
      FakeAdapter((_) => jsonBody(agingEnvelope(rows: _rows))),
    );

    Future<void> search(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    await search('bala');
    expect(find.text('Bala Kumar'), findsOneWidget);
    expect(find.text('Asha Rao'), findsNothing);

    await search('inv001');
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Bala Kumar'), findsNothing);

    await search('9222');
    expect(find.text('Bala Kumar'), findsOneWidget);
    expect(find.text('Asha Rao'), findsNothing);

    await search('zzz');
    expect(find.text('No records found'), findsOneWidget);
  });

  testWidgets('no footnote when every row is fully bucketed', (tester) async {
    await _pump(
      tester,
      FakeAdapter(
        (_) => jsonBody(
          agingEnvelope(
            rows: [agingRow(code: 'A', name: 'Covered', outstanding: 1000)],
          ),
        ),
      ),
    );
    expect(find.text('Covered'), findsOneWidget);
    expect(find.text(_footnote), findsNothing);
  });

  testWidgets('footnote shows when a bucket sum is below outstanding', (
    tester,
  ) async {
    await _pump(
      tester,
      FakeAdapter(
        (_) => jsonBody(
          agingEnvelope(
            rows: [agingRow(code: 'B', name: 'Advance', outstanding: 1500)],
          ),
        ),
      ),
    );
    expect(find.text(_footnote), findsOneWidget);
  });

  testWidgets('as-of picker cannot pick a future date and refetches', (
    tester,
  ) async {
    final adapter = FakeAdapter((_) => jsonBody(agingEnvelope(rows: _rows)));
    await _pump(tester, adapter);

    await tester.tap(find.textContaining('As of '));
    await tester.pumpAndSettle();

    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final now = DateTime.now();
    expect(picker.lastDate, DateTime(now.year, now.month, now.day));
    expect(picker.initialDate, DateTime(now.year, now.month, now.day));

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(2));
  });

  testWidgets('does not fetch while inactive; re-activation resets and '
      'refetches', (tester) async {
    final adapter = FakeAdapter((_) => jsonBody(agingEnvelope(rows: _rows)));
    final active = ValueNotifier<bool>(false);
    useWideView(tester);
    await registerDeps(adapter);
    addTearDown(() => toastification.dismissAll(delayForAnimation: false));

    await tester.pumpWidget(
      sizerApp(
        ValueListenableBuilder<bool>(
          valueListenable: active,
          builder: (_, value, _) => CollectionAgingScreen(isActive: value),
        ),
      ),
    );
    await _settle(tester);
    expect(adapter.requests, isEmpty);

    active.value = true;
    await _settle(tester);
    expect(adapter.requests, hasLength(1));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(find.text(_asOfLabel(today)), findsOneWidget);

    // Pick day 1 of this month (no-op when today is the 1st).
    await tester.tap(find.textContaining('As of '));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(CalendarDatePicker),
        matching: find.text('1'),
      ),
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final first = DateTime(today.year, today.month, 1);
    expect(find.text(_asOfLabel(first)), findsOneWidget);
    expect(
      adapter.requests.last.queryParameters['asOfDate'],
      CollectionAgingRepository.formatDate(first),
    );
    final afterPick = adapter.requests.length;

    await tester.enterText(find.byType(TextField), 'bala');
    await tester.pump();
    expect(find.text('Asha Rao'), findsNothing);

    active.value = false;
    await _settle(tester);
    expect(adapter.requests, hasLength(afterPick));

    active.value = true;
    await _settle(tester);
    expect(adapter.requests, hasLength(afterPick + 1));
    expect(find.text(_asOfLabel(today)), findsOneWidget);
    expect(
      adapter.requests.last.queryParameters.containsKey('asOfDate'),
      isFalse,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('Asha Rao'), findsOneWidget);
  });

  testWidgets('toasts once per distinct error message', (tester) async {
    final adapter = FakeAdapter(
      (_) => jsonBody({'success': false, 'message': 'Boom'}, status: 500),
    );
    await _pump(tester, adapter);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Inline error text + the toast description.
    expect(find.text('Boom'), findsNWidgets(2));

    await _flushToasts(tester);
    expect(find.text('Boom'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await _settle(tester);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Same message again: no second toast, only the inline text.
    expect(adapter.requests, hasLength(2));
    expect(find.text('Boom'), findsOneWidget);
    await _flushToasts(tester);
  });
}
