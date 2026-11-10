import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';

void main() {
  final calls = <String>[];

  setUp(() {
    calls.clear();
    appLogSinkOverride = (message, {name, error, stackTrace}) {
      calls.add('${name ?? ''}|$message|${error ?? ''}');
    };
  });

  tearDown(() {
    appLogSinkOverride = null;
    appLogEnabledOverride = null;
  });

  test('is a no-op outside debug mode', () {
    appLogEnabledOverride = false;
    appLog('hello', name: 'X', error: 'boom');
    expect(calls, isEmpty);
  });

  test('forwards message, name and error in debug mode', () {
    appLogEnabledOverride = true;
    appLog('hello', name: 'X', error: 'boom');
    expect(calls, ['X|hello|boom']);
  });

  test('defaults to enabled under flutter test (kDebugMode)', () {
    appLog('hello');
    expect(calls, hasLength(1));
  });
}
