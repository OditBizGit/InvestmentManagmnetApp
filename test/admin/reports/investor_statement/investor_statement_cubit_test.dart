import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/investor_statement/cubit/investor_statement_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/investor_statement/repository/investor_statement_repository.dart';

import 'investor_statement_fakes.dart';

void main() {
  late FakeAdapter adapter;
  late InvestorStatementCubit cubit;

  void build(Future<ResponseBody> Function(RequestOptions o) handler) {
    adapter = FakeAdapter(handler);
    final dio = dioWith(adapter);
    cubit = InvestorStatementCubit(
      repository: InvestorStatementRepository(dio),
      investorsRepository: InvestorsRepository(dio: dio),
    );
    addTearDown(cubit.close);
  }

  Future<ResponseBody> ok(RequestOptions o) async => jsonBody(
    o.path.endsWith('GetInvestors') ? investorsEnvelope() : statementEnvelope(),
  );

  test('loadInvestors maps investors to picker options', () async {
    build(ok);

    await cubit.loadInvestors();

    expect(
      cubit.state.investorsStatus,
      InvestorStatementInvestorsStatus.success,
    );
    expect(cubit.state.investors.map((o) => o.label), [
      'INV007 - Asha Rao',
      'INV008 - Ravi Kumar',
    ]);
    expect(cubit.state.investors.first.matches('asha'), isTrue);
    expect(cubit.state.investors.first.matches('inv008'), isFalse);
  });

  test('statement without dates sends no date params (TC15)', () async {
    build(ok);

    await cubit.fetchStatement(userId: 7);

    final request = adapter.statementRequests.single;
    expect(request.path, '/api/Report/InvestorStatement/7');
    expect(request.queryParameters, isEmpty);
    expect(cubit.state.statementStatus, InvestorStatementStatus.success);
    expect(cubit.state.statement.ledger, hasLength(2));
    expect(cubit.state.statement.schedule, hasLength(1));
  });

  test('statement sends only the dates that are set (TC16)', () async {
    build(ok);

    await cubit.fetchStatement(userId: 7, fromDate: DateTime(2025, 3, 5));
    expect(adapter.statementRequests.last.queryParameters, {
      'fromDate': '2025-03-05',
    });

    await cubit.fetchStatement(userId: 7, toDate: DateTime(2025, 12, 31));
    expect(adapter.statementRequests.last.queryParameters, {
      'toDate': '2025-12-31',
    });

    await cubit.fetchStatement(
      userId: 7,
      fromDate: DateTime(2025, 3, 5),
      toDate: DateTime(2025, 12, 31),
    );
    expect(adapter.statementRequests.last.queryParameters, {
      'fromDate': '2025-03-05',
      'toDate': '2025-12-31',
    });
  });

  test('400 shows the server message (TC16)', () async {
    build(
      (o) async => jsonBody({
        'success': false,
        'message': 'From date cannot be after To date',
      }, status: 400),
    );

    await cubit.fetchStatement(userId: 7);

    expect(cubit.state.statementStatus, InvestorStatementStatus.failure);
    expect(
      cubit.state.statementErrorMessage,
      'From date cannot be after To date',
    );
  });

  test(
    '404 shows the server message, ProblemDetails show errors (TC18)',
    () async {
      build(
        (o) async => jsonBody({
          'success': false,
          'message': 'Investor not found',
        }, status: 404),
      );
      await cubit.fetchStatement(userId: 999);
      expect(cubit.state.statementErrorMessage, 'Investor not found');

      adapter.onRequest = (o) async => jsonBody({
        'title': 'One or more validation errors occurred.',
        'errors': {
          'userId': ['The value must be greater than 0.'],
        },
      }, status: 400);
      await cubit.fetchStatement(userId: 0);
      expect(
        cubit.state.statementErrorMessage,
        'The value must be greater than 0.',
      );

      adapter.onRequest = (o) async =>
          jsonBody({'title': 'Bad Request'}, status: 400);
      await cubit.fetchStatement(userId: 0);
      expect(cubit.state.statementErrorMessage, 'Bad Request');
    },
  );

  test('500 without message never leaks raw Dio text (TC21)', () async {
    build((o) async => jsonBody(<String, dynamic>{}, status: 500));

    await cubit.fetchStatement(userId: 7);

    expect(
      cubit.state.statementErrorMessage,
      'Something went wrong. Please try again.',
    );
  });

  test('clearStatement returns to the empty state', () async {
    build(ok);
    await cubit.fetchStatement(userId: 7);

    cubit.clearStatement();

    expect(cubit.state.statementStatus, InvestorStatementStatus.initial);
    expect(cubit.state.statement.ledger, isEmpty);
    expect(cubit.state.investors, isEmpty);
  });

  test('investors failure surfaces the server message', () async {
    build((o) async => jsonBody({'message': 'Not allowed'}, status: 403));
    await cubit.loadInvestors();
    expect(
      cubit.state.investorsStatus,
      InvestorStatementInvestorsStatus.failure,
    );
    expect(cubit.state.investorsErrorMessage, 'Not allowed');
  });

  test('a late statement answer does not overwrite a newer request', () async {
    final a = Completer<ResponseBody>();
    final b = Completer<ResponseBody>();
    build((o) {
      return o.path.endsWith('/7') ? a.future : b.future;
    });

    final first = cubit.fetchStatement(userId: 7);
    final second = cubit.fetchStatement(userId: 8);

    b.complete(
      jsonBody(
        statementEnvelope(
          ledger: [
            {'lineNo': 1, 'reference': 'B-REF'},
          ],
        ),
      ),
    );
    await second;
    a.complete(jsonBody(statementEnvelope()));
    await first;

    expect(cubit.state.statementStatus, InvestorStatementStatus.success);
    expect(cubit.state.statement.ledger.single.reference, 'B-REF');
  });

  test('a late investors answer is ignored', () async {
    final a = Completer<ResponseBody>();
    final b = Completer<ResponseBody>();
    var calls = 0;
    build((o) => ++calls == 1 ? a.future : b.future);

    final first = cubit.loadInvestors();
    final second = cubit.loadInvestors();

    b.complete(jsonBody(investorsEnvelope()));
    await second;
    a.complete(
      jsonBody({
        'status': true,
        'data': [
          {'userId': 1, 'fullName': 'Old One', 'userRole': 'Investor'},
        ],
      }),
    );
    await first;

    expect(cubit.state.investors.map((o) => o.userId), [7, 8]);
  });
}
