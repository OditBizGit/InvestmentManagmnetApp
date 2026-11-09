import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:maribel_wellness_centre_application/user/investments/investments_screen.dart';
import 'package:maribel_wellness_centre_application/user/investments/model/investor_transaction_item_model.dart';
import 'package:maribel_wellness_centre_application/user/investments/utils/transaction_receipt_pdf.dart';
import 'package:sizer/sizer.dart';

class TransactionReceiptScreen extends StatefulWidget {
  const TransactionReceiptScreen({
    super.key,
    required this.projectName,
    required this.transaction,
    this.investorAddress,
    this.projectSignaturePath,
  });

  final String projectName;
  final InvestorTransactionItemModel transaction;
  final String? investorAddress;
  final String? projectSignaturePath;

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF4A4A4A);
  static const Color _line = Color(0xFF9A9A9A);
  static const Color _cardBorder = Color(0xFFE0E0E0);

  /// A5 landscape aspect ratio (210mm × 148mm).
  static const double _a5LandscapeRatio = 210 / 148;

  final GlobalKey _receiptBoundaryKey = GlobalKey();

  bool _isDownloading = false;
  bool _isSharing = false;

  bool get _isBusy => _isDownloading || _isSharing;

  EdgeInsets get _snackBarMargin => EdgeInsets.fromLTRB(5.w, 0, 5.w, 9.h);

  void _showSnackBar(String message, {IconData? icon}) {
    AppSnackBar.show(
      context,
      message: message,
      icon: icon,
      margin: _snackBarMargin,
    );
  }

  /// Captures the on-screen receipt widget so PDF/share match the UI exactly.
  Future<Uint8List> _captureReceiptPng() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;

    final boundary = _receiptBoundaryKey.currentContext?.findRenderObject()
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
  }

  Future<void> _shareReceipt() async {
    if (_isBusy) return;

    setState(() => _isSharing = true);
    try {
      final pngBytes = await _captureReceiptPng();
      await TransactionReceiptPdf.share(
        receiptPngBytes: pngBytes,
        transaction: widget.transaction,
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Could not share receipt. Please try again.',
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadReceipt() async {
    if (_isBusy) return;

    setState(() => _isDownloading = true);
    try {
      final pngBytes = await _captureReceiptPng();
      await TransactionReceiptPdf.download(
        receiptPngBytes: pngBytes,
        transaction: widget.transaction,
      );
      if (!mounted) return;
      _showSnackBar(
        'Receipt downloaded',
        icon: Icons.download_done_rounded,
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Could not download receipt. Please try again.',
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
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
    final projectName = widget.projectName.trim().isNotEmpty
        ? widget.projectName.trim()
        : '—';
    final address = (widget.investorAddress ?? '').trim().isNotEmpty
        ? widget.investorAddress!.trim()
        : '—';
    final paymentMethod = transaction.paymentMethod.trim().toLowerCase();
    final isCheque = paymentMethod.contains('cheque') ||
        paymentMethod.contains('check');
    final othersLabel = !isCheque && transaction.paymentMethod.trim().isNotEmpty
        ? transaction.paymentMethod.trim()
        : '';
    final day = date != null ? '${date.day}' : '';
    final month = date != null ? _monthName(date.month) : '';
    final yearSuffix = date != null
        ? (date.year % 100).toString().padLeft(2, '0')
        : '';
    final signatureUrl = (widget.projectSignaturePath ?? '').trim();

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 5.5.w,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Payment Receipt',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPad = 3.w;
                  final availableWidth =
                      constraints.maxWidth - (horizontalPad * 2);
                  const preferredWidth = 640.0;
                  final receiptWidth = availableWidth < preferredWidth
                      ? preferredWidth
                      : availableWidth;
                  final receiptHeight = receiptWidth / _a5LandscapeRatio;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0.5.h,
                      horizontalPad,
                      2.h,
                    ),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: RepaintBoundary(
                        key: _receiptBoundaryKey,
                        child: Container(
                          width: receiptWidth,
                          height: receiptHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
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
                              projectName: projectName,
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
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 6.h,
                      child: OutlinedButton(
                        onPressed: _isBusy ? null : _shareReceipt,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentDark,
                          disabledForegroundColor:
                              AppColors.accentDark.withValues(alpha: 0.5),
                          side: BorderSide(
                            color: _isBusy
                                ? AppColors.accentDark.withValues(alpha: 0.4)
                                : AppColors.accentDark,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSharing
                            ? SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.accentDark,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    ImageConstants.share,
                                    width: 4.5.w,
                                    height: 4.5.w,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.accentDark,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Share',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: SizedBox(
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _isBusy ? null : _downloadReceipt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.accentDark.withValues(alpha: 0.7),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isDownloading
                            ? SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    ImageConstants.download,
                                    width: 4.5.w,
                                    height: 4.5.w,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Download',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

/// On-screen / PDF receipt layout shared with admin receipt downloads.
class TransactionReceiptDocument extends StatelessWidget {
  const TransactionReceiptDocument({
    required this.ink,
    required this.muted,
    required this.line,
    required this.receiptNo,
    required this.dateLabel,
    required this.amountNumeric,
    required this.amountInWords,
    required this.investorName,
    required this.projectName,
    required this.address,
    required this.day,
    required this.month,
    required this.yearSuffix,
    required this.isCheque,
    required this.othersLabel,
    required this.signatureUrl,
  });

  final Color ink;
  final Color muted;
  final Color line;
  final String receiptNo;
  final String dateLabel;
  final String amountNumeric;
  final String amountInWords;
  final String investorName;
  final String projectName;
  final String address;
  final String day;
  final String month;
  final String yearSuffix;
  final bool isCheque;
  final String othersLabel;
  final String signatureUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final scale = (w / 640).clamp(0.72, 1.15);
        final padH = 25.0 * scale;
        final padV = 25.0 * scale;
        final titleSize = 13.5 * scale;
        final bodySize = 8.2 * scale;
        final smallSize = 7.5 * scale;
        final companySize = 8.0 * scale;

        return Padding(
          padding: EdgeInsets.fromLTRB(padH, 20, padH, padV * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                ink: ink,
                muted: muted,
                companySize: companySize,
                smallSize: smallSize,
                logoHeight: 50 * scale,
              ),
              SizedBox(height: 16 * scale),
              Text(
                'PROVISIONAL PROJECT CONTRIBUTION RECEIPT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: ink,
                ),
              ),
              SizedBox(height: 20 * scale),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.2),
                    child: Text(
                      'Receipt No : ',
                      style: _receiptBodyStyle(bodySize, ink),
                    ),
                  ),
                  SizedBox(
                    width: w * 0.1,
                    child: _DottedValue(
                      value: receiptNo,
                      fontSize: bodySize,
                      color: ink,
                      lineColor: line,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.2),
                    child: Text(
                      'Date : ',
                      style: _receiptBodyStyle(bodySize, ink),
                    ),
                  ),
                  SizedBox(
                    width: w * 0.15,
                    child: _DottedValue(
                      value: dateLabel,
                      fontSize: bodySize,
                      color: ink,
                      lineColor: line,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * scale),
              _AmountInWordsLines(
                amountInWords: amountInWords,
                projectName: projectName,
                fontSize: bodySize,
                color: ink,
                lineColor: line,
                scale: scale,
              ),
              SizedBox(height: 8 * scale),
              _FillLine(
                leading: 'Project of the LLP from Mr./Ms./ M/S ',
                value: investorName,
                fontSize: bodySize,
                color: ink,
                lineColor: line,
              ),
              SizedBox(height: 8 * scale),
              _DottedValue(
                value: '',
                fontSize: bodySize,
                color: ink,
                lineColor: line,
              ),
              SizedBox(height: 8 * scale),
              _FillLine(
                leading: 'Residing at/ having registered office at ',
                value: address,
                fontSize: bodySize,
                color: ink,
                lineColor: line,
              ),
              SizedBox(height: 8 * scale),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _DottedValue(
                      value: '',
                      fontSize: bodySize,
                      color: ink,
                      lineColor: line,
                      leadingGap: 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.2, left: 4),
                    child: Text(
                      'On',
                      style: _receiptBodyStyle(bodySize, ink),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 40 * scale,
                    child: _DottedValue(
                      value: day,
                      fontSize: bodySize,
                      color: ink,
                      lineColor: line,
                      textAlign: TextAlign.center,
                      leadingGap: 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.2),
                    child: Text(
                      ' Day of ',
                      style: _receiptBodyStyle(bodySize, ink),
                    ),
                  ),
                  SizedBox(
                    width: 100 * scale,
                    child: _DottedValue(
                      value: month,
                      fontSize: bodySize,
                      color: ink,
                      lineColor: line,
                      textAlign: TextAlign.center,
                      leadingGap: 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.2),
                    child: Text(
                      ' Month of 20',
                      style: _receiptBodyStyle(bodySize, ink),
                    ),
                  ),
                  SizedBox(
                    width: 32 * scale,
                    child: _DottedValue(
                      value: yearSuffix,
                      fontSize: bodySize,
                      color: ink,
                      lineColor: line,
                      textAlign: TextAlign.center,
                      leadingGap: 0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PaymentMethodBox(
                    label: 'Cheque',
                    value: isCheque ? 'Cheque' : '',
                    fontSize: bodySize,
                    color: ink,
                    scale: scale,
                    boxWidth: 108,
                  ),
                  SizedBox(width: 14 * scale),
                  _PaymentMethodBox(
                    label: 'Others',
                    value: !isCheque ? othersLabel : '',
                    fontSize: bodySize,
                    color: ink,
                    scale: scale,
                    boxWidth: 118,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 150 * scale,
                    child: Text(
                      'for MARIBEL MATERNITY\nCARE MANJERI LLP',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: smallSize,
                        fontWeight: FontWeight.w600,
                        color: ink,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * scale),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 148 * scale,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 5 * scale,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: ink, width: 1.1),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '₹',
                          style: TextStyle(
                            fontSize: bodySize + 1,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16 * scale,
                          margin: EdgeInsets.symmetric(horizontal: 6 * scale),
                          color: ink,
                        ),
                        Expanded(
                          child: Text(
                            amountNumeric,
                            style: TextStyle(
                              fontSize: bodySize,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 48 * scale,
                        width: 180 * scale,
                        child: signatureUrl.isNotEmpty
                            ? Image.network(
                                signatureUrl,
                                fit: BoxFit.contain,
                                alignment: Alignment.centerRight,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 10 * scale),
                      Text(
                        'Authorized Signature',
                        style: TextStyle(
                          fontSize: smallSize,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.ink,
    required this.muted,
    required this.companySize,
    required this.smallSize,
    required this.logoHeight,
  });

  final Color ink;
  final Color muted;
  final double companySize;
  final double smallSize;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MARIBEL MATERNITY CARE MANJERI LLP',
                style: TextStyle(
                  fontSize: companySize,
                  fontWeight: FontWeight.w700,
                  color: ink,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Thar Plaza Building, Pandikkad Rd Bypass,\n'
                'Kovilakam Kundu, Manjeri, Kerala 676121',
                style: TextStyle(
                  fontSize: smallSize,
                  fontWeight: FontWeight.w400,
                  color: muted,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tel : +91 789 100 8002',
                style: TextStyle(
                  fontSize: smallSize,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        SvgPicture.asset(
          ImageConstants.Meribel,
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

TextStyle _receiptBodyStyle(double fontSize, Color color) {
  return TextStyle(
    fontFamily: 'Montserrat',
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.25,
  );
}

double _measureTextWidth(
  String text,
  TextStyle style, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  if (text.isEmpty) return 0;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();
  return painter.width;
}


List<String> _splitTextAcrossWidths(
  String text,
  TextStyle style,
  List<double> maxWidths, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  if (text.isEmpty || maxWidths.isEmpty) {
    return text.isEmpty ? const [] : [text];
  }

  final lines = <String>[];
  var remaining = text.trim();

  for (var i = 0; i < maxWidths.length; i++) {
    final isLast = i == maxWidths.length - 1;
    if (remaining.isEmpty) {
      lines.add('');
      continue;
    }
    if (isLast) {
      lines.add(remaining);
      remaining = '';
      break;
    }

    final fitted = _fitTextToWidth(
      remaining,
      style,
      maxWidths[i],
      textScaler: textScaler,
    );
    lines.add(fitted.$1);
    remaining = fitted.$2;
  }


  for (var i = 0; i < lines.length - 1; i++) {
    while (lines[i].isNotEmpty &&
        _measureTextWidth(lines[i], style, textScaler: textScaler) >
            maxWidths[i]) {
      final words = lines[i].split(RegExp(r'\s+'));
      if (words.length <= 1) break;
      final moved = words.removeLast();
      lines[i] = words.join(' ');
      lines[i + 1] =
          lines[i + 1].isEmpty ? moved : '$moved ${lines[i + 1]}';
    }
  }

  return lines;
}


(String, String) _fitTextToWidth(
  String text,
  TextStyle style,
  double maxWidth, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty || maxWidth <= 0) return ('', trimmed);

  final painter = TextPainter(
    text: TextSpan(text: trimmed, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout(maxWidth: maxWidth);

  final metrics = painter.computeLineMetrics();
  if (metrics.length <= 1 && painter.width <= maxWidth + 0.5) {
    return (trimmed, '');
  }

  final boundary = painter.getLineBoundary(const TextPosition(offset: 0));
  var end = boundary.end.clamp(0, trimmed.length);
  if (end < trimmed.length && end > 0 && trimmed[end - 1] != ' ') {
    final lastSpace = trimmed.lastIndexOf(' ', end - 1);
    if (lastSpace > 0) {
      end = lastSpace;
    }
  }

  if (end <= 0) {
    return _fitCharsToWidth(
      trimmed,
      style,
      maxWidth,
      textScaler: textScaler,
    );
  }

  final fitted = trimmed.substring(0, end).trimRight();
  final rest = trimmed.substring(end).trimLeft();
  if (fitted.isEmpty) {
    return _fitCharsToWidth(
      trimmed,
      style,
      maxWidth,
      textScaler: textScaler,
    );
  }
  return (fitted, rest);
}

(String, String) _fitCharsToWidth(
  String text,
  TextStyle style,
  double maxWidth, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  if (_measureTextWidth(text, style, textScaler: textScaler) <= maxWidth) {
    return (text, '');
  }

  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    maxLines: 1,
  )..layout(maxWidth: maxWidth);

  final pos = painter.getPositionForOffset(
    Offset(maxWidth, painter.preferredLineHeight / 2),
  );
  var end = pos.offset.clamp(0, text.length);
  if (end <= 0) end = 1.clamp(0, text.length);

  return (text.substring(0, end), text.substring(end).trimLeft());
}


class _AmountInWordsLines extends StatelessWidget {
  const _AmountInWordsLines({
    required this.amountInWords,
    required this.projectName,
    required this.fontSize,
    required this.color,
    required this.lineColor,
    required this.scale,
  });

  final String amountInWords;
  final String projectName;
  final double fontSize;
  final Color color;
  final Color lineColor;
  final double scale;

  static const String _leading =
      'This is to acknowledge the receipt of Rs. ';
  static const String _towardsLabel = 'Towards contribution to';
  static const double _leadingGap = 10.0;
  static const double _towardsLeftPad = 6.0;
  static const double _safetyPad = 18.0;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context)
        .style
        .merge(_receiptBodyStyle(fontSize, color));
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, lineConstraints) {
        final leadingWidth = _measureTextWidth(
          _leading,
          style,
          textScaler: textScaler,
        );
        final firstLineMax = (lineConstraints.maxWidth -
                leadingWidth -
                _leadingGap -
                _safetyPad)
            .clamp(0.0, lineConstraints.maxWidth);

        final towardsWidth = _measureTextWidth(
              _towardsLabel,
              style,
              textScaler: textScaler,
            ) +
            _towardsLeftPad;
        final afterTowardsWidth =
            (lineConstraints.maxWidth - towardsWidth)
                .clamp(0.0, lineConstraints.maxWidth);
        final towardsRowValueMax = (afterTowardsWidth * 5 / 8 -
                _leadingGap -
                _safetyPad)
            .clamp(0.0, afterTowardsWidth);
        final fullWidthMax = (lineConstraints.maxWidth -
                _leadingGap -
                _safetyPad)
            .clamp(0.0, lineConstraints.maxWidth);

        var split = _splitTextAcrossWidths(
          amountInWords,
          style,
          [firstLineMax, towardsRowValueMax],
          textScaler: textScaler,
        );
        final remainder =
            split.length > 1 ? split[1] : '';
        final needsFullWidthLine = remainder.isNotEmpty &&
            _measureTextWidth(
                  remainder,
                  style,
                  textScaler: textScaler,
                ) >
                towardsRowValueMax + 0.5;
        if (needsFullWidthLine) {
          split = _splitTextAcrossWidths(
            amountInWords,
            style,
            [firstLineMax, fullWidthMax, towardsRowValueMax],
            textScaler: textScaler,
          );
        }

        final firstLine = split.isNotEmpty ? split[0] : '';
        final fullWidthLine =
            needsFullWidthLine && split.length > 2 ? split[1] : '';
        final towardsRowLine = needsFullWidthLine
            ? (split.length > 2 ? split[2] : '')
            : (split.length > 1 ? split[1] : '');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FillLine(
              leading: _leading,
              value: firstLine,
              fontSize: fontSize,
              color: color,
              lineColor: lineColor,
              ellipsize: false,
            ),
            if (fullWidthLine.isNotEmpty) ...[
              SizedBox(height: 8 * scale),
              _DottedValue(
                value: fullWidthLine,
                fontSize: fontSize,
                color: color,
                lineColor: lineColor,
                ellipsize: false,
              ),
            ],
            SizedBox(height: 8 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 5,
                  child: _DottedValue(
                    value: towardsRowLine,
                    fontSize: fontSize,
                    color: color,
                    lineColor: lineColor,
                    leadingGap: towardsRowLine.isEmpty ? 0 : _leadingGap,
                    ellipsize: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 2.2,
                    left: _towardsLeftPad,
                  ),
                  child: Text(
                    _towardsLabel,
                    style: style,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _DottedValue(
                    value: projectName.toUpperCase(),
                    fontSize: fontSize,
                    color: color,
                    lineColor: lineColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DottedValue extends StatelessWidget {
  const _DottedValue({
    required this.value,
    required this.fontSize,
    required this.color,
    required this.lineColor,
    this.textAlign = TextAlign.left,
    this.leadingGap = 10,
    this.ellipsize = true,
  });

  final String value;
  final double fontSize;
  final Color color;
  final Color lineColor;
  final TextAlign textAlign;
  final double leadingGap;
  final bool ellipsize;

  @override
  Widget build(BuildContext context) {
    final style = _receiptBodyStyle(fontSize, color);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: value.isEmpty ? 0 : leadingGap),
          child: Text(
            value.isEmpty ? ' ' : value,
            textAlign: textAlign,
            maxLines: 1,
            softWrap: false,
            overflow:
                ellipsize ? TextOverflow.ellipsis : TextOverflow.clip,
            style: style,
          ),
        ),
        const SizedBox(height: 1),
        SizedBox(
          height: 1.2,
          width: double.infinity,
          child: CustomPaint(
            painter: _DottedLinePainter(color: lineColor),
          ),
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({
    required this.color,
    this.dashWidth = 2.5,
    this.dashSpace = 2.0,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

class _FillLine extends StatelessWidget {
  const _FillLine({
    required this.leading,
    required this.value,
    required this.fontSize,
    required this.color,
    required this.lineColor,
    this.ellipsize = true,
  });

  final String leading;
  final String value;
  final double fontSize;
  final Color color;
  final Color lineColor;
  final bool ellipsize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.2),
          child: Text(
            leading,
            style: _receiptBodyStyle(fontSize, color),
          ),
        ),
        Expanded(
          child: _DottedValue(
            value: value,
            fontSize: fontSize,
            color: color,
            lineColor: lineColor,
            ellipsize: ellipsize,
          ),
        ),
      ],
    );
  }
}

class _FillSegment {
  const _FillSegment({
    this.text,
    this.value,
    this.flex = 0,
    this.isLabel = false,
  });

  final String? text;
  final String? value;
  final int flex;
  final bool isLabel;
}

class _WrappedFillRow extends StatelessWidget {
  const _WrappedFillRow({
    required this.children,
    required this.fontSize,
    required this.color,
    required this.lineColor,
  });

  final List<_FillSegment> children;
  final double fontSize;
  final Color color;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final segment in children)
          if (segment.isLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.2),
              child: Text(
                segment.text ?? '',
                style: _receiptBodyStyle(fontSize, color),
              ),
            )
          else
            Expanded(
              flex: segment.flex <= 0 ? 1 : segment.flex,
              child: _DottedValue(
                value: segment.value ?? '',
                fontSize: fontSize,
                color: color,
                lineColor: lineColor,
              ),
            ),
      ],
    );
  }
}

class _PaymentMethodBox extends StatelessWidget {
  const _PaymentMethodBox({
    required this.label,
    required this.value,
    required this.fontSize,
    required this.color,
    required this.scale,
    required this.boxWidth,
  });

  final String label;
  final String value;
  final double fontSize;
  final Color color;
  final double scale;
  final double boxWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: _receiptBodyStyle(fontSize, color),
        ),
        SizedBox(width: 8 * scale),
        CustomPaint(
          painter: _DashedRectPainter(color: color.withValues(alpha: 0.85)),
          child: SizedBox(
            width: boxWidth * scale,
            height: 26 * scale,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * scale),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _receiptBodyStyle(fontSize * 0.95, color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    const dash = 4.0;
    const gap = 3.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          const Radius.circular(1),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
