import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  late FakeSecureStorage secure;

  Future<LocalStorage> open([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    return LocalStorage.init(secureStorage: secure);
  }

  setUp(() => secure = FakeSecureStorage());

  test('token is written to secure storage and never to prefs', () async {
    final storage = await open();
    await storage.setAuthToken('abc');
    await storage.setRefreshToken('ref');

    expect(storage.getAuthToken(), 'abc');
    expect(secure.store['auth_token'], 'abc');
    expect(secure.store['refresh_token'], 'ref');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_token'), isFalse);
    expect(prefs.containsKey('refresh_token'), isFalse);
  });

  test('legacy prefs token is migrated to secure storage and deleted', () async {
    final storage = await open({
      'auth_token': 'legacy',
      'refresh_token': 'legacy-ref',
    });

    expect(storage.getAuthToken(), 'legacy');
    expect(storage.getRefreshToken(), 'legacy-ref');
    expect(secure.store['auth_token'], 'legacy');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_token'), isFalse);
    expect(prefs.containsKey('refresh_token'), isFalse);
  });

  test('existing secure token wins over legacy prefs token', () async {
    secure = FakeSecureStorage({'auth_token': 'secure'});
    final storage = await open({'auth_token': 'legacy'});

    expect(storage.getAuthToken(), 'secure');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_token'), isFalse);
  });

  test('clearSession clears memory, secure storage and prefs', () async {
    final storage = await open({'auth_token': 'legacy'});
    await storage.saveSession(authToken: 'abc', refreshToken: 'ref');
    await storage.clearSession();

    expect(storage.getAuthToken(), isNull);
    expect(storage.getRefreshToken(), isNull);
    expect(secure.store, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_token'), isFalse);
    expect(prefs.getBool('is_logged_in'), isNull);
  });

  test('secure write failure keeps token in memory and does not throw',
      () async {
    final storage = await open();
    secure.failWrites = true;

    await expectLater(storage.setAuthToken('abc'), completes);
    expect(storage.getAuthToken(), 'abc');
    expect(secure.store, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_token'), isFalse);
  });
}
