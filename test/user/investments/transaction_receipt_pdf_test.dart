import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/utils/transaction_receipt_pdf.dart';

void main() {
  group('TransactionReceiptPdf.fileNameFor', () {
    final date = DateTime(2026, 11, 24);
    final stamp = UserInvestmentsScreen.formatDate(date);

    test('uses entryNo when it is greater than zero', () {
      expect(
        TransactionReceiptPdf.fileNameFor(
          entryNo: 42,
          transactionId: 7,
          transactionDate: date,
        ),
        'Payment Receipt - 42 - $stamp.pdf',
      );
    });

    test('falls back to transactionId when entryNo is zero', () {
      expect(
        TransactionReceiptPdf.fileNameFor(
          entryNo: 0,
          transactionId: 7,
          transactionDate: date,
        ),
        'Payment Receipt - 7 - $stamp.pdf',
      );
    });

    test('handles a missing date the way the old file name did', () {
      expect(
        TransactionReceiptPdf.fileNameFor(entryNo: 5, transactionId: 7),
        'Payment Receipt - 5 - ${UserInvestmentsScreen.formatDate(null)}.pdf',
      );
    });
  });
}
