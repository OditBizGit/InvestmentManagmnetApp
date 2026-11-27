import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/manage_users_table_section.dart';
import 'package:sizer/sizer.dart';

import 'manage_users_fakes.dart';

Future<ManageUsersCubit> _pump(
  WidgetTester tester,
  FakeManageUsersRepository repo,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1400, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = ManageUsersCubit(repository: repo);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: SingleChildScrollView(
              child: ManageUsersTableSection(
                onToggleBlock: (user, {required terminateRemarks}) {},
                onUserTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await cubit.fetchUsers();
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('shows only Active and Block chips, no All', (tester) async {
    await _pump(tester, FakeManageUsersRepository(
      (filter) async => usersResponse([investor(1)]),
    ));

    expect(find.text('Active'), findsWidgets);
    expect(find.text('Block'), findsOneWidget);
    expect(find.text('All'), findsNothing);
    expect(find.text('Investor 1'), findsOneWidget);
  });

  testWidgets('tapping Block refetches, tapping Active switches back',
      (tester) async {
    final repo = FakeManageUsersRepository(
      (filter) async => usersResponse(
        filter == ManageUsersStatusFilter.active
            ? [investor(1)]
            : [investor(9, isActive: false)],
      ),
    );
    final cubit = await _pump(tester, repo);

    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();

    expect(repo.calls.last, ManageUsersStatusFilter.blocked);
    expect(cubit.filter, ManageUsersStatusFilter.blocked);
    expect(find.text('Investor 9'), findsOneWidget);
    expect(find.text('Investor 1'), findsNothing);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(repo.calls.last, ManageUsersStatusFilter.active);
    expect(find.text('Investor 1'), findsOneWidget);
  });

  testWidgets('chips stay usable when Block is empty', (tester) async {
    final repo = FakeManageUsersRepository(
      (filter) async => usersResponse(
        filter == ManageUsersStatusFilter.active ? [investor(1)] : [],
      ),
    );
    final cubit = await _pump(tester, repo);

    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();

    expect(cubit.state, isA<ManageUsersEmpty>());
    expect(find.text('No investors found'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Block'), findsOneWidget);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('Investor 1'), findsOneWidget);
  });

  testWidgets('chips stay usable when the request fails', (tester) async {
    final repo = FakeManageUsersRepository((filter) async {
      if (filter == ManageUsersStatusFilter.blocked) {
        throw Exception('boom');
      }
      return usersResponse([investor(1)]);
    });
    final cubit = await _pump(tester, repo);

    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();

    expect(cubit.state, isA<ManageUsersFailure>());
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('Investor 1'), findsOneWidget);
  });
}
