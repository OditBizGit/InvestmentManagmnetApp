# Codebase Map

"Where do I find X" lookup. Paths are relative to the repo root. `A/` = `lib/admin/`, `U/` = `lib/user/`. Directory names with unusual characters are real: `A/funding&payments`, `A/funding&payments/screens/funding&payents` (typo), `A/work_progress/screens/add_update/add _banner` (space), `update_status_stroies` (typo), `A/settings/screens/create_project/model/projcet_model.dart`, `user_complaints_respository.dart`, `montly_payment_*` files.

## 1. Entry points and bootstrap

| What | Where |
|---|---|
| `main()`, `MyApp`, `isAdmin` build switch, background FCM handler | `lib/main.dart` |
| Dependency injection (`setupDi`, `getIt`, `Dio`, interceptor, `kBaseUrl`) | `lib/core/network/service_locator.dart` |
| Firebase options (generated) | `lib/firebase_options.dart` |
| Splash | `lib/auth/splash_screen.dart` |
| Login (investor/mobile) | `lib/auth/login_screen.dart` |
| Login (admin web, role dropdown) | `lib/auth/admin_web_login_screen.dart` |
| Post-login home | admin: `A/navigation/admin_main_screen.dart`; user: `U/navigation/user_main_screen.dart` |
| App config / pubspec / lints | `pubspec.yaml`, `analysis_options.yaml`, `firebase.json` |

## 2. Screens by role

**Investor (user app, `isAdmin = false`)** - bottom nav (`U/navigation/user_bottom_nav.dart`) with 5 tabs:
- Home: `U/home/home_screen.dart`, `U/home/notification_screen.dart`
- Investments: `U/investments/investments_screen.dart`, `U/investments/transaction_receipt_screen.dart`
- Status: `U/status/status_screen.dart`
- Updates: `U/updates/updates_screen.dart`
- Profile: `U/profile/profile_screen.dart` + `screens/personal_info_screen`, `document_screen/documents_screen.dart`, `investment_details_screen`, `register_complaint_screen`

**Admin / Super Admin** - drawer (`A/navigation/admin_side_drawer.dart`): Dashboard (`A/dashboard/dashboard_screen.dart`), Investors (`A/investors/screens/investors_screen`, `add_new_investor`), Funding & Payments (`A/funding&payments/screens/...`), Work Progress (`A/work_progress/screens/work_progress`, `add_update`), Reports (`A/reports/screens/reports_screen.dart`, `staff_report/`), Manage Users (`A/user_management/screens/manage_users/screens/`), Due Payments (`A/user_management/screens/due_payments/`), Settings (`A/settings/screens/settings/settings_screen.dart` and the six sub-screens under `A/settings/screens/*`). Monthly List is also reachable by these roles per `AdminNavPermissions`.

**Marketing Manager:** Pending Requests only: `A/pending_requests/screens/pending_requests/pending_requests_screen.dart`, `review_request/review_request_screen.dart`.

**Financial Manager:** Monthly Payment List only: `A/monthly_payment_list/screen/monthly_payments_list_screen.dart`, `payment_verification_history_screen.dart`.

Role-to-screen logic: `A/navigation/admin_nav_permissions.dart` (client-side only).

## 3. Cubits (state)

Convention: `X/cubit/x_cubit.dart` + `x_state.dart` ([STATE_MANAGEMENT.md](STATE_MANAGEMENT.md)).
- Admin: `DashboardCubit`, `FundingPaymentsCubit`, `InvestorsCubit`, `PaymentListCubit` (monthly list), `PendingRequestsCubit`, `ReportCubit` (`A/reports/cubit/report__cubit.dart`, double underscore), `StaffReportCubit`, `CreateAdminCubit`, `CreateProjectCubit`, `InvestorRatingCubit`, `StaffAllocationCubit`, `UserComplaintsCubit`, `DuePaymentsCubit`, `ManageUsersCubit`, `WorkProgressCubit`, `UpdatePhaseCubit`, `UpdateConstructionCubit`, `UpdateStatusCubit`, `AddBannerCubit`.
- Auth/core: `LoginCubit` (`lib/auth/cubit`), `AccountBlockCubit` (`lib/core/account`).
- User: `HomeCubit`, `NotificationsCubit` (`U/home/cubit`), `InvestmentsCubit`, `ProfileCubit`, `StatusCubit`, `UpdatesCubit`.

## 4. Repositories (API access)

One per feature in `*/repository/`; all take `Dio`. Registered in `get_it` (see `service_locator.dart` and `MyApp` `MultiRepositoryProvider` in `main.dart`): `AuthRepository`, `InvestorsRepository`, `InvestorPaymentRepository`, `HomeRepository`, `ProfileRepository`, `AddPhaseRepository`, and others; the remaining ones are created in screens (see [ARCHITECTURE.md](ARCHITECTURE.md)). Endpoint-by-repository table: [API_INTEGRATION.md](API_INTEGRATION.md).

