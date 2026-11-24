import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';

/// Converts a [StaffReportPeriod] into a date-only (from, to) pair.
///
/// - This Month: first day of the current month to today.
/// - Last Month: first to last day of the previous month.
/// - Custom: [customFrom] / [customTo] (required, From must not be after To).
///
/// [now] is injectable for tests.
(DateTime, DateTime) reportPeriodRange(
  StaffReportPeriod period, {
  DateTime? now,
  DateTime? customFrom,
  DateTime? customTo,
}) {
  final today = _dateOnly(now ?? DateTime.now());

  switch (period) {
    case StaffReportPeriod.thisMonth:
      return (DateTime(today.year, today.month, 1), today);
    case StaffReportPeriod.lastMonth:
      // Day 0 of a month is the last day of the previous month; DateTime
      // normalises month 0 to December of the previous year.
      return (
        DateTime(today.year, today.month - 1, 1),
        DateTime(today.year, today.month, 0),
      );
    case StaffReportPeriod.custom:
      if (customFrom == null || customTo == null) {
        throw ArgumentError('Custom period requires customFrom and customTo.');
      }
      final from = _dateOnly(customFrom);
      final to = _dateOnly(customTo);
      if (from.isAfter(to)) {
        throw ArgumentError('customFrom must not be after customTo.');
      }
      return (from, to);
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
