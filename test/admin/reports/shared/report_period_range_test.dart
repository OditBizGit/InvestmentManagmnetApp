import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/report_period_range.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';

void main() {
  group('reportPeriodRange', () {
    test('This Month = first of month to today', () {
      final (from, to) = reportPeriodRange(
        StaffReportPeriod.thisMonth,
        now: DateTime(2026, 11, 23, 14, 30),
      );
      expect(from, DateTime(2026, 11, 1));
      expect(to, DateTime(2026, 11, 23));
    });

    test('This Month on the 1st is a single day', () {
      final (from, to) = reportPeriodRange(
        StaffReportPeriod.thisMonth,
        now: DateTime(2026, 3, 1),
      );
      expect(from, DateTime(2026, 3, 1));
      expect(to, DateTime(2026, 3, 1));
    });

    test('Last Month covers the whole previous month', () {
      final (from, to) = reportPeriodRange(
        StaffReportPeriod.lastMonth,
        now: DateTime(2026, 11, 23),
      );
      expect(from, DateTime(2026, 10, 1));
      expect(to, DateTime(2026, 10, 31));
    });

    test('Last Month in January is December of the previous year', () {
      final (from, to) = reportPeriodRange(
        StaffReportPeriod.lastMonth,
        now: DateTime(2026, 1, 15),
      );
      expect(from, DateTime(2025, 12, 1));
      expect(to, DateTime(2025, 12, 31));
    });

    test('Last Month handles February in a leap and a normal year', () {
      final leap = reportPeriodRange(
        StaffReportPeriod.lastMonth,
        now: DateTime(2028, 3, 10),
      );
      expect(leap.$2, DateTime(2028, 2, 29));

      final normal = reportPeriodRange(
        StaffReportPeriod.lastMonth,
        now: DateTime(2027, 3, 10),
      );
      expect(normal.$2, DateTime(2027, 2, 28));
    });

    test('Custom returns the given dates without time', () {
      final (from, to) = reportPeriodRange(
        StaffReportPeriod.custom,
        now: DateTime(2026, 11, 23),
        customFrom: DateTime(2026, 2, 3, 9, 15),
        customTo: DateTime(2026, 4, 20, 23, 59),
      );
      expect(from, DateTime(2026, 2, 3));
      expect(to, DateTime(2026, 4, 20));
    });

    test('Custom without dates throws', () {
      expect(
        () => reportPeriodRange(StaffReportPeriod.custom, now: DateTime(2026)),
        throwsArgumentError,
      );
    });

    test('Custom with From after To throws', () {
      expect(
        () => reportPeriodRange(
          StaffReportPeriod.custom,
          customFrom: DateTime(2026, 5, 2),
          customTo: DateTime(2026, 5, 1),
        ),
        throwsArgumentError,
      );
    });
  });
}