## 5. Models

`*/model/` per module (list per module in [DATA_MODELS.md](DATA_MODELS.md)). Largest model clusters: `A/investors/model` (11 files), `A/user_management/screens/manage_users/model`, `U/home/model`, `U/profile/model`.

## 6. Widgets and shared UI

- Per-screen widgets: `*/widgets/` or `*/screens/**/widgets/` with suffixes `_overview_section` (stat cards), `_table_section`/`_table` (tables), `_form_card`, `_side_panel` ([UI_COMPONENTS.md](UI_COMPONENTS.md)).
- Shared admin: `lib/core/utils/admin_main_screen_layout.dart`, `admin_top_bar.dart`, `admin_footer.dart`; user-management shared: `A/user_management/widgets/` (`user_management_confirm_dialog`, `..._list_toolbar`, `..._stat_cards`, `..._table_widgets`).
- Shared dialogs/overlays: `logout_confirm_dialog.dart`, `user_logout_confirm_dialog.dart`, `commitment_completed_overlay.dart`, `success_screen.dart`, `A/funding&payments/widgets/funding_limit_warning_dialog.dart`, `lib/core/account/account_blocked_overlay.dart`.
- Charts/painters: custom painters inside `A/reports/screens/widgets/reports_details_section.dart` and `U/investments/widgets/work_progress_graph_card.dart`.
- Responsiveness: [RESPONSIVE_DESIGN.md](RESPONSIVE_DESIGN.md); theme/colors: [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

## 7. Utils, constants, services

| Need | File |
|---|---|
| Endpoint paths | `lib/core/constants/api_endpoints.dart` |
| Colors | `lib/core/constants/app_colors.dart` |
| Image/Lottie asset paths | `lib/core/constants/image_constants.dart`, `lottie_constants.dart` |
| Session/token storage | `lib/core/storage/local_storage.dart` ([LOCAL_STORAGE.md](LOCAL_STORAGE.md)) |
| Push notifications (FCM + local) | `lib/core/notifications/notification_service.dart` |
| Blocked-account flow | `lib/core/account/*` (`account_block_cubit`, `account_block_state`, `account_block_routes`, `account_status_monitor`, `auth_navigation_guard`, `account_blocked_overlay`) |
| Error text from Dio | `lib/core/utils/api_error_message.dart` |
| Toasts / snackbars | `lib/core/utils/app_toast.dart`, `app_snack_bar.dart` |
| Media URL resolution | `lib/core/utils/media_url.dart` |
| Image picker | `lib/core/utils/photo_picker_helper.dart` |
| Currency / string helpers | `currency_formatter.dart`, `string_extensions.dart` |
| Scroll-to-top | `go_to_top_button.dart` |
| File export saving (web / IO) | `A/user_management/screens/manage_users/utils/export_file_saver*.dart`, `manage_users_export_file.dart` |
| Receipt PDF + download | `U/investments/utils/transaction_receipt_pdf.dart`, `transaction_receipt_downloader.dart` |
| Media caching/download | `U/updates/utils/work_update_media_cache.dart`, `U/status/utils/status_media_download.dart` |
| Windows video playback | `A/work_progress/screens/add_update/update_construction_photos_videos/windows_video_play_support/` |

## 8. Platform folders

| Folder | Notes |
|---|---|
| `android/` | `app/build.gradle.kts` (applicationId placeholder, debug signing for release), `google-services.json`, manifest in `app/src/main` |
| `ios/` | present; launcher icons disabled in pubspec (`ios: false`) |
| `web/` | `index.html`, `manifest.json`, icons (admin web build) |
| `windows/` | CMake runner; `flutter/generated_plugin*` auto-generated |
| `macos/` | present; `Flutter/GeneratedPluginRegistrant.swift` auto-generated |
| `assets/` | `font/` (Montserrat-Bold only), `gif/`, `logo/`, `lottie/`, `svg_icons/` |

Details: [CONFIGURATION.md](CONFIGURATION.md), [DEVICE_INTEGRATIONS.md](DEVICE_INTEGRATIONS.md).

## 9. Tests

- `test/widget_test.dart` - the only test file: pumps `MyApp` after `setupDi()` with mocked `SharedPreferences`, asserts `MyApp` exists (smoke test).
- `test/admin/settings/` and `test/core/constants/` exist as directories but contain no files.
- No unit tests for cubits, repositories or models; no `mockito`/`bloc_test` dependency (`dev_dependencies`: `flutter_test`, `flutter_lints`, `flutter_launcher_icons`). Whether `widget_test.dart` currently passes was not run: Unclear - needs human clarification.

## 10. Documentation map

`docs/*.md` cross-cutting guides; `docs/modules/*.md` one per feature; `docs/superpowers/` is unrelated tooling material and not part of this documentation set. Index of coverage: [DOC_COVERAGE.md](DOC_COVERAGE.md). Feature inventory: [FEATURE_MODULES.md](FEATURE_MODULES.md).
