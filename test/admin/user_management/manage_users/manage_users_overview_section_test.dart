import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/manage_users_overview_section.dart';
import 'package:sizer/sizer.dart';

Future<void> _pump(
  WidgetTester tester, {
  int? total,
  int? active,
  int? blocked,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1400, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ManageUsersOverviewSection(
              totalUsers: total,
              activeUsers: active,
              blockedUsers: blocked,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the three counts', (tester) async {
    await _pump(tester, total: 7, active: 5, blocked: 2);

    expect(find.text('7'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('shows an em dash for a count that is not known', (tester) async {
    await _pump(tester, total: null, active: 5, blocked: null);

    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
