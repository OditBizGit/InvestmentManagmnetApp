import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/block_user_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/pdf_excel_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/review_block_request_model.dart';

import 'manage_users_fakes.dart';

const _active = ManageUsersStatusFilter.active;
const _blocked = ManageUsersStatusFilter.blocked;

ManageUsersCubit _cubit(FakeManageUsersRepository repo) {
  final cubit = ManageUsersCubit(repository: repo);
  addTearDown(cubit.close);
  return cubit;
}

FakeManageUsersRepository _repoByFilter({
  List<ManageUsersInvestor> active = const [],
  List<ManageUsersInvestor> blocked = const [],
}) {
  return FakeManageUsersRepository(
    (filter) async => usersResponse(filter == _active ? active : blocked),
  );
}

DioException _dioError() =>
    DioException(requestOptions: RequestOptions(path: '/x'));

/// Hands out one pending response per call so a test decides the order.
class _Gate {
  final calls = <ManageUsersStatusFilter, List<Completer<ManageUsersResponse>>>{
    _active: [],
    _blocked: [],
  };

  Future<ManageUsersResponse> call(ManageUsersStatusFilter filter) {
    final completer = Completer<ManageUsersResponse>();
    calls[filter]!.add(completer);
    return completer.future;
  }
}

void main() {
  test('default filter is Active and fetchUsers uses it', () async {
    final repo = _repoByFilter(active: [investor(1), investor(2)]);
    final cubit = _cubit(repo);

    expect(cubit.filter, _active);
    await cubit.fetchUsers();

    expect(repo.calls.first, _active);
    expect((cubit.state as ManageUsersSuccess).users.map((u) => u.id), [1, 2]);
  });

  test('setFilter(blocked) shows the blocked list', () async {
    final repo = _repoByFilter(
      active: [investor(1)],
      blocked: [investor(9, isActive: false)],
    );
    final cubit = _cubit(repo);
    await cubit.fetchUsers();
    repo.calls.clear();

    await cubit.setFilter(_blocked);

    expect(cubit.filter, _blocked);
    expect(repo.calls, [_blocked]);
    final state = cubit.state as ManageUsersSuccess;
    expect(state.users.map((u) => u.id), [9]);
    expect(state.isTableLoading, isFalse);
  });

  test('setFilter shows table loading while refetching', () async {
    final completer = Completer<ManageUsersResponse>();
    final repo = FakeManageUsersRepository((filter) {
      if (filter == _blocked) return completer.future;
      return Future.value(usersResponse([investor(1)]));
    });
    final cubit = _cubit(repo);
    final initial = cubit.fetchUsers();
    completer.complete(usersResponse([investor(9, isActive: false)]));
    await initial;

    final next = Completer<ManageUsersResponse>();
    repo.onGetInvestors = (_) => next.future;
    final pending = cubit.setFilter(_blocked);
    expect((cubit.state as ManageUsersSuccess).isTableLoading, isTrue);

    next.complete(usersResponse([investor(9, isActive: false)]));
    await pending;
    expect((cubit.state as ManageUsersSuccess).isTableLoading, isFalse);
  });

  test('re-activation refetch keeps the current filter', () async {
    final repo = _repoByFilter(
      active: [investor(1)],
      blocked: [investor(9, isActive: false)],
    );
    final cubit = _cubit(repo);
    await cubit.fetchUsers();
    await cubit.setFilter(_blocked);
    repo.calls.clear();

    await cubit.fetchUsers(); // what the screen does when the tab re-activates

    expect(repo.calls.first, _blocked);
    expect(cubit.filter, _blocked);
    expect((cubit.state as ManageUsersSuccess).users.single.id, 9);
  });

  test('setFilter to the same filter does not refetch', () async {
    final repo = _repoByFilter(active: [investor(1)]);
    final cubit = _cubit(repo);
    await cubit.fetchUsers();
    repo.calls.clear();

    await cubit.setFilter(_active);

    expect(repo.calls, isEmpty);
  });

  test('an older response never overwrites a newer one (both calls)', () async {
    final gate = _Gate();
    final cubit = _cubit(FakeManageUsersRepository(gate.call));

    final firstCall = cubit.fetchUsers(); // Active selected, still in flight
    final secondCall = cubit.setFilter(_blocked); // counts unknown: both calls

    gate.calls[_blocked]![1].complete(
      usersResponse([investor(9, isActive: false)]),
    );
    gate.calls[_active]![1].complete(usersResponse([investor(1)]));
    await secondCall;

    gate.calls[_active]![0].complete(
      usersResponse([investor(1), investor(2), investor(3)]),
    );
    gate.calls[_blocked]![0].complete(usersResponse([]));
    await firstCall;

    expect(cubit.filter, _blocked);
    expect((cubit.state as ManageUsersSuccess).users.map((u) => u.id), [9]);
    expect(cubit.activeCount, 1);
    expect(cubit.blockedCount, 1);
  });

  test('an older failure never overwrites a newer success', () async {
    final gate = _Gate();
    final cubit = _cubit(FakeManageUsersRepository(gate.call));

    final firstCall = cubit.fetchUsers();
    final secondCall = cubit.setFilter(_blocked);
    gate.calls[_blocked]![1].complete(
      usersResponse([investor(9, isActive: false)]),
    );
    gate.calls[_active]![1].complete(usersResponse([investor(1)]));
    await secondCall;

    gate.calls[_active]![0].completeError(_dioError());
    gate.calls[_blocked]![0].completeError(_dioError());
    await firstCall;

    expect(cubit.state, isA<ManageUsersSuccess>());
    expect(cubit.activeCount, 1);
  });

  test('no blocked investors gives Empty and the filter can be switched back',
      () async {
    final repo = _repoByFilter(active: [investor(1)]);
    final cubit = _cubit(repo);
    await cubit.fetchUsers();

    await cubit.setFilter(_blocked);
    expect(cubit.state, isA<ManageUsersEmpty>());
    expect(cubit.filter, _blocked);
    // Empty is a real answer: the Blocked count is 0, Active stays 1.
    expect(cubit.blockedCount, 0);
    expect(cubit.activeCount, 1);
    expect(cubit.totalCount, 1);

    await cubit.setFilter(_active);
    expect(cubit.filter, _active);
    expect((cubit.state as ManageUsersSuccess).users.single.id, 1);
  });

  test('Failure keeps the filter and a chip switch recovers', () async {
    final repo = FakeManageUsersRepository((filter) async {
      if (filter == _blocked) throw _dioError();
      return usersResponse([investor(1)]);
    });
    final cubit = _cubit(repo);
    await cubit.fetchUsers();

    await cubit.setFilter(_blocked);
    expect(cubit.state, isA<ManageUsersFailure>());
    expect(cubit.filter, _blocked);

    await cubit.setFilter(_active);
    expect(cubit.state, isA<ManageUsersSuccess>());
  });

  test('"Req sent" flag survives switching Active -> Blocked -> Active',
      () async {
    final repo = _repoByFilter(
      active: [investor(1), investor(2)],
      blocked: [investor(9, isActive: false)],
    );
    final cubit = _cubit(repo);
    await cubit.fetchUsers();

    final user = (cubit.state as ManageUsersSuccess).users.first;
    await cubit.toggleBlockStatus(user, terminateRemarks: 'long enough text');
    expect(
      (cubit.state as ManageUsersSuccess).users.first.hasPendingTerminateRequest,
      isTrue,
    );

    await cubit.setFilter(_blocked);
    await cubit.setFilter(_active);

    final users = (cubit.state as ManageUsersSuccess).users;
    expect(users.firstWhere((u) => u.id == 1).hasPendingTerminateRequest, true);
    expect(users.firstWhere((u) => u.id == 2).hasPendingTerminateRequest, false);
  });

  test('terminate request keeps the row in the Active list', () async {
    final repo = _repoByFilter(active: [investor(1)]);
    final cubit = _cubit(repo);
    await cubit.fetchUsers();

    await cubit.toggleBlockStatus(
      (cubit.state as ManageUsersSuccess).users.single,
      terminateRemarks: 'long enough text',
    );

    final users = (cubit.state as ManageUsersSuccess).users;
    expect(users.single.id, 1);
    expect(users.single.isActive, isTrue);
    expect(cubit.activeCount, 1);
    expect(cubit.blockedCount, 0);
  });

  group('summary card counts (both lists)', () {
    test('counts come from both lists, total is their sum', () async {
      final repo = _repoByFilter(
        active: [investor(1), investor(2)],
        blocked: [investor(9, isActive: false)],
      );
      final cubit = _cubit(repo);
      expect(cubit.totalCount, isNull);

      await cubit.fetchUsers();

      expect(repo.calls.toSet(), {_active, _blocked});
      expect(cubit.activeCount, 2);
      expect(cubit.blockedCount, 1);
      expect(cubit.totalCount, 3);
      // The table still shows only the selected list.
      expect((cubit.state as ManageUsersSuccess).users, hasLength(2));
    });

    test('chip switch keeps the counts and does not refetch the other list',
        () async {
      final repo = _repoByFilter(
        active: [investor(1), investor(2)],
        blocked: [investor(9, isActive: false)],
      );
      final cubit = _cubit(repo);
      await cubit.fetchUsers();
      repo.calls.clear();

      await cubit.setFilter(_blocked);

      expect(repo.calls, [_blocked]);
      expect(cubit.activeCount, 2);
      expect(cubit.blockedCount, 1);
      expect(cubit.totalCount, 3);
    });

    test('re-activation refreshes both counts', () async {
      var active = [investor(1)];
      final repo = FakeManageUsersRepository(
        (filter) async => usersResponse(
          filter == _active ? active : [investor(9, isActive: false)],
        ),
      );
      final cubit = _cubit(repo);
      await cubit.fetchUsers();
      expect(cubit.activeCount, 1);

      active = [investor(1), investor(2), investor(3)];
      await cubit.fetchUsers();

      expect(cubit.activeCount, 3);
      expect(cubit.totalCount, 4);
    });

    test('other list fails: selected list shows, its count is unknown not 0',
        () async {
      final repo = FakeManageUsersRepository((filter) async {
        if (filter == _blocked) throw _dioError();
        return usersResponse([investor(1), investor(2)]);
      });
      final cubit = _cubit(repo);

      await cubit.fetchUsers();

      expect((cubit.state as ManageUsersSuccess).users, hasLength(2));
      expect(cubit.activeCount, 2);
      expect(cubit.blockedCount, isNull);
      expect(cubit.totalCount, isNull);
    });

    test('other list fails later: last known value is kept', () async {
      var failBlocked = false;
      final repo = FakeManageUsersRepository((filter) async {
        if (filter == _blocked && failBlocked) throw _dioError();
        return usersResponse(
          filter == _active
              ? [investor(1), investor(2)]
              : [investor(9, isActive: false)],
        );
      });
      final cubit = _cubit(repo);
      await cubit.fetchUsers();

      failBlocked = true;
      await cubit.fetchUsers();

      expect(cubit.blockedCount, 1);
      expect(cubit.activeCount, 2);
      expect(cubit.totalCount, 3);
    });

    test('selected list fails: Failure shown, other count still updated',
        () async {
      final repo = FakeManageUsersRepository((filter) async {
        if (filter == _active) throw _dioError();
        return usersResponse([investor(9, isActive: false)]);
      });
      final cubit = _cubit(repo);

      await cubit.fetchUsers();

      expect(cubit.state, isA<ManageUsersFailure>());
      expect(cubit.blockedCount, 1);
      expect(cubit.activeCount, isNull);
    });

    test('chip switch retries the other list when its count is unknown',
        () async {
      var failBlocked = true;
      final repo = FakeManageUsersRepository((filter) async {
        if (filter == _blocked && failBlocked) throw _dioError();
        return usersResponse(
          filter == _active ? [investor(1)] : [investor(9, isActive: false)],
        );
      });
      final cubit = _cubit(repo);
      await cubit.fetchUsers();
      expect(cubit.blockedCount, isNull);

      failBlocked = false;
      await cubit.setFilter(_blocked);

      expect(cubit.blockedCount, 1);
      expect(cubit.activeCount, 1);
      expect(cubit.totalCount, 2);
    });

    test('unblock moves one from Blocked to Active in the counts', () async {
      final repo = _repoByFilter(
        active: [investor(1)],
        blocked: [investor(9, isActive: false), investor(8, isActive: false)],
      );
      final cubit = _cubit(repo);
      await cubit.fetchUsers();
      await cubit.setFilter(_blocked);
      expect(cubit.blockedCount, 2);
      expect(cubit.activeCount, 1);

      final user = (cubit.state as ManageUsersSuccess).users.first;
      await cubit.toggleBlockStatus(user);

      expect(repo.blockUserCalled, isTrue);
      expect(
        (cubit.state as ManageUsersSuccess).users.map((u) => u.id),
        [8],
      );
      expect(cubit.blockedCount, 1);
      expect(cubit.activeCount, 2);
      expect(cubit.totalCount, 3);
    });
  });

  group('approve terminate (review)', () {
    ReviewBlockRequestResponse review(
      int userId, {
      required bool isActive,
      String status = 'Approved',
    }) => ReviewBlockRequestResponse(
      status: true,
      message: status,
      code: 200,
      data: ReviewBlockRequestResult(
        requestId: 5,
        userId: userId,
        fullName: 'Investor $userId',
        isActive: isActive,
        status: status,
      ),
    );

    test('Active chip: row leaves the list, counts Active -1 / Blocked +1',
        () async {
      final repo = _repoByFilter(
        active: [investor(1), investor(2)],
        blocked: [investor(9, isActive: false)],
      );
      repo.onReview = (_) async => review(1, isActive: false);
      final cubit = _cubit(repo);
      await cubit.fetchUsers();

      await cubit.reviewBlockRequest(requestId: 5, status: 'Approved');

      final users = (cubit.state as ManageUsersSuccess).users;
      expect(users.map((u) => u.id), [2]);
      expect(cubit.activeCount, 1);
      expect(cubit.blockedCount, 2);
      expect(cubit.totalCount, 3);
    });

    test('Blocked chip: list unchanged, counts still move once', () async {
      final repo = _repoByFilter(
        active: [investor(1)],
        blocked: [investor(9, isActive: false)],
      );
      repo.onReview = (_) async => review(1, isActive: false);
      final cubit = _cubit(repo);
      await cubit.fetchUsers();
      await cubit.setFilter(_blocked);

      await cubit.reviewBlockRequest(requestId: 5, status: 'Approved');

      expect(
        (cubit.state as ManageUsersSuccess).users.map((u) => u.id),
        [9],
      );
      expect(cubit.activeCount, 0);
      expect(cubit.blockedCount, 2);
    });

    test('an already blocked row does not change the counts', () async {
      final repo = _repoByFilter(blocked: [investor(9, isActive: false)]);
      repo.onReview = (_) async => review(9, isActive: false);
      final cubit = _cubit(repo);
      await cubit.setFilter(_blocked);
      expect(cubit.blockedCount, 1);
      expect(cubit.activeCount, 0);

      await cubit.reviewBlockRequest(requestId: 5, status: 'Approved');

      expect(cubit.blockedCount, 1);
      expect(cubit.activeCount, 0);
    });

    test('reject changes neither the list nor the counts', () async {
      final repo = _repoByFilter(active: [investor(1)]);
      repo.onReview =
          (_) async => review(1, isActive: true, status: 'Rejected');
      final cubit = _cubit(repo);
      await cubit.fetchUsers();

      await cubit.reviewBlockRequest(requestId: 5, status: 'Rejected');

      expect((cubit.state as ManageUsersSuccess).users.single.id, 1);
      expect(cubit.activeCount, 1);
      expect(cubit.blockedCount, 0);
    });
  });

  group('transient flags survive a refetch', () {
    test('isExporting stays true when a chip switch refetches mid-export',
        () async {
      final repo = _repoByFilter(
        active: [investor(1)],
        blocked: [investor(9, isActive: false)],
      );
      final export = Completer<PdfExcelResponseModel>();
      repo.onGetPdfExcel = () => export.future;
      final cubit = _cubit(repo);
      await cubit.fetchUsers();

      final exporting = cubit.exportInvestorPaymentReport(
        asPdf: true,
        section: 'all',
        fromDate: DateTime(2026, 1, 1),
        toDate: DateTime(2026, 1, 31),
      );
      expect((cubit.state as ManageUsersSuccess).isExporting, isTrue);

      await cubit.setFilter(_blocked);
      expect((cubit.state as ManageUsersSuccess).isExporting, isTrue);

      repo.onGetInvestors = (_) async => usersResponse([]);
      await cubit.fetchUsers();
      expect((cubit.state as ManageUsersEmpty).isExporting, isTrue);

      repo.onGetInvestors = (_) async => throw _dioError();
      await cubit.fetchUsers();
      expect((cubit.state as ManageUsersFailure).isExporting, isTrue);

      export.completeError(_dioError());
      await exporting;
      expect((cubit.state as ManageUsersFailure).isExporting, isFalse);
    });

    test('isExporting is false when no export is running', () async {
      final repo = _repoByFilter(active: [investor(1)]);
      final cubit = _cubit(repo);
      await cubit.fetchUsers();

      expect((cubit.state as ManageUsersSuccess).isExporting, isFalse);
    });

    test('statusUpdatingUserId stays set when a refetch lands mid-request',
        () async {
      final repo = _repoByFilter(active: [investor(1), investor(2)]);
      final block = Completer<BlockUserResponseModel>();
      repo.onBlockUser = () => block.future;
      final cubit = _cubit(repo);
      await cubit.fetchUsers();

      final user = (cubit.state as ManageUsersSuccess).users.first;
      final toggling = cubit.toggleBlockStatus(
        user,
        terminateRemarks: 'long enough text',
      );
      expect((cubit.state as ManageUsersSuccess).statusUpdatingUserId, 1);

      await cubit.fetchUsers();
      expect((cubit.state as ManageUsersSuccess).statusUpdatingUserId, 1);

      block.complete(
        const BlockUserResponseModel(status: true, message: 'ok', code: 200),
      );
      await toggling;
      expect((cubit.state as ManageUsersSuccess).statusUpdatingUserId, isNull);
    });
  });
}
