import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/month_range_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

const _names = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

void main() {
  testWidgets('moving From past 12 months shifts To and shows the toast', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final to = DateTime(now.year, now.month, 1);
    final from = DateTime(to.year, to.month - 5, 1);
    // Same month one year earlier: 13 months inclusive with `to`.
    final target = DateTime(to.year - 1, to.month, 1);

    DateTime? gotFrom;
    DateTime? gotTo;

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, screenType) => ToastificationWrapper(
          child: MaterialApp(
            home: Scaffold(
              body: MonthRangePicker(
                from: from,
                to: to,
                onChanged: (f, t) {
                  gotFrom = f;
                  gotTo = t;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(MonthRangePicker.formatMonth(from)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (var year = from.year; year > target.year; year--) {
      await tester.tap(find.byTooltip('Previous year'));
      await tester.pump();
    }
    await tester.tap(find.text(_names[target.month - 1]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Let the toast animate in.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(gotFrom, target);
    expect(gotTo, DateTime(target.year, target.month + 11, 1));
    expect(find.text('Date range limited to 12 months'), findsOneWidget);

    // Let the toast's auto-close timer finish.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
  });
}
