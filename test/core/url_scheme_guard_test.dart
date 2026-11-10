import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/utils/url_scheme_guard.dart';

void main() {
  group('isHttpOrHttpsUrl', () {
    test('allows http and https, case-insensitive', () {
      expect(isHttpOrHttpsUrl(Uri.parse('http://a.com/x.pdf')), isTrue);
      expect(isHttpOrHttpsUrl(Uri.parse('https://a.com/x.pdf')), isTrue);
      expect(isHttpOrHttpsUrl(Uri.parse('HTTPS://a.com')), isTrue);
    });

    test('rejects other schemes', () {
      for (final u in [
        'file:///etc/passwd',
        'javascript:alert(1)',
        'intent://x#Intent;end',
        'tel:123',
        'data:text/html,hi',
        'ftp://a.com/f',
      ]) {
        expect(isHttpOrHttpsUrl(Uri.parse(u)), isFalse, reason: u);
      }
    });

    test('rejects null and scheme-less relative values', () {
      expect(isHttpOrHttpsUrl(null), isFalse);
      expect(isHttpOrHttpsUrl(Uri.parse('/docs/a.pdf')), isFalse);
    });
  });
}
