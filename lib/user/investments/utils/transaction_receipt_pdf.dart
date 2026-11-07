import 'dart:io';
import 'dart:typed_data';

import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Builds an A5-landscape PDF from a PNG capture of the on-screen receipt UI.
///
/// The receipt layout lives only in [TransactionReceiptScreen]; this class
/// wraps that screenshot so download/share stay visually identical.
class TransactionReceiptPdf {
  TransactionReceiptPdf._();

  static Future<File> download({
    required Uint8List receiptPngBytes,
    required InvestorTransactionItemModel transaction,
  }) async {
    final file = await _createFile(
      receiptPngBytes: receiptPngBytes,
      transaction: transaction,
    );
    await OpenFilex.open(file.path);
    return file;
  }

  static Future<void> share({
    required Uint8List receiptPngBytes,
    required InvestorTransactionItemModel transaction,
  }) async {
    final file = await _createFile(
      receiptPngBytes: receiptPngBytes,
      transaction: transaction,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Provisional Project Contribution Receipt',
        text:
            'Provisional project contribution receipt from Maribel Maternity Care',
      ),
    );
  }

  static Future<File> _createFile({
    required Uint8List receiptPngBytes,
    required InvestorTransactionItemModel transaction,
  }) async {
    final bytes = await _buildPdf(receiptPngBytes);
    return _saveFile(
      bytes: bytes,
      entryNo: transaction.entryNo,
      transactionId: transaction.transactionId,
      transactionDate: transaction.date,
    );
  }

  static Future<Uint8List> _buildPdf(Uint8List receiptPngBytes) async {
    final image = pw.MemoryImage(receiptPngBytes);
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(8),
        build: (_) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );
    return doc.save();
  }

  static Future<File> _saveFile({
    required Uint8List bytes,
    required int entryNo,
    required int transactionId,
    DateTime? transactionDate,
  }) async {
    final directory = await _resolveSaveDirectory();
    final safeEntry = entryNo > 0 ? entryNo : transactionId;
    final dateStamp = UserInvestmentsScreen.formatDate(transactionDate);
    final fileName = 'Contribution Receipt-$safeEntry-$dateStamp.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<Directory> _resolveSaveDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      try {
        if (await downloads.exists()) {
          final probe = File(
            '${downloads.path}/.maribel_receipt_write_probe',
          );
          await probe.writeAsString('ok');
          await probe.delete();
          return downloads;
        }
      } catch (_) {
        // Fall through to app documents when public Downloads is not writable.
      }
    }

    return getApplicationDocumentsDirectory();
  }
}
