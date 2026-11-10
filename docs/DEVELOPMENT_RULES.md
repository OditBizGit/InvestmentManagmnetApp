# Development Rules

## Observed conventions
**Naming**: files `snake_case.dart`; classes `UpperCamelCase`; private widgets `_XyzView`; cubit `XyzCubit` in `xyz_cubit.dart`, state in `xyz_state.dart` (`part of`); repositories `XyzRepository`; models `*_model.dart`. Imports mix `package:maribel_wellness_centre_application/...` and relative paths. Some folders contain `&` (`funding&payments`); keep as is.

**Feature layout** (`lib/<admin|user>/<feature>/`): `cubit/`, `model/`, `repository/`, `screen(s)/` (+ `widgets/`), optional `utils/`. Cross-feature helpers go in `lib/core/utils/`.

**State management**: `flutter_bloc` Cubit. State is a `sealed class` in a `part of` file: `Initial`, `Loading`, `Loaded`, `Error`; `Loaded` has `copyWith` (with `clearX` flags) and carries refresh/submit flags (`isListRefreshing`, `isReviewSubmitting`) and `actionMessage`/`actionIsSuccess` for snackbars. Refreshing with existing data keeps the data and reports errors through `actionMessage`; first-load errors emit `Error(message)`. Cubits take repositories via required named constructor params and log with `dart:developer` `log`.

**DI/providers**: shared repos/cubits are registered in `setupDi()` (repository = `registerLazySingleton`, cubit = `registerFactory`); app-wide providers in `MyApp`. Feature-local alternative: the screen builds `RepositoryProvider(create: ... Repository(dio: getIt<Dio>()))` + `BlocProvider`. Match the neighbouring feature.

**API**: endpoints are constants in `ApiEndpoints`; repositories use the single `getIt<Dio>()` (base URL and bearer-token interceptor in service_locator); never create another Dio. Responses are `{status, message, data}` wrapped by models with `fromJson`; the repo throws `Exception(message)` when `!status`, and handles `DioException` (cancel rethrown, server `message`, timeout/connection texts).

**Errors**: repo throws -> cubit catches, strips `Exception: `, emits state -> screen shows via `AppSnackBar`/`AppToast`/error view. `ApiErrorMessage.from(error)` gives network-aware text.

**UI**: Montserrat; colors from `AppColors`; admin screens use shared shell/top bar/footer from `core/utils`; admin is wide (web/desktop), user is mobile portrait. See DESIGN_SYSTEM.md and RESPONSIVE_DESIGN.md.

## The 15 AI development rules
1. Read `docs/AI_CONTEXT.md` before any task.
2. Read the module docs relevant to the task.
3. Search for existing implementations before writing code.
4. Reuse existing widgets and services.
5. Follow the state management architecture (Cubit + sealed states).
6. Follow routing/navigation conventions (see NAVIGATION.md).
7. Follow the existing API patterns (ApiEndpoints, shared Dio, repository).
8. Preserve existing functionality.
9. Preserve UI behavior unless the task requires change.
10. Do not invent business rules; ask or cite the source.
11. Do not add packages unnecessarily.
12. Do not change the design system without approval.
13. Do not create duplicate widgets or services.
14. Do not modify unrelated modules.
15. Ask when requirements are ambiguous.
