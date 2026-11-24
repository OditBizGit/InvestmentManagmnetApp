import 'dart:typed_data';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:maribel_wellness_centre_application/admin/reports/investor_statement/model/investor_statement_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/utils/export_file_saver.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Web-safe investor statement PDF (R12): `pdf` MultiPage + [saveExportFile].
/// No `dart:io`, no file-system access in [build].
class InvestorStatementPdf {
  InvestorStatementPdf._();

  static const String _fontAsset = 'assets/font/Montserrat-Bold.ttf';
  static const int _rupeeCodePoint = 0x20B9;

  /// `statement_<investorCode>_<yyyyMMdd>.pdf`
  static String fileName(InvestorStatement statement, {DateTime? now}) {
    final date = now ?? DateTime.now();
    final stamp =
        '${date.year}${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    final code = statement.header.investorCode.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    return 'statement_${code.isEmpty ? 'investor' : code}_$stamp.pdf';
  }

  static Future<ExportSaveResult> generateAndSave(
    InvestorStatement statement, {
    DateTime? now,
  }) async {
    final bytes = await build(statement, generatedAt: now);
    return saveExportFile(
      bytes: bytes,
      fileName: fileName(statement, now: now),
      mimeType: 'application/pdf',
    );
  }

  /// Builds the PDF bytes. Uses "Rs." instead of the rupee sign when the
  /// bundled font has no glyph for it.
  static Future<Uint8List> build(
    InvestorStatement statement, {
    DateTime? generatedAt,
    String? currencySymbol,
  }) async {
    final fontData = await rootBundle.load(_fontAsset);
    final font = pw.Font.ttf(fontData);
    final symbol = currencySymbol ?? symbolForFont(fontData);
    String money(double v) => CurrencyFormatter.format(v, symbol: symbol);

    final header = statement.header;
    final doc = pw.Document(title: 'Investor Statement');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => [
          pw.Text(
            'Investor Statement',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Investor: ${_investorLabel(header)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Period: ${_rangeLabel(header)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Generated: ${_formatDate(generatedAt ?? DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          _section('Summary'),
          _table(
            headers: summaryLabels,
            rows: [
              [
                money(header.commitmentAmount),
                money(header.netPaid),
                money(header.discount),
                money(header.pending),
                money(header.openingBalance),
                money(header.closingBalance),
              ],
            ],
            rightFrom: 0,
          ),
          pw.SizedBox(height: 14),
          _section('Ledger'),
          if (statement.ledger.isEmpty)
            _empty()
          else
            _table(
              headers: const [
                'Date',
                'Type',
                'Reference',
                'Description',
                'Method',
                'Status',
                'Charge',
                'Payment',
                'Balance',
              ],
              rows: [
                for (final e in statement.ledger)
                  [
                    _formatDate(e.entryDate),
                    e.entryType,
                    e.reference,
                    e.description,
                    e.paymentMethod,
                    e.verificationStatus,
                    money(e.chargeAmount),
                    money(e.paymentAmount),
                    money(e.runningBalance),
                  ],
              ],
              rightFrom: 6,
            ),
          pw.SizedBox(height: 14),
          _section('Installment Schedule'),
          if (statement.schedule.isEmpty)
            _empty()
          else
            _table(
              headers: const [
                'No',
                'Due Date',
                'Amount',
                'Paid',
                'Pending',
                'Status',
                'Days Overdue',
              ],
              rows: [
                for (final s in statement.schedule)
                  [
                    '${s.installmentNo}',
                    _formatDate(s.dueDate),
                    money(s.amount),
                    money(s.paidAmount),
                    money(s.pendingAmount),
                    s.status,
                    '${s.daysOverdue}',
                  ],
              ],
              rightFrom: 2,
              rightTo: 4,
            ),
        ],
      ),
    );

    return doc.save();
  }

  /// Summary columns: exactly the figures the screen shows.
  static const List<String> summaryLabels = [
    'Commitment',
    'Net Paid',
    'Discount',
    'Pending',
    'Opening Balance',
    'Closing Balance',
  ];

  /// `₹` when [fontData] has the glyph, else `Rs.`.
  static String symbolForFont(ByteData fontData) =>
      _supportsRupee(fontData) ? '₹' : 'Rs.';

  static bool _supportsRupee(ByteData fontData) {
    try {
      return TtfParser(
        fontData,
      ).charToGlyphIndexMap.containsKey(_rupeeCodePoint);
    } catch (_) {
      return false;
    }
  }

  static pw.Widget _section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _empty() =>
      pw.Text('No records found', style: const pw.TextStyle(fontSize: 11));

  /// Columns from [rightFrom] to [rightTo] (default: last) are right aligned.
  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required int rightFrom,
    int? rightTo,
  }) {
    final last = rightTo ?? headers.length - 1;
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0EBF6),
      ),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        for (var i = rightFrom; i <= last; i++) i: pw.Alignment.centerRight,
      },
    );
  }

  static String _investorLabel(InvestorStatementHeader h) {
    final label = h.investorCode.isEmpty
        ? h.name
        : '${h.investorCode} - ${h.name}';
    return label.isEmpty ? '—' : label;
  }

  static String _rangeLabel(InvestorStatementHeader h) {
    final from = h.fromDate;
    final to = h.toDate;
    if (from != null && to != null) {
      return '${_formatDate(from)} – ${_formatDate(to)}';
    }
    if (from != null) return 'From ${_formatDate(from)}';
    if (to != null) return 'Up to ${_formatDate(to)}';
    return 'All dates';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]}, ${date.year}';
  }
}
