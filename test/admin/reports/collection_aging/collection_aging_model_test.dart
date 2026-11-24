import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/collection_aging/model/collection_aging_model.dart';

void main() {
  group('CollectionAgingReportModel.fromJson', () {
    test('parses a full payload', () {
      final model = CollectionAgingReportModel.fromJson({
        'asOfDate': '2026-11-23T00:00:00',
        'rows': [
          {
            'userId': 7,
            'investorCode': 'INV007',
            'name': 'Asha',
            'phoneNumber': '9999',
            'isActive': true,
            'totalPayable': 10000.5,
            'amountPaid': 4000,
            'outstanding': 6000.5,
            'notYetDue': 1000,
            'days1To30': 2000,
            'days31To60': 1500,
            'days61To90': 1000,
            'days90Plus': 500.5,
            'totalOverdue': 5000.5,
            'oldestDueDate': '2026-06-01T00:00:00',
            'maxDaysPastDue': 175,
          },
        ],
        'totals': {
          'investorCount': 1,
          'notYetDue': 1000,
          'days1To30': 2000,
          'days31To60': 1500,
          'days61To90': 1000,
          'days90Plus': 500.5,
          'totalOverdue': 5000.5,
          'outstanding': 6000.5,
        },
      });

      expect(model.asOfDate, DateTime(2026, 11, 23));
      expect(model.rows, hasLength(1));
      final row = model.rows.single;
      expect(row.userId, 7);
      expect(row.investorCode, 'INV007');
      expect(row.name, 'Asha');
      expect(row.phoneNumber, '9999');
      expect(row.isActive, isTrue);
      expect(row.outstanding, 6000.5);
      expect(row.days90Plus, 500.5);
      expect(row.oldestDueDate, DateTime(2026, 6, 1));
      expect(row.maxDaysPastDue, 175);
      expect(model.totals.investorCount, 1);
      expect(model.totals.totalOverdue, 5000.5);
      expect(model.totals.outstanding, 6000.5);
    });

    test('missing fields fall back to defaults and empty lists', () {
      final model = CollectionAgingReportModel.fromJson({});

      expect(model.asOfDate, isNull);
      expect(model.rows, isEmpty);
      expect(model.totals.totalOverdue, 0);

      final row = CollectionAgingRowModel.fromJson({});
      expect(row.name, '');
      expect(row.isActive, isFalse);
      expect(row.outstanding, 0);
      expect(row.oldestDueDate, isNull);
    });

    test('numbers may arrive as int or double', () {
      final asInt = CollectionAgingRowModel.fromJson({'outstanding': 100});
      final asDouble = CollectionAgingRowModel.fromJson({'outstanding': 100.0});

      expect(asInt.outstanding, 100.0);
      expect(asDouble.outstanding, 100.0);
      expect(asInt.outstanding, isA<double>());
    });

    test('date with a time part and an invalid date', () {
      final row = CollectionAgingRowModel.fromJson({
        'oldestDueDate': '2026-03-05T13:45:10',
      });
      expect(row.oldestDueDate, DateTime(2026, 3, 5, 13, 45, 10));

      final bad = CollectionAgingRowModel.fromJson({'oldestDueDate': 'nope'});
      expect(bad.oldestDueDate, isNull);
    });

    test('hasUnbucketedOutstanding when bucket sum is below outstanding', () {
      const covered = CollectionAgingRowModel(
        outstanding: 1000,
        notYetDue: 400,
        days1To30: 600,
      );
      const withAdvance = CollectionAgingRowModel(
        outstanding: 1000,
        days1To30: 600,
      );

      expect(covered.hasUnbucketedOutstanding, isFalse);
      expect(withAdvance.hasUnbucketedOutstanding, isTrue);
    });

    test('string numbers are parsed, garbage becomes 0 (no throw)', () {
      final row = CollectionAgingRowModel.fromJson({
        'outstanding': '1250.5',
        'days1To30': 'abc',
        'userId': '7',
        'maxDaysPastDue': '12',
        'notYetDue': null,
      });
      expect(row.outstanding, 1250.5);
      expect(row.days1To30, 0);
      expect(row.userId, 7);
      expect(row.maxDaysPastDue, 12);
      expect(row.notYetDue, 0);

      final totals = CollectionAgingTotalsModel.fromJson({
        'totalOverdue': '99.5',
        'investorCount': '3',
      });
      expect(totals.totalOverdue, 99.5);
      expect(totals.investorCount, 3);
    });
  });
}
