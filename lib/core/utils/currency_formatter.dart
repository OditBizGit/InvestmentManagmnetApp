/// Indian currency grouping: last 3 digits, then pairs (e.g. ₹1,90,000.01).
class CurrencyFormatter {
  CurrencyFormatter._();

  static const _ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  /// Formats [amount] as INR with Indian grouping and exactly two decimals.
  ///
  /// Examples: `1000` → `₹1,000.00`, `190000.01` → `₹1,90,000.01`.
  /// NaN and infinite values are treated as `0`.
  static String format(double amount, {String symbol = '₹'}) {
    final value = _safeAmount(amount);
    final isNegative = value < 0;
    final absAmount = value.abs();
    final raw = absAmount.toStringAsFixed(2);
    final parts = raw.split('.');
    final grouped = indianGrouping(parts.first);
    final sign = isNegative ? '-' : '';
    return '$sign$symbol$grouped.${parts[1]}';
  }

  /// Same as [format], treating `null` as `0`.
  static String formatNullable(num? amount, {String symbol = '₹'}) {
    return format((amount ?? 0).toDouble(), symbol: symbol);
  }

  /// Groups digits as 3,00,000 (last 3, then pairs).
  static String indianGrouping(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return '0';
    if (cleaned.length <= 3) return cleaned;
    final lastThree = cleaned.substring(cleaned.length - 3);
    final rest = cleaned.substring(0, cleaned.length - 3);
    final withCommas = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$withCommas,$lastThree';
  }

  /// Indian English words, e.g. `300000` → `Three Lakh Rupees Only`.
  static String amountInWords(double amount) {
    final value = _safeAmount(amount);
    final isNegative = value < 0;
    final absAmount = value.abs();
    final rupees = absAmount.floor();
    final paise = ((absAmount - rupees) * 100).round();

    final rupeeWords = _convertIndian(rupees);
    final buffer = StringBuffer();
    if (isNegative) buffer.write('Minus ');

    if (rupees == 0 && paise == 0) {
      return 'Zero Rupees Only';
    }

    if (rupees > 0) {
      buffer.write(rupeeWords);
      buffer.write(rupees == 1 ? ' Rupee' : ' Rupees');
    }

    if (paise > 0) {
      if (rupees > 0) buffer.write(' and ');
      buffer.write(_convertBelowThousand(paise));
      buffer.write(paise == 1 ? ' Paisa' : ' Paise');
    }

    buffer.write(' Only');
    return buffer.toString();
  }

  static double _safeAmount(double amount) {
    if (amount.isNaN || amount.isInfinite) return 0;
    return amount;
  }

  static String _convertIndian(int number) {
    if (number == 0) return 'Zero';

    final crore = number ~/ 10000000;
    number %= 10000000;
    final lakh = number ~/ 100000;
    number %= 100000;
    final thousand = number ~/ 1000;
    number %= 1000;

    final parts = <String>[];
    if (crore > 0) {
      parts.add('${_convertBelowThousand(crore)} Crore');
    }
    if (lakh > 0) {
      parts.add('${_convertBelowThousand(lakh)} Lakh');
    }
    if (thousand > 0) {
      parts.add('${_convertBelowThousand(thousand)} Thousand');
    }
    if (number > 0) {
      parts.add(_convertBelowThousand(number));
    }
    return parts.join(' ');
  }

  static String _convertBelowThousand(int number) {
    if (number == 0) return '';
    if (number < 20) return _ones[number];
    if (number < 100) {
      final ten = number ~/ 10;
      final one = number % 10;
      return one == 0 ? _tens[ten] : '${_tens[ten]} ${_ones[one]}';
    }
    final hundred = number ~/ 100;
    final rest = number % 100;
    if (rest == 0) return '${_ones[hundred]} Hundred';
    return '${_ones[hundred]} Hundred ${_convertBelowThousand(rest)}';
  }
}
