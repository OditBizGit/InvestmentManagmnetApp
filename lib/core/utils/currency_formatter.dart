/// Indian currency grouping: last 3 digits, then pairs (e.g. ₹3,00,000).
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

  static String format(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final isWhole = absAmount == absAmount.roundToDouble();
    final raw = isWhole
        ? absAmount.toStringAsFixed(0)
        : absAmount.toStringAsFixed(2);
    final parts = raw.split('.');
    final grouped = indianGrouping(parts.first);
    final decimals = parts.length > 1 ? '.${parts[1]}' : '';
    final sign = isNegative ? '-' : '';
    return '$sign$symbol$grouped$decimals';
  }

  /// Groups digits as 3,00,000 (last 3, then pairs).
  static String indianGrouping(String digits) {
    if (digits.length <= 3) return digits;
    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final withCommas = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$withCommas,$lastThree';
  }

  /// Indian English words, e.g. `300000` → `Three Lakh Rupees Only`.
  static String amountInWords(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
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
