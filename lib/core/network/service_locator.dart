import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// API base URL used by network clients / repositories.
const String kBaseUrl = 'https://api.maribelwellness.com/v1/';

/// Registers core dependencies used by Flutter BLoC layers.
///
/// Call once from [main] before [runApp].
Future<void> setupDi() async {
  // ── Core ──────────────────────────────────────────────────────────
  final localStorage = await LocalStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);

  // Named base URL for repositories / API clients resolved via GetIt.
  getIt.registerLazySingleton<String>(
    () => kBaseUrl,
    instanceName: 'baseUrl',
  );

  // ── Network ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = getIt<LocalStorage>().getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint(
              '→ ${options.method} ${options.uri}\n'
              '  headers: ${options.headers}\n'
              '  data: ${options.data}',
            );
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '← ${response.statusCode} ${response.requestOptions.uri}\n'
              '  data: ${response.data}',
            );
          }

          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint(
              '✖ ${error.response?.statusCode ?? 'NO_STATUS'} '
              '${error.requestOptions.uri}\n'
              '  message: ${error.message}\n'
              '  data: ${error.response?.data}',
            );
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  });

  // ── BLoC / Cubit factories ────────────────────────────────────────
  // Register feature Blocs/Cubits here as factories, e.g.:
  // getIt.registerFactory(() => AuthBloc(localStorage: getIt()));
}
