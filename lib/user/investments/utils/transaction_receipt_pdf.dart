import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class TransactionReceiptPdf {
  TransactionReceiptPdf._();

  static const _accentDark = PdfColor.fromInt(0xFF370F69);
  static const _textPrimary = PdfColor.fromInt(0xFF3D3D3D);
  static const _textSecondary = PdfColor.fromInt(0xFF8A8099);
  static const _green = PdfColor.fromInt(0xFF1BA752);
  // Matches AppColors.green @ 10% / 40% alpha on white (same as screen badge).
  static const _greenSoft = PdfColor(0.9106, 0.9655, 0.9322);
  static const _greenBorder = PdfColor(0.6424, 0.86196, 0.7286);
  static const _closingBalance = PdfColor.fromInt(0xFFE05A4F);
  static const _divider = PdfColor.fromInt(0xFFD0CBD8);
  static const _cardBorder = PdfColor.fromInt(0xFFE8E4EE);

  static Future<File> download({
    required String projectName,
    required InvestorTransactionItemModel transaction,
  }) async {
    final file = await _createFile(
      projectName: projectName,
      transaction: transaction,
    );
    await OpenFilex.open(file.path);
    return file;
  }

  static Future<void> share({
    required String projectName,
    required InvestorTransactionItemModel transaction,
  }) async {
    final file = await _createFile(
      projectName: projectName,
      transaction: transaction,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Transaction Receipt',
        text: 'Transaction receipt from Maribel Wellness Centre',
      ),
    );
  }

  static Future<File> _createFile({
    required String projectName,
    required InvestorTransactionItemModel transaction,
  }) async {
    final bytes = await _buildPdf(
      projectName: projectName,
      transaction: transaction,
    );
    return _saveFile(
      bytes: bytes,
      entryNo: transaction.entryNo,
      transactionId: transaction.transactionId,
      transactionDate: transaction.date,
    );
  }

  static Future<Uint8List> _buildPdf({
    required String projectName,
    required InvestorTransactionItemModel transaction,
  }) async {
    final amount = transaction.paidAmount > 0
        ? transaction.paidAmount
        : transaction.receivedAmount;
    final amountLabel = UserInvestmentsScreen.formatCurrency(amount);
    final amountInWords = CurrencyFormatter.amountInWords(amount);
    final dateLabel = UserInvestmentsScreen.formatDate(transaction.date);
    final timeLabel =
        UserInvestmentsScreen.formatTransactionTime(transaction.date);
    final dateTime =
        timeLabel.isNotEmpty ? '$dateLabel · $timeLabel' : dateLabel;
    final paymentMethod = transaction.paymentMethod.trim().isNotEmpty
        ? transaction.paymentMethod
        : (transaction.status.trim().isNotEmpty
            ? transaction.status
            : '-');
    final displayProject = projectName.trim().isNotEmpty
        ? projectName.trim()
        : 'Investment';
    final investor = transaction.fullName.trim().isNotEmpty
        ? transaction.fullName.toUpperCase()
        : '-';
    final closingBalance = UserInvestmentsScreen.formatCurrency(
      transaction.pendingAmount,
    );
    final generatedAt = DateTime.now();
    final generatedLabel =
        '${UserInvestmentsScreen.formatDate(generatedAt)} · ${UserInvestmentsScreen.formatTransactionTime(generatedAt)}';

    final fontData =
        await rootBundle.load('assets/font/Montserrat-Bold.ttf');
    final font = pw.Font.ttf(fontData);
    final logoData = await rootBundle.load(ImageConstants.logo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());
    final tickIcon = await _loadTickSvgImage();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: _cardBorder),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(logo, height: 56),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'TRANSACTION RECEIPT',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                        color: _accentDark,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Acknowledgement of payment received',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                    pw.SizedBox(height: 28),
                    pw.Text(
                      amountLabel,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      amountInWords,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _paidBadge(font: font, tickIcon: tickIcon),
                    pw.SizedBox(height: 20),
                    _dashedLine(),
                    pw.SizedBox(height: 14),
                    _row('Project', displayProject.toUpperCase(), font),
                    _row('Entry No', '${transaction.entryNo}', font),
                    _row('Investor', investor, font),
                    _row('Date & Time', dateTime, font),
                    _row('Payment Method', paymentMethod.toUpperCase(), font),
                    if (transaction.narration.trim().isNotEmpty)
                      _row('Narration', transaction.narration, font),
                    _row(
                      'Closing Balance',
                      closingBalance,
                      font,
                      valueColor: _closingBalance,
                    ),
                    pw.SizedBox(height: 14),
                    _dashedLine(),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Thank you for your investment',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Maribel Wellness Centre',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: _accentDark,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated on $generatedLabel',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static Future<pw.MemoryImage> _loadTickSvgImage() async {
    final rawSvg = await rootBundle.loadString(ImageConstants.tick);
    final greenSvg = rawSvg.replaceAll('fill="#000000"', 'fill="#1BA752"');
    final pictureInfo = await vg.loadPicture(
      SvgStringLoader(greenSvg),
      null,
    );
    try {
      // picture.toImage(w,h) does NOT scale — it draws at intrinsic size.
      // Scale onto a crisp square so the tick fills the PDF image.
      const pixelSize = 128;
      final src = pictureInfo.size;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.scale(pixelSize / src.width, pixelSize / src.height);
      canvas.drawPicture(pictureInfo.picture);
      final scaledPicture = recorder.endRecording();
      final image = await scaledPicture.toImage(pixelSize, pixelSize);
      try {
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw StateError('Failed to encode tick SVG as PNG');
        }
        return pw.MemoryImage(byteData.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    } finally {
      pictureInfo.picture.dispose();
    }
  }

  /// Mirrors the PAID chip on [TransactionReceiptScreen].
  static pw.Widget _paidBadge({
    required pw.Font font,
    required pw.MemoryImage tickIcon,
  }) {
    // Fixed height + radius = height/2 → true capsule (stadium).
    // A radius larger than both half-width and half-height makes the
    // pdf package draw an ellipse instead of a pill.
    const badgeHeight = 26.0;
    const outerRadius = badgeHeight / 2;
    const borderWidth = 1.0;
    const innerRadius = outerRadius - borderWidth;

    return pw.Container(
      height: badgeHeight,
      decoration: pw.BoxDecoration(
        color: _greenBorder,
        borderRadius: pw.BorderRadius.circular(outerRadius),
      ),
      padding: const pw.EdgeInsets.all(borderWidth),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: _greenSoft,
          borderRadius: pw.BorderRadius.circular(innerRadius),
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 12),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Image(tickIcon, width: 13, height: 13),
            pw.SizedBox(width: 6),
            pw.Text(
              'PAID',
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _row(
    String label,
    String value,
    pw.Font font, {
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: _textSecondary,
              ),
            ),
          ),
          pw.Expanded(
            flex: 6,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: valueColor ?? _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _dashedLine() {
    return pw.LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final width = constraints?.maxWidth ?? 400;
        final count = (width / (dashWidth + dashSpace)).floor();
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => pw.Container(
              width: dashWidth,
              height: 1.2,
              color: _divider,
            ),
          ),
        );
      },
    );
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
    final fileName = 'Transaction Receipt-$safeEntry-$dateStamp.pdf';
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
