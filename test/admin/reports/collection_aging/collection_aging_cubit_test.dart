import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/cubit/collection_aging_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/model/collection_aging_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/repository/collection_aging_repository.dart';

import 'collection_aging_fakes.dart';

DioException _dioError(int status, Object data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test(
    'starts Initial, then Loading, then Loaded; passes the as-of date',
    () async {
      final repo = FakeCollectionAgingRepository(
        (_) async => const CollectionAgingReportModel(
          rows: [CollectionAgingRowModel(name: 'Asha')],
        ),
      );
      final cubit = CollectionAgingCubit(repo);
      addTearDown(cubit.close);

      expect(cubit.state, isA<CollectionAgingInitial>());

      final emitted = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CollectionAgingLoading>(),
          isA<CollectionAgingLoaded>(),
        ]),
      );
      await cubit.load(DateTime(2026, 11, 20));
      await emitted;

      expect(
        (cubit.state as CollectionAgingLoaded).report.rows.single.name,
        'Asha',
      );
      expect(repo.calls, [DateTime(2026, 11, 20)]);
    },
  );

  test('emits Error with the server message from the envelope', () async {
    final cubit = CollectionAgingCubit(
      FakeCollectionAgingRepository(
        (_) async => throw _dioError(400, {
          'success': false,
          'message': 'As-of date cannot be in the future.',
        }),
      ),
    );
    addTearDown(cubit.close);

    await cubit.load(DateTime(2026, 11, 20));

    expect(cubit.state, isA<CollectionAgingError>());
    expect(
      (cubit.state as CollectionAgingError).message,
      'As-of date cannot be in the future.',
    );
  });

  test('ProblemDetails: uses title, else the first validation error', () async {
    final withTitle = CollectionAgingCubit(
      FakeCollectionAgingRepository(
        (_) async => throw _dioError(400, {'title': 'Bad request title'}),
      ),
    );
    addTearDown(withTitle.close);
    await withTitle.load(DateTime(2026, 11, 20));
    expect(
      (withTitle.state as CollectionAgingError).message,
      'Bad request title',
    );

    final withErrors = CollectionAgingCubit(
      FakeCollectionAgingRepository(
        (_) async => throw _dioError(400, {
          'errors': {
            'asOfDate': ['The value is not valid.'],
          },
        }),
      ),
    );
    addTearDown(withErrors.close);
    await withErrors.load(DateTime(2026, 11, 20));
    expect(
      (withErrors.state as CollectionAgingError).message,
      'The value is not valid.',
    );
  });

  test('never exposes raw exception text', () async {
    final cubit = CollectionAgingCubit(
      FakeCollectionAgingRepository(
        (_) async => throw _dioError(500, 'Internal <html>'),
      ),
    );
    addTearDown(cubit.close);

    await cubit.load(DateTime(2026, 11, 20));

    final message = (cubit.state as CollectionAgingError).message;
    expect(message, 'Something went wrong. Please try again.');
    expect(message, isNot(contains('DioException')));
  });

  test('late response from an older request is ignored (race)', () async {
    final completers = <DateTime, Completer<CollectionAgingReportModel>>{};
    final repo = FakeCollectionAgingRepository((asOf) {
      return (completers[asOf] = Completer<CollectionAgingReportModel>())
          .future;
    });
    final cubit = CollectionAgingCubit(repo);
    addTearDown(cubit.close);

    final a = DateTime(2026, 11, 1);
    final b = DateTime(2026, 11, 2);
    final futureA = cubit.load(a);
    final futureB = cubit.load(b);

    completers[b]!.complete(
      const CollectionAgingReportModel(
        rows: [CollectionAgingRowModel(name: 'B')],
      ),
    );
    await futureB;
    completers[a]!.complete(
      const CollectionAgingReportModel(
        rows: [CollectionAgingRowModel(name: 'A')],
      ),
    );
    await futureA;

    expect((cubit.state as CollectionAgingLoaded).report.rows.single.name, 'B');
  });

  test('late error from an older request is ignored too', () async {
    final completers = <DateTime, Completer<CollectionAgingReportModel>>{};
    final repo = FakeCollectionAgingRepository((asOf) {
      return (completers[asOf] = Completer<CollectionAgingReportModel>())
          .future;
    });
    final cubit = CollectionAgingCubit(repo);
    addTearDown(cubit.close);

    final a = DateTime(2026, 11, 1);
    final b = DateTime(2026, 11, 2);
    final futureA = cubit.load(a);
    final futureB = cubit.load(b);
    completers[b]!.complete(const CollectionAgingReportModel());
    await futureB;
    completers[a]!.completeError(Exception('old failure'));
    await futureA;

    expect(cubit.state, isA<CollectionAgingLoaded>());
  });

  test(
    'repository: 200 with success:false throws the server message',
    () async {
      final adapter = FakeAdapter(
        (_) => jsonBody({'success': false, 'message': 'Not allowed.'}),
      );
      final repo = CollectionAgingRepository(
        Dio()..httpClientAdapter = adapter,
      );

      await expectLater(
        repo.getReport(asOfDate: DateTime(2026, 11, 20)),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Not allowed.'),
          ),
        ),
      );

      final cubit = CollectionAgingCubit(repo);
      addTearDown(cubit.close);
      await cubit.load(DateTime(2026, 11, 20));
      expect((cubit.state as CollectionAgingError).message, 'Not allowed.');
    },
  );

  test('repository omits asOfDate for today, sends other dates', () async {
    final adapter = FakeAdapter((_) => jsonBody(agingEnvelope()));
    final repo = CollectionAgingRepository(Dio()..httpClientAdapter = adapter);
    final now = DateTime.now();

    await repo.getReport(asOfDate: DateTime(now.year, now.month, now.day));
    await repo.getReport(asOfDate: now);
    await repo.getReport(asOfDate: DateTime(2026, 1, 5));

    expect(
      adapter.requests[0].queryParameters.containsKey('asOfDate'),
      isFalse,
    );
    expect(
      adapter.requests[1].queryParameters.containsKey('asOfDate'),
      isFalse,
    );
    expect(adapter.requests[2].queryParameters['asOfDate'], '2026-01-05');
  });
}
