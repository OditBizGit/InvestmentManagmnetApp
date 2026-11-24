import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/investor_statement_pdf.dart';

import 'investor_statement_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  bool isPdf(List<int> bytes) =>
      bytes.length > 4 && latin1.decode(bytes.sublist(0, 5)) == '%PDF-';

  test('builds non-empty bytes for a multi-row statement (TC17a)', () async {
    final ledger = [
      for (var i = 1; i <= 120; i++)
        {
          'lineNo': i,
          'entryDate': '2025-01-01T00:00:00',
          'entryType': 'Payment',
          'reference': 'PAY-$i',
          'description': 'Installment $i',
          'paymentMethod': 'UPI',
          'verificationStatus': 'Approved',
          'chargeAmount': 0,
          'paymentAmount': 1000 + i,
          'runningBalance': 100000 - i,
        },
    ];

    final bytes = await InvestorStatementPdf.build(
      parsedStatement(ledger: ledger),
      generatedAt: DateTime(2026, 11, 23),
    );

    expect(isPdf(bytes), isTrue);
    expect(bytes.length, greaterThan(5000));
  });

  test('builds for an empty ledger and schedule (TC17b)', () async {
    final multi = await InvestorStatementPdf.build(parsedStatement());
    final empty = await InvestorStatementPdf.build(
      parsedStatement(ledger: [], schedule: []),
    );

    expect(isPdf(empty), isTrue);
    expect(empty, isNotEmpty);
    expect(empty.length, lessThan(multi.length));
  });

  test('file name is statement_<code>_<yyyyMMdd>.pdf', () {
    final statement = parsedStatement();
    expect(
      InvestorStatementPdf.fileName(statement, now: DateTime(2026, 3, 9)),
      'statement_INV007_20260309.pdf',
    );
  });

  test('uses the rupee sign when the bundled font has the glyph', () async {
    final data = await rootBundle.load('assets/font/Montserrat-Bold.ttf');

    expect(InvestorStatementPdf.symbolForFont(data), '₹');
  });

  test('falls back to "Rs." when the font has no rupee glyph', () async {
    // Unparseable / glyph-less font data cannot render the rupee sign.
    expect(InvestorStatementPdf.symbolForFont(ByteData(16)), 'Rs.');

    final bytes = await InvestorStatementPdf.build(
      parsedStatement(),
      currencySymbol: 'Rs.',
    );
    expect(isPdf(bytes), isTrue);
    expect(bytes, isNotEmpty);
  });

  test('summary shows only what the screen shows (R28)', () {
    expect(InvestorStatementPdf.summaryLabels, [
      'Commitment',
      'Net Paid',
      'Discount',
      'Pending',
      'Opening Balance',
      'Closing Balance',
    ]);
    expect(InvestorStatementPdf.summaryLabels, isNot(contains('Gross Paid')));
    expect(InvestorStatementPdf.summaryLabels, isNot(contains('Refunds')));
  });
}
