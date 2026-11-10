import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/network/token_refresh_service.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// Builds an unsigned JWT-shaped string with the given `exp` (seconds).
String jwtWithExp(int? exp) {
  String enc(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${enc({'alg': 'none'})}.${enc({'exp': ?exp})}.sig';
}

int secondsFromNow(DateTime now, int seconds) =>
    now.add(Duration(seconds: seconds)).millisecondsSinceEpoch ~/ 1000;

typedef Handler = Future<ResponseBody> Function(RequestOptions options);

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Handler handler;
  final List<RequestOptions> requests = [];

  int count(String path) => requests.where((r) => r.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody refreshOk(String access, String refresh) => jsonBody(200, {
      'status': true,
      'message': 'Token refreshed successfully.',
      'data': {'token': access, 'refreshToken': refresh},
      'code': 200,
    });

DioException unauthorized(String path, {required String bearer}) {
  final options = RequestOptions(
    path: path,
    headers: {'Authorization': 'Bearer $bearer'},
  );
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 401),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);
  late LocalStorage storage;

  Dio dioWith(FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    return dio;
  }

  TokenRefreshService serviceWith(FakeAdapter adapter) => TokenRefreshService(
        localStorage: storage,
        baseUrl: 'http://test.local',
        dio: dioWith(adapter),
        now: () => now,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.init(secureStorage: FakeSecureStorage());
    await storage.saveSession(
      authToken: 'old-access',
      refreshToken: 'old-refresh',
      userId: '7',
    );
  });

  group('refresh', () {
    test('stores new tokens and keeps the rest of the session', () async {
      final adapter =
          FakeAdapter((_) async => refreshOk('new-access', 'new-refresh'));
      final outcome = await serviceWith(adapter).refresh();

      expect(outcome, TokenRefreshOutcome.refreshed);
      expect(storage.getAuthToken(), 'new-access');
      expect(storage.getRefreshToken(), 'new-refresh');
      expect(storage.getUserId(), '7');
      expect(storage.hasValidSession(), isTrue);
      expect(adapter.requests.single.data, {'refreshToken': 'old-refresh'});
    });

    test('concurrent refreshes share a single request', () async {
      final gate = Completer<void>();
      final adapter = FakeAdapter((_) async {
        await gate.future;
        return refreshOk('new-access', 'new-refresh');
      });
      final service = serviceWith(adapter);

      final futures = [for (var i = 0; i < 5; i++) service.refresh()];
      gate.complete();
      final outcomes = await Future.wait(futures);

      expect(outcomes, everyElement(TokenRefreshOutcome.refreshed));
      expect(adapter.count(ApiEndpoints.refreshToken), 1);
    });

    test('a later refresh after completion makes a new request', () async {
      final adapter =
          FakeAdapter((_) async => refreshOk('new-access', 'new-refresh'));
      final service = serviceWith(adapter);
      await service.refresh();
      await service.refresh();
      expect(adapter.count(ApiEndpoints.refreshToken), 2);
    });

    test('401 / 403 / 400 are rejected and tokens are untouched', () async {
      for (final status in [400, 401, 403]) {
        final adapter = FakeAdapter(
          (_) async => jsonBody(status, {'status': false, 'code': status}),
        );
        final outcome = await serviceWith(adapter).refresh();
        expect(outcome, TokenRefreshOutcome.rejected, reason: '$status');
        expect(storage.getAuthToken(), 'old-access');
        expect(storage.getRefreshToken(), 'old-refresh');
      }
    });

    test('server error, bad payload and offline are failed (not rejected)',
        () async {
      final cases = <Handler>[
        (_) async => jsonBody(500, {'status': false}),
        (_) async => jsonBody(200, {'status': true, 'data': {}}),
        (o) async => throw DioException(
              requestOptions: o,
              type: DioExceptionType.connectionError,
            ),
      ];
      for (final handler in cases) {
        final outcome = await serviceWith(FakeAdapter(handler)).refresh();
        expect(outcome, TokenRefreshOutcome.failed);
        expect(storage.getAuthToken(), 'old-access');
      }
    });

    test('no refresh token is rejected without a request', () async {
      await storage.saveSession(authToken: 'only-access');
      final adapter = FakeAdapter((_) async => refreshOk('a', 'b'));
      final outcome = await serviceWith(adapter).refresh();
      expect(outcome, TokenRefreshOutcome.rejected);
      expect(adapter.requests, isEmpty);
    });

    test('does not overwrite a session that changed during the request',
        () async {
      final gate = Completer<void>();
      final adapter = FakeAdapter((_) async {
        await gate.future;
        return refreshOk('new-access', 'new-refresh');
      });
      final pending = serviceWith(adapter).refresh();

      await storage.clearSession(); // user logged out meanwhile
      gate.complete();

      expect(await pending, TokenRefreshOutcome.failed);
      expect(storage.getAuthToken(), isNull);
      expect(storage.getRefreshToken(), isNull);
    });
  });

  group('proactive refresh', () {
    test('refreshes when the access token expires within the leeway',
        () async {
      await storage.saveTokens(
        authToken: jwtWithExp(secondsFromNow(now, 10)),
        refreshToken: 'old-refresh',
      );
      final adapter =
          FakeAdapter((_) async => refreshOk('new-access', 'new-refresh'));

      final outcome = await serviceWith(adapter).refreshIfExpiring();
      expect(outcome, TokenRefreshOutcome.refreshed);
      expect(storage.getAuthToken(), 'new-access');
    });

    test('refreshes an already expired token', () async {
      await storage.saveTokens(
        authToken: jwtWithExp(secondsFromNow(now, -60)),
        refreshToken: 'old-refresh',
      );
      final adapter =
          FakeAdapter((_) async => refreshOk('new-access', 'new-refresh'));
      expect(
        await serviceWith(adapter).refreshIfExpiring(),
        TokenRefreshOutcome.refreshed,
      );
    });

    test('does nothing for a token with plenty of lifetime left', () async {
      await storage.saveTokens(
        authToken: jwtWithExp(secondsFromNow(now, 600)),
        refreshToken: 'old-refresh',
      );
      final adapter = FakeAdapter((_) async => refreshOk('a', 'b'));
      expect(await serviceWith(adapter).refreshIfExpiring(), isNull);
      expect(adapter.requests, isEmpty);
    });

    test('ignores tokens without exp or that are not JWTs', () async {
      final adapter = FakeAdapter((_) async => refreshOk('a', 'b'));
      final service = serviceWith(adapter);

      await storage.saveTokens(
        authToken: jwtWithExp(null),
        refreshToken: 'old-refresh',
      );
      expect(await service.refreshIfExpiring(), isNull);

      await storage.saveTokens(
        authToken: 'not-a-jwt',
        refreshToken: 'old-refresh',
      );
      expect(await service.refreshIfExpiring(), isNull);
      expect(adapter.requests, isEmpty);
    });

    test('does nothing without a refresh token', () async {
      await storage.saveSession(authToken: jwtWithExp(secondsFromNow(now, 1)));
      final adapter = FakeAdapter((_) async => refreshOk('a', 'b'));
      expect(await serviceWith(adapter).refreshIfExpiring(), isNull);
      expect(adapter.requests, isEmpty);
    });
  });

  group('recoverFromUnauthorized', () {
    FakeAdapter adapterFor({
      ResponseBody Function()? onRefresh,
      int apiStatus = 200,
      Completer<void>? gate,
    }) {
      return FakeAdapter((options) async {
        if (options.path == ApiEndpoints.refreshToken) {
          await gate?.future;
          return (onRefresh ?? () => refreshOk('new-access', 'new-refresh'))();
        }
        return jsonBody(apiStatus, {'status': apiStatus == 200});
      });
    }

    test('refreshes then replays once with the new token', () async {
      final adapter = adapterFor();
      final service = serviceWith(adapter);
      final recovery = await service.recoverFromUnauthorized(
        unauthorized('/api/Investors', bearer: 'old-access'),
        dioWith(adapter),
      );

      expect(recovery.response?.statusCode, 200);
      final replay = adapter.requests.last;
      expect(replay.path, '/api/Investors');
      expect(replay.headers['Authorization'], 'Bearer new-access');
      expect(replay.extra[TokenRefreshService.retriedExtraKey], true);
      expect(adapter.count(ApiEndpoints.refreshToken), 1);
    });

    test('concurrent 401s trigger a single refresh and all replay', () async {
      final gate = Completer<void>();
      final adapter = adapterFor(gate: gate);
      final service = serviceWith(adapter);
      final dio = dioWith(adapter);

      final futures = [
        for (var i = 0; i < 4; i++)
          service.recoverFromUnauthorized(
            unauthorized('/api/Investors', bearer: 'old-access'),
            dio,
          ),
      ];
      gate.complete();
      final results = await Future.wait(futures);

      expect(results.every((r) => r.response?.statusCode == 200), isTrue);
      expect(adapter.count(ApiEndpoints.refreshToken), 1);
      expect(adapter.count('/api/Investors'), 4);
    });

    test('stale-token 401 replays with the current token, no refresh',
        () async {
      await storage.saveTokens(
        authToken: 'already-refreshed',
        refreshToken: 'newer-refresh',
      );
      final adapter = adapterFor();
      final recovery = await serviceWith(adapter).recoverFromUnauthorized(
        unauthorized('/api/Investors', bearer: 'old-access'),
        dioWith(adapter),
      );

      expect(recovery.response?.statusCode, 200);
      expect(adapter.count(ApiEndpoints.refreshToken), 0);
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer already-refreshed',
      );
    });

    test('rejected refresh token ends the session (no replay)', () async {
      final adapter = adapterFor(
        onRefresh: () => jsonBody(401, {'status': false, 'code': 401}),
      );
      final recovery = await serviceWith(adapter).recoverFromUnauthorized(
        unauthorized('/api/Investors', bearer: 'old-access'),
        dioWith(adapter),
      );

      expect(recovery.sessionEnded, isTrue);
      expect(recovery.response, isNull);
      expect(adapter.count('/api/Investors'), 0);
    });

    test('temporary refresh failure keeps the session', () async {
      final adapter =
          adapterFor(onRefresh: () => jsonBody(500, {'status': false}));
      final recovery = await serviceWith(adapter).recoverFromUnauthorized(
        unauthorized('/api/Investors', bearer: 'old-access'),
        dioWith(adapter),
      );

      expect(recovery.passThrough, isTrue);
      expect(recovery.sessionEnded, isFalse);
      expect(storage.hasValidSession(), isTrue);
    });

    test('a replayed request that fails surfaces its own error', () async {
      final adapter = adapterFor(apiStatus: 400);
      final recovery = await serviceWith(adapter).recoverFromUnauthorized(
        unauthorized('/api/Investors', bearer: 'old-access'),
        dioWith(adapter),
      );

      expect(recovery.error?.response?.statusCode, 400);
      expect(recovery.sessionEnded, isFalse);
    });

    test('non-401, public and already-retried requests are not handled',
        () async {
      final adapter = adapterFor();
      final service = serviceWith(adapter);
      final dio = dioWith(adapter);

      final notFound = DioException(
        requestOptions: RequestOptions(path: '/api/Investors'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/Investors'),
          statusCode: 404,
        ),
      );
      expect(
        (await service.recoverFromUnauthorized(notFound, dio)).response,
        isNull,
      );

      final publicCall = unauthorized(ApiEndpoints.login, bearer: 'x');
      final r1 = await service.recoverFromUnauthorized(publicCall, dio);
      expect(r1.sessionEnded || r1.passThrough || r1.response != null, isFalse);

      final retriedOptions = RequestOptions(
        path: '/api/Investors',
        headers: {'Authorization': 'Bearer old-access'},
        extra: {TokenRefreshService.retriedExtraKey: true},
      );
      final retried = DioException(
        requestOptions: retriedOptions,
        response: Response(requestOptions: retriedOptions, statusCode: 401),
      );
      final r2 = await service.recoverFromUnauthorized(retried, dio);
      expect(r2.sessionEnded || r2.passThrough || r2.response != null, isFalse);

      expect(adapter.requests, isEmpty);
    });
  });

  group('revokeSession', () {
    test('sends the given token to the logout endpoint', () async {
      final adapter = FakeAdapter(
        (_) async => jsonBody(200, {'status': true}),
      );
      await serviceWith(adapter).revokeSession('the-access-token');

      final request = adapter.requests.single;
      expect(request.path, ApiEndpoints.logout);
      expect(request.headers['Authorization'], 'Bearer the-access-token');
    });

    test('never throws when the server is unreachable', () async {
      final adapter = FakeAdapter(
        (o) async => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ),
      );
      await serviceWith(adapter).revokeSession('t');
    });

    test('does nothing for an empty token', () async {
      final adapter = FakeAdapter((_) async => jsonBody(200, {}));
      await serviceWith(adapter).revokeSession('');
      expect(adapter.requests, isEmpty);
    });
  });
}
