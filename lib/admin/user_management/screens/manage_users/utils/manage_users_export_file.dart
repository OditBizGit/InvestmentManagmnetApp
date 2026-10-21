import 'dart:convert';
import 'dart:typed_data';

import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/pdf_excel_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/utils/export_file_saver.dart';
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
        : _buildCsvBytes(investors);

    return saveExportFile(
      bytes: bytes,
      fileName: fileName,
      mimeType: asPdf ? 'application/pdf' : 'text/csv',
    );
  }

  static Uint8List _buildCsvBytes(List<PdfExcelInvestorModel> investors) {
    const header = [
      'User ID',
      'Investor Code',
      'Full Name',
      'Due Amount',
      'Paid Amount',
      'Pending Amount',
    ];

    final buffer = StringBuffer()
      ..writeln('\uFEFF${header.map(_escapeCsv).join(',')}');

    for (final row in investors) {
      buffer.writeln(
        [
          row.userId,
          row.investorCode,
          row.fullName,
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

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
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
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
              ),
          ];
        },
      ),
    );

    return doc.save();
  }

  static String _escapeCsv(Object value) {
    final text = value.toString();
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
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
