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

  // ── BLoC / Cubit factories ────────────────────────────────────────
  // Register feature Blocs/Cubits here as factories, e.g.:
  // getIt.registerFactory(() => AuthBloc(localStorage: getIt()));
}
