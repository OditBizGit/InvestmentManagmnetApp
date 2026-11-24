import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/refund_termination/model/refund_termination_model.dart';

void main() {
  group('RefundTerminationReportModel.fromJson', () {
    test('parses a full payload', () {
      final model = RefundTerminationReportModel.fromJson({
        'refunds': [
          {
            'refundId': 11,
            'requestId': 12,
            'userId': 13,
            'investorCode': 'INV013',
            'name': 'Asha',
            'refundDate': '2026-11-10T00:00:00',
            'refundAmount': 2500.5,
            'paymentMethod': 'Cash',
            'remarks': 'Because',
          },
        ],
        'terminated': [
          {
            'userId': 21,
            'investorCode': 'INV021',
            'name': 'Bala',
            'terminatedDate': '2026-11-05T00:00:00',
            'dateSource': 'ModifiedDate',
            'totalPayable': 100000,
            'totalPaid': 40000.25,
            'totalRefunded': 8000,
            'pendingRefundRequests': 1500,
            'remainingRefundable': 30500.25,
          },
        ],
        'totals': {
          'refundCount': 1,
          'refundAmount': 2500.5,
          'terminatedCount': 1,
          'totalPaid': 40000.25,
          'totalRefunded': 8000,
          'remainingRefundable': 30500.25,
        },
      });

      final refund = model.refunds.single;
      expect(refund.refundId, 11);
      expect(refund.investorCode, 'INV013');
      expect(refund.refundDate, DateTime(2026, 11, 10));
      expect(refund.refundAmount, 2500.5);
      expect(refund.paymentMethod, 'Cash');
      expect(refund.remarks, 'Because');

      final t = model.terminated.single;
      expect(t.terminatedDate, DateTime(2026, 11, 5));
      expect(t.dateSource, 'ModifiedDate');
      expect(t.isApproximateDate, isTrue);
      expect(t.totalPaid, 40000.25);
      expect(t.pendingRefundRequests, 1500);
      expect(t.remainingRefundable, 30500.25);

      expect(model.totals.refundCount, 1);
      expect(model.totals.terminatedCount, 1);
      expect(model.totals.remainingRefundable, 30500.25);
    });

    test('missing fields and lists fall back to defaults', () {
      final model = RefundTerminationReportModel.fromJson({});

      expect(model.refunds, isEmpty);
      expect(model.terminated, isEmpty);
      expect(model.totals.refundAmount, 0);

      final t = TerminatedInvestorModel.fromJson({});
      expect(t.name, '');
      expect(t.terminatedDate, isNull);
      expect(t.isApproximateDate, isFalse);
    });

    test('BlockRequest date source is not approximate', () {
      final t = TerminatedInvestorModel.fromJson({
        'dateSource': 'BlockRequest',
      });
      expect(t.isApproximateDate, isFalse);
    });

    test('numbers may be int or double', () {
      final a = RefundRowModel.fromJson({'refundAmount': 100});
      final b = RefundRowModel.fromJson({'refundAmount': 100.0});
      expect(a.refundAmount, 100.0);
      expect(b.refundAmount, 100.0);
      expect(a.refundAmount, isA<double>());
    });

    test('ISO date with a time part', () {
      final r = RefundRowModel.fromJson({'refundDate': '2026-03-05T13:45:10'});
      expect(r.refundDate, DateTime(2026, 3, 5, 13, 45, 10));
      expect(RefundRowModel.fromJson({'refundDate': 'x'}).refundDate, isNull);
    });

    test('string numbers are parsed, garbage becomes 0 (no throw)', () {
      final r = RefundRowModel.fromJson({
        'refundAmount': '2500.75',
        'refundId': '4',
        'requestId': 'x',
      });
      expect(r.refundAmount, 2500.75);
      expect(r.refundId, 4);
      expect(r.requestId, 0);

      final t = TerminatedInvestorModel.fromJson({
        'totalPaid': '100',
        'remainingRefundable': 'nope',
      });
      expect(t.totalPaid, 100);
      expect(t.remainingRefundable, 0);

      final totals = RefundTerminationTotalsModel.fromJson({
        'refundCount': '2',
        'refundAmount': '10.5',
      });
      expect(totals.refundCount, 2);
      expect(totals.refundAmount, 10.5);
    });
  });
}
