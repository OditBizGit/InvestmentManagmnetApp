import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/utils/csv_escape.dart';

void main() {
  group('escapeCsvField', () {
    test('leaves plain text unchanged', () {
      expect(escapeCsvField('John Doe'), 'John Doe');
      expect(escapeCsvField(1500), '1500');
    });

    test('prefixes formula triggers with a single quote', () {
      expect(escapeCsvField('=SUM(A1)'), "'=SUM(A1)");
      expect(escapeCsvField('-1+2'), "'-1+2");
      expect(escapeCsvField('+cmd'), "'+cmd");
      expect(escapeCsvField('-x'), "'-x");
      expect(escapeCsvField('@cmd'), "'@cmd");
      expect(escapeCsvField('\tx'), "'\tx");
    });

    test('does not prefix purely numeric values', () {
      expect(escapeCsvField('-500'), '-500');
      expect(escapeCsvField('-12.5'), '-12.5');
      expect(escapeCsvField(-500), '-500');
      expect(escapeCsvField('+1'), '+1');
    });

    test('prefixes then quotes values with commas', () {
      expect(escapeCsvField('=A1,B1'), '"\'=A1,B1"');
    });

    test('quotes commas, quotes and newlines', () {
      expect(escapeCsvField('a,b'), '"a,b"');
      expect(escapeCsvField('say "hi"'), '"say ""hi"""');
      expect(escapeCsvField('a\nb'), '"a\nb"');
    });

    test('carriage return start is prefixed and quoted', () {
      expect(escapeCsvField('\rx'), '"\'\rx"');
    });
  });
}
