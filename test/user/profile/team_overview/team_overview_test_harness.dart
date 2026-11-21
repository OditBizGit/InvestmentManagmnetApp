import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

/// Pumps [home] inside Sizer + MaterialApp at a given logical [size].
/// Resets every view override in addTearDown. Uses pump(), never
/// pumpAndSettle(), because of image loading.
Future<void> pumpTeamApp(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(402, 874),
  double devicePixelRatio = 1.0,
  double textScale = 1.0,
  double bottomInset = 0,
}) async {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = size * devicePixelRatio;
  if (bottomInset > 0) {
    final padding = FakeViewPadding(bottom: bottomInset * devicePixelRatio);
    tester.view.padding = padding;
    tester.view.viewPadding = padding;
  }
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
  });

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pump();
}
