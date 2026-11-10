import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/pdf_excel_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/utils/export_file_saver.dart';
import 'package:maribel_wellness_centre_application/core/utils/csv_escape.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ManageUsersExportFile {
  ManageUsersExportFile._();

  static Future<ExportSaveResult> generateAndSave({
    required bool asPdf,
    required String section,
    required DateTime fromDate,
    required DateTime toDate,
    required List<PdfExcelInvestorModel> investors,
  }) async {
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final sectionSlug = section.toLowerCase() == 'due' ? 'dues' : 'all';
    final extension = asPdf ? 'pdf' : 'csv';
    final fileName = 'investor_payments_${sectionSlug}_$stamp.$extension';

    final bytes = asPdf
        ? await _buildPdfBytes(
            section: section,
            fromDate: fromDate,
            toDate: toDate,
            investors: investors,
          )
        : _buildCsvBytes(
            fromDate: fromDate,
            toDate: toDate,
            section: section,
            investors: investors,
          );

    return saveExportFile(
      bytes: bytes,
      fileName: fileName,
      mimeType: asPdf ? 'application/pdf' : 'text/csv',
    );
  }

  static Uint8List _buildCsvBytes({
    required DateTime fromDate,
    required DateTime toDate,
    required String section,
    required List<PdfExcelInvestorModel> investors,
  }) {
    final sectionLabel = section.toLowerCase() == 'due'
        ? 'Dues'
        : 'All transactions';

    const header = [
      'User ID',
      'Investor Code',
      'Full Name',
      'Date',
      'Payment Method',
      'Due Amount',
      'Paid Amount',
      'Pending Amount',
    ];

    final buffer = StringBuffer()
      ..writeln('\uFEFFReport period,${_escapeCsv(_formatReportDate(fromDate))} – ${_escapeCsv(_formatReportDate(toDate))}')
      ..writeln('Section,${_escapeCsv(sectionLabel)}')
      ..writeln(header.map(_escapeCsv).join(','));

    for (final row in investors) {
      buffer.writeln(
        [
          row.userId,
          row.investorCode,
          row.fullName,
          _formatPaymentDate(row.paymentDate),
          _displayOrNA(row.paymentMethod),
          CurrencyFormatter.format(row.dueAmount),
          CurrencyFormatter.format(row.paidAmount),
          CurrencyFormatter.format(row.pendingAmount),
        ].map(_escapeCsv).join(','),
      );
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  static Future<Uint8List> _buildPdfBytes({
    required String section,
    required DateTime fromDate,
    required DateTime toDate,
    required List<PdfExcelInvestorModel> investors,
  }) async {
    final sectionLabel = section.toLowerCase() == 'due'
        ? 'Dues'
        : 'All transactions';

    final fontData =
        await rootBundle.load('assets/font/Montserrat-Bold.ttf');
    final baseFont = pw.Font.ttf(fontData);
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: baseFont,
          bold: baseFont,
        ),
        build: (context) {
          return [
            pw.Text(
              'Investor payment report',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Section: $sectionLabel · '
              '${_formatReportDate(fromDate)} – ${_formatReportDate(toDate)}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
            if (investors.isEmpty)
              pw.Text(
                'No investor records found for the selected range.',
                style: const pw.TextStyle(fontSize: 11),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: const [
                  'User ID',
                  'Investor Code',
                  'Full Name',
                  'Date',
                  'Payment Method',
                  'Due Amount',
                  'Paid Amount',
                  'Pending Amount',
                ],
                data: investors
                    .map(
                      (item) => [
                        '${item.userId}',
                        item.investorCode,
                        item.fullName,
                        _formatPaymentDate(item.paymentDate),
                        _displayOrNA(item.paymentMethod),
                        CurrencyFormatter.format(item.dueAmount),
                        CurrencyFormatter.format(item.paidAmount),
                        CurrencyFormatter.format(item.pendingAmount),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF0EBF6),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                  7: pw.Alignment.centerRight,
                },
              ),
          ];
        },
      ),
    );

    return doc.save();
  }

  static String _escapeCsv(Object value) => escapeCsvField(value);

  static String _displayOrNA(String value) {
    final text = value.trim();
    return text.isEmpty ? 'N/A' : text;
  }

  static String _formatPaymentDate(DateTime? date) {
    if (date == null) return 'N/A';
    final local = date.toLocal();
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
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day.toString().padLeft(2, '0')} '
        '${months[local.month - 1]}, ${local.year} '
        '${hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String _formatReportDate(DateTime date) {
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
