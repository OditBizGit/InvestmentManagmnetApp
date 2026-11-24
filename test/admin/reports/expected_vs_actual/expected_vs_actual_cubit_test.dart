import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/expected_vs_actual/cubit/expected_vs_actual_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/expected_vs_actual/repository/expected_vs_actual_repository.dart';

import 'expected_vs_actual_fakes.dart';

void main() {
  late FakeAdapter adapter;
  late ExpectedVsActualCubit cubit;

  void build(Future<ResponseBody> Function(RequestOptions o) h) {
    adapter = FakeAdapter(h);
    cubit = ExpectedVsActualCubit(ExpectedVsActualRepository(dioWith(adapter)));
    addTearDown(cubit.close);
  }

  test('range becomes whole-month request params (TC09, TC10)', () async {
    build((o) async => jsonBody(reportEnvelope()));

    await cubit.fetchReport(
      fromMonth: DateTime(2026, 1, 1),
      toMonth: DateTime(2026, 6, 1),
    );

    final request = adapter.requests.single;
    expect(request.path, '/api/Report/ExpectedVsActual');
    expect(request.queryParameters, {
      'fromDate': '2026-01-01',
      'toDate': '2026-06-01',
    });
    expect(cubit.state.listStatus, ExpectedVsActualListStatus.success);
    expect(cubit.state.report.months, hasLength(1));
  });

  test('drill-down keeps the month list and sends month (TC12)', () async {
    build((o) async {
      return o.path.endsWith('Details')
          ? jsonBody(detailsEnvelope())
          : jsonBody(reportEnvelope());
    });

    await cubit.fetchReport(
      fromMonth: DateTime(2026, 6, 1),
      toMonth: DateTime(2026, 6, 1),
    );
    final months = cubit.state.report.months;

    await cubit.fetchDetails(DateTime(2026, 6, 1));

    expect(adapter.requests.last.queryParameters, {'month': '2026-06-01'});
    expect(cubit.state.detailsStatus, ExpectedVsActualDetailsStatus.success);
    expect(cubit.state.details.rows, hasLength(1));
    expect(cubit.state.report.months, same(months));
    expect(cubit.state.listStatus, ExpectedVsActualListStatus.success);

    cubit.resetDetails();
    expect(cubit.state.detailsStatus, ExpectedVsActualDetailsStatus.initial);
    expect(cubit.state.details.rows, isEmpty);
    expect(cubit.state.report.months, same(months));
  });

  test('server message is shown on 400 (TC10)', () async {
    build(
      (o) async => jsonBody({
        'success': false,
        'message': 'Date range cannot exceed 12 months',
      }, status: 400),
    );

    await cubit.fetchReport(
      fromMonth: DateTime(2025, 1, 1),
      toMonth: DateTime(2026, 6, 1),
    );

    expect(cubit.state.listStatus, ExpectedVsActualListStatus.failure);
    expect(cubit.state.listErrorMessage, 'Date range cannot exceed 12 months');
  });

  test('ProblemDetails shows first error, then title', () async {
    build(
      (o) async => jsonBody({
        'title': 'One or more validation errors occurred.',
        'errors': {
          'month': ['The month is required.'],
        },
      }, status: 400),
    );
    await cubit.fetchDetails(DateTime(2026, 6, 1));
    expect(cubit.state.detailsErrorMessage, 'The month is required.');

    adapter.onRequest = (o) async =>
        jsonBody({'title': 'Bad Request'}, status: 400);
    await cubit.fetchDetails(DateTime(2026, 6, 1));
    expect(cubit.state.detailsStatus, ExpectedVsActualDetailsStatus.failure);
    expect(cubit.state.detailsErrorMessage, 'Bad Request');
  });

  test('500 without message never leaks raw Dio text (TC21)', () async {
    build((o) async => jsonBody(<String, dynamic>{}, status: 500));

    await cubit.fetchReport(
      fromMonth: DateTime(2026, 6, 1),
      toMonth: DateTime(2026, 6, 1),
    );

    expect(cubit.state.listStatus, ExpectedVsActualListStatus.failure);
    expect(
      cubit.state.listErrorMessage,
      'Something went wrong. Please try again.',
    );
    expect(cubit.state.listErrorMessage, isNot(contains('DioException')));
  });

  test('success=false in a 200 shows its message', () async {
    build((o) async => jsonBody({'success': false, 'message': 'No access'}));
    await cubit.fetchReport(
      fromMonth: DateTime(2026, 6, 1),
      toMonth: DateTime(2026, 6, 1),
    );
    expect(cubit.state.listErrorMessage, 'No access');
  });

  test('a late report answer does not overwrite a newer request', () async {
    final a = Completer<ResponseBody>();
    final b = Completer<ResponseBody>();
    build(
      (o) =>
          o.queryParameters['fromDate'] == '2026-01-01' ? a.future : b.future,
    );

    final first = cubit.fetchReport(
      fromMonth: DateTime(2026, 1, 1),
      toMonth: DateTime(2026, 6, 1),
    );
    final second = cubit.fetchReport(
      fromMonth: DateTime(2026, 3, 1),
      toMonth: DateTime(2026, 6, 1),
    );

    b.complete(
      jsonBody(
        reportEnvelope(months: [monthJson(month: '2026-03-01T00:00:00')]),
      ),
    );
    await second;
    a.complete(
      jsonBody(
        reportEnvelope(months: [monthJson(month: '2026-01-01T00:00:00')]),
      ),
    );
    await first;

    expect(cubit.state.report.months.single.month, DateTime(2026, 3, 1));
  });

  test('a late details answer is ignored after a newer one', () async {
    final a = Completer<ResponseBody>();
    final b = Completer<ResponseBody>();
    build(
      (o) => o.queryParameters['month'] == '2026-01-01' ? a.future : b.future,
    );

    final first = cubit.fetchDetails(DateTime(2026, 1, 1));
    final second = cubit.fetchDetails(DateTime(2026, 2, 1));

    b.complete(
      jsonBody(
        detailsEnvelope(
          rows: [
            {'userId': 2, 'investorCode': 'NEW'},
          ],
        ),
      ),
    );
    await second;
    a.complete(jsonBody(detailsEnvelope()));
    await first;

    expect(cubit.state.details.rows.single.investorCode, 'NEW');
  });
}
