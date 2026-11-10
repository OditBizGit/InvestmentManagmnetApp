/// Escapes one CSV field.
///
/// Values starting with `=`, `+`, `-`, `@`, tab or CR get a leading single
/// quote so spreadsheet apps do not evaluate them as formulas (CSV injection),
/// then standard quoting is applied.
final RegExp _numeric = RegExp(r'^[+-]?\d+(\.\d+)?$');

String escapeCsvField(Object value) {
  var text = value.toString();
  if (text.isNotEmpty &&
      '=+-@\t\r'.contains(text[0]) &&
      !_numeric.hasMatch(text)) {
    text = "'$text";
  }
  if (text.contains(',') ||
      text.contains('"') ||
      text.contains('\n') ||
      text.contains('\r')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
