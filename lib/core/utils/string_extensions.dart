extension StringCasingExtension on String {
  String get toTitleCase {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;

    return trimmed.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}
