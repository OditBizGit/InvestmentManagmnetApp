# AI Context (start here)

## Overview
Maribel Wellness Centre is a Flutter app (Dart SDK ^3.12) for investor/project management. One codebase, two role builds selected by the compile-time constant `isAdmin` in `lib/main.dart`: the **admin** app (web/desktop; staff dashboards, investors, payments, reports, settings) and the **user** (investor) app (Android/iOS; home, investments, status, updates, profile, push notifications). The backend is a REST API reached through one shared Dio instance.

## Architecture summary
- Layers per feature: `screen -> Cubit (flutter_bloc) -> Repository (Dio) -> Model`.
- DI: `get_it` via `setupDi()` in `lib/core/network/service_locator.dart` (called from `main`). Registers LocalStorage, AccountBlockCubit, the Dio client (auth-token interceptor), repositories (lazy singletons) and many cubits (factories).
- Cubits are provided with `BlocProvider`; app-wide ones in `MyApp` (`lib/main.dart`), others at screen level. Some features (e.g. admin monthly payment list) are NOT in get_it: the screen creates `RepositoryProvider` + `BlocProvider` using `getIt<Dio>()`.
- API paths: `lib/core/constants/api_endpoints.dart`. Errors: repositories throw `Exception(message)`; cubits emit error states / action messages; `lib/core/utils/api_error_message.dart` maps errors to user text.
- Shared UI helpers live in `lib/core/utils/`; colors in `lib/core/constants/app_colors.dart`; font Montserrat.

## Important modules
`lib/auth` (login), `lib/core` (account block guard, constants, network/DI, notifications, storage, utils), `lib/admin/*` (dashboard, funding&payments, investors, monthly_payment_list, navigation, pending_requests, reports, settings, user_management, work_progress), `lib/user/*` (home, investments, navigation, profile, status, updates).

## Where to find things
| Need | Location |
|---|---|
| DI / Dio setup | `lib/core/network/service_locator.dart` |
| Endpoints | `lib/core/constants/api_endpoints.dart` |
| Token / prefs | `lib/core/storage/local_storage.dart` |
| Role switch, app providers | `lib/main.dart` |
| Admin shell / permissions | `lib/admin/navigation/admin_main_screen.dart`, `admin_nav_permissions.dart` |
| Colors | `lib/core/constants/app_colors.dart` |
| Snackbars/toasts/formatters | `lib/core/utils/` |
| Tests | `test/` (minimal; see AI_TASK_WORKFLOW) |

## Task type -> read first
| Task | Docs |
|---|---|
| Any task | this file, DEVELOPMENT_RULES.md, AI_TASK_WORKFLOW.md |
| New screen/feature | FEATURE_IMPLEMENTATION_GUIDE.md, UI_IMPLEMENTATION_GUIDE.md, DESIGN_SYSTEM.md, RESPONSIVE_DESIGN.md, relevant `modules/*.md` |
| API integration | API_INTEGRATION.md, API_CLIENT_CORE.md, DATA_MODELS.md, CONFIGURATION.md |
| State bug / new cubit | STATE_MANAGEMENT.md, ARCHITECTURE.md |
| Navigation / permissions | NAVIGATION.md, modules/ADMIN_NAVIGATION.md, modules/USER_NAVIGATION.md |
| Login / roles / blocked account | AUTHENTICATION.md, modules/AUTH_AND_ACCOUNT.md |
| UI styling / widgets | DESIGN_SYSTEM.md, UI_COMPONENTS.md, UI_IMPLEMENTATION_GUIDE.md, RESPONSIVE_DESIGN.md |
| Storage, notifications, devices | LOCAL_STORAGE.md, DEVICE_INTEGRATIONS.md |
| Security, auth hardening | SECURITY.md, DECISIONS.md, plans/SECURITY_HARDENING_PLAN.md |
| Packages | DEPENDENCIES.md |
| Locate code / feature behavior | CODEBASE_MAP.md, FEATURE_MODULES.md, DOC_COVERAGE.md |
| Diagrams | DIAGRAMS.md |

## All docs
- Project: [PROJECT_OVERVIEW](PROJECT_OVERVIEW.md), [ARCHITECTURE](ARCHITECTURE.md), [CONFIGURATION](CONFIGURATION.md), [DEPENDENCIES](DEPENDENCIES.md), [STATE_MANAGEMENT](STATE_MANAGEMENT.md), [NAVIGATION](NAVIGATION.md), [AUTHENTICATION](AUTHENTICATION.md), [API_CLIENT_CORE](API_CLIENT_CORE.md), [LOCAL_STORAGE](LOCAL_STORAGE.md), [DEVICE_INTEGRATIONS](DEVICE_INTEGRATIONS.md), [SECURITY](SECURITY.md), [DECISIONS](DECISIONS.md)
- UI: [DESIGN_SYSTEM](DESIGN_SYSTEM.md), [UI_COMPONENTS](UI_COMPONENTS.md), [UI_IMPLEMENTATION_GUIDE](UI_IMPLEMENTATION_GUIDE.md), [RESPONSIVE_DESIGN](RESPONSIVE_DESIGN.md)
- AI workflow: [DEVELOPMENT_RULES](DEVELOPMENT_RULES.md), [FEATURE_IMPLEMENTATION_GUIDE](FEATURE_IMPLEMENTATION_GUIDE.md), [AI_TASK_WORKFLOW](AI_TASK_WORKFLOW.md), [DIAGRAMS](DIAGRAMS.md)
- Catalogs: [FEATURE_MODULES](FEATURE_MODULES.md), [API_INTEGRATION](API_INTEGRATION.md), [DATA_MODELS](DATA_MODELS.md), [CODEBASE_MAP](CODEBASE_MAP.md), [DOC_COVERAGE](DOC_COVERAGE.md)
- Admin modules: [DASHBOARD](modules/ADMIN_DASHBOARD.md), [FUNDING_PAYMENTS](modules/ADMIN_FUNDING_PAYMENTS.md), [INVESTORS](modules/ADMIN_INVESTORS.md), [MONTHLY_PAYMENT_LIST](modules/ADMIN_MONTHLY_PAYMENT_LIST.md), [NAVIGATION](modules/ADMIN_NAVIGATION.md), [PENDING_REQUESTS](modules/ADMIN_PENDING_REQUESTS.md), [REPORTS](modules/ADMIN_REPORTS.md), [SETTINGS](modules/ADMIN_SETTINGS.md), [USER_MANAGEMENT](modules/ADMIN_USER_MANAGEMENT.md), [WORK_PROGRESS](modules/ADMIN_WORK_PROGRESS.md)
- Auth/User modules: [AUTH_AND_ACCOUNT](modules/AUTH_AND_ACCOUNT.md), [USER_HOME](modules/USER_HOME.md), [USER_INVESTMENTS](modules/USER_INVESTMENTS.md), [USER_NAVIGATION](modules/USER_NAVIGATION.md), [USER_PROFILE](modules/USER_PROFILE.md), [USER_STATUS](modules/USER_STATUS.md), [USER_UPDATES](modules/USER_UPDATES.md)

Source code wins over docs on any discrepancy.
