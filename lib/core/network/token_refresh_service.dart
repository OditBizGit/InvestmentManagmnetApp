import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart'
    show isPublicAuthRequest;
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

/// Result of a refresh-token attempt.
enum TokenRefreshOutcome {
  /// New access + refresh tokens were stored.
  refreshed,

  /// The server rejected the refresh token (expired, revoked, reused) or
  /// there is none: the session is over.
  rejected,

  /// Temporary failure (offline, timeout, 5xx, session changed meanwhile).
  /// The session may still be valid, so the user must not be logged out.
  failed,
}

/// What the Dio interceptor should do after a 401.
class UnauthorizedRecovery {
  const UnauthorizedRecovery._({
    this.response,
    this.error,
    this.sessionEnded = false,
    this.passThrough = false,
  });

  /// Original request replayed successfully.
  final Response<dynamic>? response;

  /// Replay failed with its own (non-recovery) error: surface this one.
  final DioException? error;

  /// Refresh token rejected: run the normal session-expiry (logout) handling.
  final bool sessionEnded;

  /// Surface the original error without logging the user out.
  final bool passThrough;

  /// Not a case this service handles; use the default 401 handling.
  static const notHandled = UnauthorizedRecovery._();

  static const ended = UnauthorizedRecovery._(sessionEnded: true);

  static const keepSession = UnauthorizedRecovery._(passThrough: true);

  factory UnauthorizedRecovery.retried(Response<dynamic> response) =>
      UnauthorizedRecovery._(response: response);

  factory UnauthorizedRecovery.retryFailed(DioException error) =>
      UnauthorizedRecovery._(error: error);
}

/// Refreshes the access token with the stored refresh token.
///
/// Uses its own plain [Dio] (no interceptors) so it can never recurse. All
/// callers share one in-flight refresh: the backend rotates refresh tokens and
/// treats reuse of a rotated token as an attack (it revokes the session), so
/// two parallel refreshes with the same token must never happen.
///
/// Tokens are never logged.
class TokenRefreshService {
  TokenRefreshService({
    required LocalStorage localStorage,
    required String baseUrl,
    Dio? dio,
    DateTime Function()? now,
    this.expiryLeeway = const Duration(seconds: 30),
  })  : _storage = localStorage,
        _now = now ?? DateTime.now,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  final LocalStorage _storage;
  final Dio _dio;
  final DateTime Function() _now;

  /// Refresh when the access token has less than this left.
  final Duration expiryLeeway;

  /// Marks a request that was already replayed after a refresh.
  static const String retriedExtraKey = 'auth_retried';

  Future<TokenRefreshOutcome>? _inFlight;

  /// Refreshes the tokens. Concurrent callers share the same attempt.
  Future<TokenRefreshOutcome> refresh() {
    final running = _inFlight;
    if (running != null) return running;
    final attempt = _performRefresh().whenComplete(() => _inFlight = null);
    _inFlight = attempt;
    return attempt;
  }

  /// Proactive refresh: refreshes only when a refresh token exists and the
  /// access token expires within [expiryLeeway] (or already expired). Tokens
  /// without `exp` (issued before expiry existed) are left alone. Returns
  /// `null` when no refresh was needed.
  Future<TokenRefreshOutcome?> refreshIfExpiring() async {
    final access = _storage.getAuthToken();
    final refresh = _storage.getRefreshToken();
    if (access == null || access.isEmpty) return null;
    if (refresh == null || refresh.isEmpty) return null;
    if (!isAccessTokenExpiring(access)) return null;
    return this.refresh();
  }

  /// True when [token] has an `exp` that is within [expiryLeeway] (or past).
  bool isAccessTokenExpiring(String token) {
    final exp = _expiryOf(token);
    if (exp == null) return false;
    return !exp.isAfter(_now().toUtc().add(expiryLeeway));
  }

  Future<TokenRefreshOutcome> _performRefresh() async {
    final sentRefreshToken = _storage.getRefreshToken();
    if (sentRefreshToken == null || sentRefreshToken.isEmpty) {
      return TokenRefreshOutcome.rejected;
    }

    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': sentRefreshToken},
      );

      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final newAccess = data is Map ? data['token'] : null;
      final newRefresh = data is Map ? data['refreshToken'] : null;
      if (newAccess is! String ||
          newAccess.isEmpty ||
          newRefresh is! String ||
          newRefresh.isEmpty) {
        return TokenRefreshOutcome.failed;
      }

      // The user may have logged out / in while the request was running; do
      // not resurrect or overwrite a different session.
      if (_storage.getRefreshToken() != sentRefreshToken) {
        return TokenRefreshOutcome.failed;
      }

      await _storage.saveTokens(
        authToken: newAccess,
        refreshToken: newRefresh,
      );
      return TokenRefreshOutcome.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        return TokenRefreshOutcome.rejected;
      }
      return TokenRefreshOutcome.failed;
    } catch (_) {
      return TokenRefreshOutcome.failed;
    }
  }

  /// Handles a 401 from an authenticated request: refreshes (if needed) and
  /// replays the request once using [dio].
  Future<UnauthorizedRecovery> recoverFromUnauthorized(
    DioException error,
    Dio dio,
  ) async {
    final options = error.requestOptions;
    if (error.response?.statusCode != 401) {
      return UnauthorizedRecovery.notHandled;
    }
    if (isPublicAuthRequest(options)) return UnauthorizedRecovery.notHandled;
    if (options.extra[retriedExtraKey] == true) {
      return UnauthorizedRecovery.notHandled;
    }

    final current = _storage.getAuthToken();
    if (current == null || current.isEmpty) {
      return UnauthorizedRecovery.notHandled;
    }

    // Another request already refreshed the token while this one was in
    // flight: just replay with the current token (no second refresh).
    final sentWithCurrent =
        options.headers['Authorization'] == 'Bearer $current';
    if (sentWithCurrent) {
      final outcome = await refresh();
      switch (outcome) {
        case TokenRefreshOutcome.rejected:
          return UnauthorizedRecovery.ended;
        case TokenRefreshOutcome.failed:
          return UnauthorizedRecovery.keepSession;
        case TokenRefreshOutcome.refreshed:
          break;
      }
    }

    final fresh = _storage.getAuthToken();
    if (fresh == null || fresh.isEmpty) {
      return UnauthorizedRecovery.notHandled;
    }
    return _replay(options, fresh, dio);
  }

  Future<UnauthorizedRecovery> _replay(
    RequestOptions options,
    String token,
    Dio dio,
  ) async {
    try {
      final data = options.data;
      // Multipart bodies are consumed by the first attempt.
      final body = data is FormData ? data.clone() : data;
      final response = await dio.fetch<dynamic>(
        options.copyWith(
          data: body,
          headers: {...options.headers, 'Authorization': 'Bearer $token'},
          extra: {...options.extra, retriedExtraKey: true},
        ),
      );
      return UnauthorizedRecovery.retried(response);
    } on DioException catch (e) {
      // The replay itself failed (e.g. 4xx/5xx or offline): the refresh
      // worked, so surface the replay's own error and keep the session.
      return UnauthorizedRecovery.retryFailed(e);
    } catch (_) {
      // For example a multipart body that cannot be replayed.
      return UnauthorizedRecovery.keepSession;
    }
  }

  /// Best-effort server-side logout (revokes the session). Never throws and
  /// never blocks the caller for long.
  Future<void> revokeSession(String accessToken) async {
    if (accessToken.isEmpty) return;
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.logout,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      // Ignored on purpose: local logout must always succeed.
    }
  }

  DateTime? _expiryOf(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      final exp = json is Map ? json['exp'] : null;
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }
}
