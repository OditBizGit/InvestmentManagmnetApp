import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/fakes.dart';

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1400, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) =>
          MaterialApp(home: Scaffold(body: home)),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.init(secureStorage: FakeSecureStorage());
    await storage.setUserRole('Admin');
    await getIt.reset();
    getIt.registerSingleton<LocalStorage>(storage);
  });

  tearDown(() => getIt.reset());

  testWidgets('tapping each new drawer item selects it (TC01)', (tester) async {
    final selected = <AdminDrawerItem>[];
    await _pump(
      tester,
      AdminSideDrawer(
        selectedItem: AdminDrawerItem.dashboard,
        onItemSelected: selected.add,
        onLogout: () {},
        animate: false,
      ),
    );

    await tester.tap(find.text('Reports'));
    await tester.pump();

    const expected = {
      // PM 2026-11-23: Collection Aging hidden for now — uncomment to restore.
      // 'Collection Aging': AdminDrawerItem.collectionAging,
      'Expected vs Actual': AdminDrawerItem.expectedVsActual,
      'Refunds & Terminations': AdminDrawerItem.refundTermination,
      'Investor Statement': AdminDrawerItem.investorStatement,
    };
    for (final entry in expected.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pump();
    }

    expect(selected, expected.values.toList());
  });
}
