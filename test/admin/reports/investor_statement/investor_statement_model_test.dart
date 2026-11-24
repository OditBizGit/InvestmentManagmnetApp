import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/investor_statement/model/investor_statement_model.dart';

import 'investor_statement_fakes.dart';

void main() {
  test('parses header, ledger and schedule (TC15)', () {
    final model = InvestorStatementResponseModel.fromJson(statementEnvelope());

    expect(model.success, isTrue);
    final header = model.data.header;
    expect(header.investorCode, 'INV007');
    expect(header.name, 'Asha Rao');
    expect(header.commitmentAmount, 120000.0);
    expect(header.grossPaid, 50000.5);
    expect(header.investmentStartDate, DateTime(2025, 1, 1));
    expect(header.settlementDate, isNull);
    expect(header.closingBalance, 69999.5);
    expect(header.pending, 69000.0);

    final ledger = model.data.ledger;
    expect(ledger, hasLength(2));
    expect(ledger.first.entryDate, DateTime(2025, 1, 1));
    expect(ledger.first.entryType, 'Investment');
    expect(ledger.first.chargeAmount, 120000.0);
    expect(ledger.last.verificationStatus, 'Pending');
    expect(ledger.last.runningBalance, 69999.5);

    final schedule = model.data.schedule.single;
    expect(schedule.installmentNo, 1);
    expect(schedule.dueDate, DateTime(2025, 2, 1));
    expect(schedule.pendingAmount, 9999.5);
    expect(schedule.daysOverdue, 12);
  });

  test('missing lists are empty and bad dates are null', () {
    final model = InvestorStatementResponseModel.fromJson(
      statementEnvelope(omitLists: true),
    );
    expect(model.data.ledger, isEmpty);
    expect(model.data.schedule, isEmpty);

    final broken = InvestorStatementResponseModel.fromJson({
      'success': true,
      'data': {
        'header': {'investmentStartDate': 'nope', 'netPaid': 5},
        'ledger': [
          {'entryDate': 'nope', 'chargeAmount': 7},
        ],
      },
    });
    expect(broken.data.header.investmentStartDate, isNull);
    expect(broken.data.header.netPaid, 5.0);
    expect(broken.data.ledger.single.entryDate, isNull);
    expect(broken.data.ledger.single.chargeAmount, 7.0);
    expect(broken.data.schedule, isEmpty);
  });

  test('empty body parses to an empty statement', () {
    final model = InvestorStatementResponseModel.fromJson({'success': true});
    expect(model.data.header.userId, 0);
    expect(model.data.ledger, isEmpty);
  });
}
