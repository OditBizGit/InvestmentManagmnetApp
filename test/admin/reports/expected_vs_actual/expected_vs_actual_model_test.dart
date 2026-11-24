import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/expected_vs_actual/model/expected_vs_actual_model.dart';

import 'expected_vs_actual_fakes.dart';

void main() {
  test('report parses months, totals and ints/doubles (TC09)', () {
    final model = ExpectedVsActualResponseModel.fromJson(
      reportEnvelope(
        months: [monthJson(expected: 1000.5, payments: 800, refunds: 100.25)],
      ),
    );

    expect(model.success, isTrue);
    final row = model.data.months.single;
    expect(row.month, DateTime(2024, 3, 1));
    expect(row.expectedAmount, 1000.5);
    expect(row.actualPayments, 800.0);
    expect(row.refunds, 100.25);
    expect(row.expectedInstallments, 2);
    expect(row.collectionRate, 70.0);
    expect(model.data.totals.expectedAmount, 1000);
    expect(model.data.fromMonth, DateTime(2024, 3, 1));
  });

  test('null collectionRate stays null (TC11)', () {
    final model = ExpectedVsActualResponseModel.fromJson(
      reportEnvelope(months: [monthJson(expected: 0, rate: null)]),
    );
    expect(model.data.months.single.collectionRate, isNull);
  });

  test('missing lists, totals and bad dates fall back to empty', () {
    final model = ExpectedVsActualResponseModel.fromJson({
      'success': true,
      'data': {'months': null, 'fromMonth': 'not-a-date'},
    });
    expect(model.data.months, isEmpty);
    expect(model.data.fromMonth, isNull);
    expect(model.data.totals.expectedAmount, 0);
    expect(model.message, '');

    final empty = ExpectedVsActualDetailsResponseModel.fromJson({
      'success': true,
    });
    expect(empty.data.rows, isEmpty);
  });

  test('details parse rows and totals (TC12)', () {
    final model = ExpectedVsActualDetailsResponseModel.fromJson(
      detailsEnvelope(),
    );
    final row = model.data.rows.single;
    expect(row.investorCode, 'INV007');
    expect(row.name, 'Asha Rao');
    expect(row.actualAmount, 700);
    expect(row.collectionRate, 70);
    expect(model.data.totals.investorCount, 1);
    expect(model.data.totals.expectedAmount, 1000);
    expect(model.data.month, DateTime(2024, 3, 1));
  });
}
