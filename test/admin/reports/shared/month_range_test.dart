import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/month_range_picker.dart';

void main() {
  final now = DateTime(2026, 11, 23);

  MonthRangeChange change({
    required DateTime from,
    required DateTime to,
    required bool fromChanged,
  }) =>
      adjustMonthRange(from: from, to: to, fromChanged: fromChanged, now: now);

  group('adjustMonthRange', () {
    test('keeps a valid range and normalises to the first of the month', () {
      final r = change(
        from: DateTime(2026, 6, 17),
        to: DateTime(2026, 11, 5),
        fromChanged: true,
      );
      expect(r.from, DateTime(2026, 6, 1));
      expect(r.to, DateTime(2026, 11, 1));
      expect(r.limited, isFalse);
    });

    test('12 months inclusive (11 apart) is allowed', () {
      final r = change(
        from: DateTime(2025, 12, 1),
        to: DateTime(2026, 11, 1),
        fromChanged: true,
      );
      expect(r.from, DateTime(2025, 12, 1));
      expect(r.to, DateTime(2026, 11, 1));
      expect(r.limited, isFalse);
    });

    test(
      '13 months inclusive is limited: To shifts to From + 11 (toast case)',
      () {
        final r = change(
          from: DateTime(2025, 11, 1),
          to: DateTime(2026, 11, 1),
          fromChanged: true,
        );
        expect(r.from, DateTime(2025, 11, 1));
        expect(r.to, DateTime(2026, 10, 1));
        expect(r.limited, isTrue);
      },
    );

    test('moving From too far back shifts To to From + 11 months', () {
      final r = change(
        from: DateTime(2025, 1, 1),
        to: DateTime(2026, 6, 1),
        fromChanged: true,
      );
      expect(r.from, DateTime(2025, 1, 1));
      expect(r.to, DateTime(2025, 12, 1));
      expect(r.limited, isTrue);
    });

    test('moving To too far forward shifts From to To - 11 months', () {
      final r = change(
        from: DateTime(2025, 1, 1),
        to: DateTime(2026, 11, 1),
        fromChanged: false,
      );
      expect(r.to, DateTime(2026, 11, 1));
      expect(r.from, DateTime(2025, 12, 1));
      expect(r.limited, isTrue);
    });

    test('To before From aligns the other end (From changed)', () {
      final r = change(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 5, 1),
        fromChanged: true,
      );
      expect(r.from, DateTime(2026, 9, 1));
      expect(r.to, DateTime(2026, 9, 1));
      expect(r.limited, isFalse);
    });

    test('To before From aligns the other end (To changed)', () {
      final r = change(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 5, 1),
        fromChanged: false,
      );
      expect(r.from, DateTime(2026, 5, 1));
      expect(r.to, DateTime(2026, 5, 1));
    });

    test('future months are clamped to the current month', () {
      final r = change(
        from: DateTime(2026, 8, 1),
        to: DateTime(2027, 2, 1),
        fromChanged: false,
      );
      expect(r.to, DateTime(2026, 11, 1));
      expect(r.from, DateTime(2026, 8, 1));

      final r2 = change(
        from: DateTime(2027, 3, 1),
        to: DateTime(2026, 11, 1),
        fromChanged: true,
      );
      expect(r2.from, DateTime(2026, 11, 1));
      expect(r2.to, DateTime(2026, 11, 1));
    });

    test('cap works across a year boundary', () {
      final r = change(
        from: DateTime(2024, 12, 1),
        to: DateTime(2026, 3, 1),
        fromChanged: true,
      );
      expect(r.to, DateTime(2025, 11, 1));
      expect(r.limited, isTrue);
    });
  });

  group('defaultMonthRange', () {
    test('is the last 6 months ending this month', () {
      final r = defaultMonthRange(now: now);
      expect(r.from, DateTime(2026, 6, 1));
      expect(r.to, DateTime(2026, 11, 1));
    });

    test('crosses the year boundary', () {
      final r = defaultMonthRange(now: DateTime(2026, 2, 10));
      expect(r.from, DateTime(2025, 9, 1));
      expect(r.to, DateTime(2026, 2, 1));
    });
  });
}
