import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';

import 'manage_users_fakes.dart';

void main() {
  late FakeAdapter adapter;
  late ManageUsersRepository repository;

  setUp(() {
    adapter = FakeAdapter(
      (options) async => jsonBody(listEnvelope([investorJson(1)])),
    );
    repository = ManageUsersRepository(dio: dioWith(adapter));
  });

  test('Active sends GetAllInvestors?status=all', () async {
    final response = await repository.getInvestors(
      filter: ManageUsersStatusFilter.active,
    );

    final request = adapter.requests.single;
    expect(request.path, '/api/Investor/GetAllInvestors');
    expect(request.method, 'GET');
    expect(request.queryParameters, {'status': 'all'});
    expect(request.uri.query, 'status=all');
    expect(response.users.single.id, 1);
  });

  test('Blocked sends GetAllInvestors?status=blocked', () async {
    await repository.getInvestors(filter: ManageUsersStatusFilter.blocked);

    final request = adapter.requests.single;
    expect(request.path, '/api/Investor/GetAllInvestors');
    expect(request.queryParameters, {'status': 'blocked'});
    expect(request.uri.query, 'status=blocked');
  });

  test('filter maps to the API value in one place', () {
    expect(ManageUsersStatusFilter.values, hasLength(2));
    expect(ManageUsersStatusFilter.active.apiValue, 'all');
    expect(ManageUsersStatusFilter.blocked.apiValue, 'blocked');
  });
}
