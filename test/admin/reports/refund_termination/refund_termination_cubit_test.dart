import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/cubit/refund_termination_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/model/refund_termination_model.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/repository/refund_termination_repository.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';

import 'refund_termination_fakes.dart';

DioException _dioError(int status, Object data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test('Initial, then Loading, then Loaded', () async {
    final repo = FakeRefundTerminationRepository(
      () async => const RefundTerminationReportModel(
        refunds: [RefundRowModel(name: 'Asha')],
      ),
    );
    final cubit = RefundTerminationCubit(repo);
    addTearDown(cubit.close);
    expect(cubit.state, isA<RefundTerminationInitial>());

    final emitted = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RefundTerminationLoading>(),
        isA<RefundTerminationLoaded>(),
      ]),
    );
    await cubit.load(period: StaffReportPeriod.thisMonth);
    await emitted;
  });

  test('period is converted to dates passed to the repository', () async {
    final repo = FakeRefundTerminationRepository(
      () async => const RefundTerminationReportModel(),
    );
    final cubit = RefundTerminationCubit(repo);
    addTearDown(cubit.close);
    final now = DateTime.now();

    await cubit.load(period: StaffReportPeriod.thisMonth);
    expect(repo.calls.last, (
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day),
    ));

    await cubit.load(period: StaffReportPeriod.lastMonth);
    expect(repo.calls.last, (
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 0),
    ));

    await cubit.load(
      period: StaffReportPeriod.custom,
      customFrom: DateTime(2026, 1, 5),
      customTo: DateTime(2026, 2, 9),
    );
    expect(repo.calls.last, (DateTime(2026, 1, 5), DateTime(2026, 2, 9)));
  });

  test('emits Error with the server message', () async {
    final cubit = RefundTerminationCubit(
      FakeRefundTerminationRepository(
        () async => throw _dioError(400, {
          'success': false,
          'message': 'From date cannot be after To date.',
        }),
      ),
    );
    addTearDown(cubit.close);

    await cubit.load(period: StaffReportPeriod.thisMonth);

    expect(
      (cubit.state as RefundTerminationError).message,
      'From date cannot be after To date.',
    );
  });

  test('ProblemDetails: title, else first validation error', () async {
    final withTitle = RefundTerminationCubit(
      FakeRefundTerminationRepository(
        () async => throw _dioError(400, {'title': 'One or more errors'}),
      ),
    );
    addTearDown(withTitle.close);
    await withTitle.load(period: StaffReportPeriod.thisMonth);
    expect(
      (withTitle.state as RefundTerminationError).message,
      'One or more errors',
    );

    final withErrors = RefundTerminationCubit(
      FakeRefundTerminationRepository(
        () async => throw _dioError(400, {
          'errors': {
            'fromDate': ['Invalid from date.'],
          },
        }),
      ),
    );
    addTearDown(withErrors.close);
    await withErrors.load(period: StaffReportPeriod.thisMonth);
    expect(
      (withErrors.state as RefundTerminationError).message,
      'Invalid from date.',
    );
  });

  test('never exposes raw exception text', () async {
    final cubit = RefundTerminationCubit(
      FakeRefundTerminationRepository(
        () async => throw _dioError(500, 'Internal <html>'),
      ),
    );
    addTearDown(cubit.close);

    await cubit.load(period: StaffReportPeriod.thisMonth);

    final message = (cubit.state as RefundTerminationError).message;
    expect(message, 'Something went wrong. Please try again.');
  });

  test('late response from an older request is ignored (race)', () async {
    final completers = <Completer<RefundTerminationReportModel>>[];
    final cubit = RefundTerminationCubit(
      FakeRefundTerminationRepository(() {
        final c = Completer<RefundTerminationReportModel>();
        completers.add(c);
        return c.future;
      }),
    );
    addTearDown(cubit.close);

    final futureA = cubit.load(period: StaffReportPeriod.thisMonth);
    final futureB = cubit.load(period: StaffReportPeriod.lastMonth);
    await Future<void>.delayed(Duration.zero);
    expect(completers, hasLength(2));

    completers[1].complete(
      const RefundTerminationReportModel(refunds: [RefundRowModel(name: 'B')]),
    );
    await futureB;
    completers[0].complete(
      const RefundTerminationReportModel(refunds: [RefundRowModel(name: 'A')]),
    );
    await futureA;

    expect(
      (cubit.state as RefundTerminationLoaded).report.refunds.single.name,
      'B',
    );
  });

  test('late error from an older request is ignored too', () async {
    final completers = <Completer<RefundTerminationReportModel>>[];
    final cubit = RefundTerminationCubit(
      FakeRefundTerminationRepository(() {
        final c = Completer<RefundTerminationReportModel>();
        completers.add(c);
        return c.future;
      }),
    );
    addTearDown(cubit.close);

    final futureA = cubit.load(period: StaffReportPeriod.thisMonth);
    final futureB = cubit.load(period: StaffReportPeriod.lastMonth);
    await Future<void>.delayed(Duration.zero);
    completers[1].complete(const RefundTerminationReportModel());
    await futureB;
    completers[0].completeError(Exception('old failure'));
    await futureA;

    expect(cubit.state, isA<RefundTerminationLoaded>());
  });

  test('invalid custom range shows "Select a valid date range."', () async {
    final repo = FakeRefundTerminationRepository(
      () async => const RefundTerminationReportModel(),
    );
    final cubit = RefundTerminationCubit(repo);
    addTearDown(cubit.close);

    await cubit.load(
      period: StaffReportPeriod.custom,
      customFrom: DateTime(2026, 2, 10),
      customTo: DateTime(2026, 2, 1),
    );
    expect(
      (cubit.state as RefundTerminationError).message,
      'Select a valid date range.',
    );

    await cubit.load(period: StaffReportPeriod.custom);
    expect(
      (cubit.state as RefundTerminationError).message,
      'Select a valid date range.',
    );
    expect(repo.calls, isEmpty);
  });

  test(
    'repository: 200 with success:false throws the server message',
    () async {
      final repo = RefundTerminationRepository(
        Dio()
          ..httpClientAdapter = FakeAdapter(
            (_) => jsonBody({'success': false, 'message': 'Not allowed.'}),
          ),
      );

      await expectLater(
        repo.getReport(
          fromDate: DateTime(2026, 11, 1),
          toDate: DateTime(2026, 11, 2),
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Not allowed.'),
          ),
        ),
      );

      final cubit = RefundTerminationCubit(repo);
      addTearDown(cubit.close);
      await cubit.load(period: StaffReportPeriod.thisMonth);
      expect((cubit.state as RefundTerminationError).message, 'Not allowed.');
    },
  );
}
