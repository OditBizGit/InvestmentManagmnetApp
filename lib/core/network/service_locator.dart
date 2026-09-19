import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/cubit/funding_payments_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/cubit/investors_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/auth/repository/login_repository.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/user/home/cubit/home_cubit.dart';
import 'package:maribel_wellness_centre_application/user/home/repository/home_repository.dart';
import 'package:maribel_wellness_centre_application/user/investments/cubit/investments_cubit.dart';
import 'package:maribel_wellness_centre_application/user/investments/repository/investments_repository.dart';
import 'package:maribel_wellness_centre_application/user/profile/cubit/profile_cubit.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// API base URL used by network clients / repositories.
const String kBaseUrl = 'http://103.38.50.206:3052/';

/// Builds a full URL from a stored relative path such as `/investorphotos/...`.
String? resolveMediaUrl(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = kBaseUrl.endsWith('/')
      ? kBaseUrl.substring(0, kBaseUrl.length - 1)
      : kBaseUrl;
  return '$base${trimmed.startsWith('/') ? trimmed : '/$trimmed'}';
}

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
          final isPublicAuthRequest = _isPublicAuthRequest(options);

          // Never attach a (possibly stale) token to login / public auth calls.
          if (isPublicAuthRequest) {
            options.headers.remove('Authorization');
          } else {
            // Always read the latest token from LocalStorage.
            final token = getIt<LocalStorage>().getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              options.headers.remove('Authorization');
            }
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

  // ── Repositories ──────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<InvestorsRepository>(
    () => InvestorsRepository(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<InvestorPaymentRepository>(
    () => InvestorPaymentRepository(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepository(
      localStorage: getIt<LocalStorage>(),
      profileRepository: getIt<ProfileRepository>(),
      dio: getIt<Dio>(),
    ),
  );
  getIt.registerLazySingleton<InvestmentsRepository>(
    () => InvestmentsRepository(dio: getIt<Dio>()),
  );

  // ── BLoC / Cubit factories ────────────────────────────────────────
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      authRepository: getIt<AuthRepository>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  getIt.registerFactory<InvestorsCubit>(
    () => InvestorsCubit(
      repository: getIt<InvestorsRepository>(),
    ),
  );
  getIt.registerFactory<FundingPaymentsCubit>(
    () => FundingPaymentsCubit(
      investorsRepository: getIt<InvestorsRepository>(),
      paymentRepository: getIt<InvestorPaymentRepository>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      repository: getIt<HomeRepository>(),
    ),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      repository: getIt<ProfileRepository>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  getIt.registerFactory<InvestmentsCubit>(
    () => InvestmentsCubit(
      repository: getIt<InvestmentsRepository>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
}

/// Public auth endpoints that must not send an Authorization header.
bool _isPublicAuthRequest(RequestOptions options) {
  final path = options.path;
  final fullPath = options.uri.path;
  return path.contains(ApiEndpoints.login) ||
      fullPath.contains(ApiEndpoints.login);
}
