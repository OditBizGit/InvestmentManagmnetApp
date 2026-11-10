import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/network/session_expiry_handler.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

DioException error401(String path, {String? bearer, int status = 401}) {
  final options = RequestOptions(
    path: path,
    headers: {if (bearer != null) 'Authorization': 'Bearer $bearer'},
  );
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  late LocalStorage storage;
  var logouts = 0;
  Completer<void>? gate;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.init(secureStorage: FakeSecureStorage());
    await storage.saveSession(authToken: 'current');
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<LocalStorage>(storage);
    logouts = 0;
    gate = null;
    SessionExpiryHandler.sessionEndedOverride = () async {
      logouts++;
      await gate?.future;
    };
  });

  tearDown(() async {
    SessionExpiryHandler.sessionEndedOverride = null;
    await GetIt.instance.reset();
  });

  test('401 with the current token logs out once', () async {
    await SessionExpiryHandler.handleDioError(
      error401('/api/Investors', bearer: 'current'),
    );
    expect(logouts, 1);
  });

  test('concurrent 401s trigger a single logout', () async {
    gate = Completer<void>();
    final futures = [
      for (var i = 0; i < 3; i++)
        SessionExpiryHandler.handleDioError(
          error401('/api/Investors', bearer: 'current'),
        ),
    ];
    gate!.complete();
    await Future.wait(futures);
    expect(logouts, 1);

    // After finishing, a later expiry can log out again.
    await SessionExpiryHandler.handleDioError(
      error401('/api/Investors', bearer: 'current'),
    );
    expect(logouts, 2);
  });

  test('401 on the login request does not log out', () async {
    await SessionExpiryHandler.handleDioError(
      error401(ApiEndpoints.login, bearer: 'current'),
    );
    expect(logouts, 0);
  });

  test('401 carrying a stale token does not log out', () async {
    await SessionExpiryHandler.handleDioError(
      error401('/api/Investors', bearer: 'old'),
    );
    expect(logouts, 0);
  });

  test('401 without Authorization header does not log out', () async {
    await SessionExpiryHandler.handleDioError(error401('/api/Investors'));
    expect(logouts, 0);
  });

  test('non-401 errors do not log out', () async {
    await SessionExpiryHandler.handleDioError(
      error401('/api/Investors', bearer: 'current', status: 500),
    );
    expect(logouts, 0);
  });

  test('401 when already logged out does not log out', () async {
    await storage.clearSession();
    await SessionExpiryHandler.handleDioError(
      error401('/api/Investors', bearer: 'current'),
    );
    expect(logouts, 0);
  });
}
