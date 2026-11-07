import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/transaction_receipt_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/utils/transaction_receipt_pdf.dart';

/// Renders [TransactionReceiptDocument] off-screen and saves the same PDF as
/// the investor receipt screen.
class TransactionReceiptDownloader {
  TransactionReceiptDownloader._();

  static const double _a5LandscapeRatio = 210 / 148;
  static const double _captureWidth = 640;

  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF4A4A4A);
  static const Color _line = Color(0xFF9A9A9A);
  static const Color _cardBorder = Color(0xFFE0E0E0);

  static Future<void> download({
    required BuildContext context,
    required InvestorTransactionItemModel transaction,
    required String projectName,
    String? investorAddress,
    String? projectSignaturePath,
  }) async {
    final pngBytes = await _captureReceiptPng(
      context: context,
      transaction: transaction,
      projectName: projectName,
      investorAddress: investorAddress,
      projectSignaturePath: projectSignaturePath,
    );
    await TransactionReceiptPdf.download(
      receiptPngBytes: pngBytes,
      transaction: transaction,
    );
  }

  static Future<Uint8List> _captureReceiptPng({
    required BuildContext context,
    required InvestorTransactionItemModel transaction,
    required String projectName,
    String? investorAddress,
    String? projectSignaturePath,
  }) async {
    final boundaryKey = GlobalKey();
    final receipt = _buildReceiptWidget(
      boundaryKey: boundaryKey,
      transaction: transaction,
      projectName: projectName,
      investorAddress: investorAddress,
      projectSignaturePath: projectSignaturePath,
    );

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -5000,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: receipt,
        ),
      ),
    );

    overlay.insert(entry);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await WidgetsBinding.instance.endOfFrame;
      // Allow signature/network image to resolve when present.
      await Future<void>.delayed(const Duration(milliseconds: 280));
      await WidgetsBinding.instance.endOfFrame;

      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Receipt is not ready to capture');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      try {
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw StateError('Failed to encode receipt image');
        }
        return byteData.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      entry.remove();
    }
  }

  static Widget _buildReceiptWidget({
    required GlobalKey boundaryKey,
    required InvestorTransactionItemModel transaction,
    required String projectName,
    String? investorAddress,
    String? projectSignaturePath,
  }) {
    final amount = transaction.paidAmount > 0
        ? transaction.paidAmount
        : transaction.receivedAmount;
    final amountNumeric = CurrencyFormatter.format(amount, symbol: '');
    final amountInWords = CurrencyFormatter.amountInWords(amount);
    final date = transaction.date;
    final dateLabel = UserInvestmentsScreen.formatDate(date);
    final receiptNo = transaction.entryNo > 0
        ? '${transaction.entryNo}'
        : '${transaction.transactionId}';
    final investorName = transaction.fullName.trim().isNotEmpty
        ? transaction.fullName.trim()
        : '—';
    final resolvedProject = projectName.trim().isNotEmpty
        ? projectName.trim()
        : '—';
    final address = (investorAddress ?? '').trim().isNotEmpty
        ? investorAddress!.trim()
        : '—';
    final paymentMethod = transaction.paymentMethod.trim().toLowerCase();
    final isCheque = paymentMethod.contains('cheque') ||
        paymentMethod.contains('check');
    final othersLabel =
        !isCheque && transaction.paymentMethod.trim().isNotEmpty
            ? transaction.paymentMethod.trim()
            : '';
    final day = date != null ? '${date.day}' : '';
    final month = date != null ? _monthName(date.month) : '';
    final yearSuffix = date != null
        ? (date.year % 100).toString().padLeft(2, '0')
        : '';
    final signatureUrl = (projectSignaturePath ?? '').trim();
    final height = _captureWidth / _a5LandscapeRatio;

    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: _captureWidth,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TransactionReceiptDocument(
            ink: _ink,
            muted: _muted,
            line: _line,
            receiptNo: receiptNo,
            dateLabel: dateLabel,
            amountNumeric: amountNumeric,
            amountInWords: amountInWords,
            investorName: investorName,
            projectName: resolvedProject,
            address: address,
            day: day,
            month: month,
            yearSuffix: yearSuffix,
            isCheque: isCheque,
            othersLabel: othersLabel,
            signatureUrl: signatureUrl,
          ),
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
