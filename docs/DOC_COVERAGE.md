# Documentation Coverage and Verification Report

Honest status of the documentation set versus the source (`lib/**`, platform folders, `pubspec.yaml`, `test/`). Scope: documentation only; no source was modified. Source is treated as truth; unknowns are marked "Unclear - needs human clarification". This report was produced by reading the existing docs and spot-checking them against source (endpoint constants, repositories, cubits, models, pubspec, build config, tests); it is **not** a line-by-line audit of every widget.

## 1. Documentation set

| Area | Files |
|---|---|
| Cross-cutting | PROJECT_OVERVIEW, ARCHITECTURE, STATE_MANAGEMENT, NAVIGATION, AUTHENTICATION, API_CLIENT_CORE, CONFIGURATION, DEPENDENCIES, LOCAL_STORAGE, DEVICE_INTEGRATIONS, DESIGN_SYSTEM, UI_COMPONENTS, UI_IMPLEMENTATION_GUIDE, RESPONSIVE_DESIGN |
| Consolidated (this pass) | [FEATURE_MODULES](FEATURE_MODULES.md), [API_INTEGRATION](API_INTEGRATION.md), [DATA_MODELS](DATA_MODELS.md), [CODEBASE_MAP](CODEBASE_MAP.md), DOC_COVERAGE |
| Admin modules | ADMIN_DASHBOARD, FUNDING_PAYMENTS, INVESTORS, MONTHLY_PAYMENT_LIST, NAVIGATION, PENDING_REQUESTS, REPORTS, SETTINGS, USER_MANAGEMENT, WORK_PROGRESS |
| Auth / user | AUTH_AND_ACCOUNT, USER_HOME, USER_INVESTMENTS, USER_NAVIGATION, USER_PROFILE, USER_STATUS, USER_UPDATES |
| Not part of the set | `docs/superpowers/` (tooling material, untouched) |

## 2. Spot-check results (this pass)

Verified against source and found consistent:
- All 69 `ApiEndpoints` constants are referenced by a repository (nothing dead); HTTP verbs and repository method names in [API_INTEGRATION.md](API_INTEGRATION.md) were taken from `dio.get/post/delete` calls in each `*repository*.dart`.
- Cubit inventory (26 `extends Cubit` classes) matches [CODEBASE_MAP.md](CODEBASE_MAP.md).
- Hand-written (de)serialization: no codegen packages or `*.g.dart` files.
- Auth interceptor skips `Authorization` only for the Login path; `kBaseUrl` is a plain `http` IP:port string.
- `applicationId` is `com.example.maribel_wellness_centre_application`; release build type uses the debug signing config (`android/app/build.gradle.kts`).
- `test/` contains only `widget_test.dart`.

Resolutions of earlier "Unclear" items found while checking (the module docs themselves were left as written so their wording is preserved; update them if desired):
- `ApiEndpoints.getProject` is `/api/Project/GetProjects` (ADMIN_FUNDING_PAYMENTS said "assumed").
- `getAllInvestorTransactionHistory` is used by `ReportCubit`; `FundingPaymentsCubit.fetchInvestors` is called from `add_new_fund.dart` (ADMIN_FUNDING_PAYMENTS Unclear).
- `TransactionReceiptDownloader` is used by the admin `user_receipts_card.dart` (USER_INVESTMENTS Unclear), not by the user module.

## 3. Coverage levels

### Fully documented (structure, flows, validation, API, models checked)
Auth and account, API client core, local storage, configuration, state management, navigation shells (admin and user), admin Dashboard, Funding & Payments, Investors, Monthly Payment List, Pending Requests, Settings, User Management, Work Progress, Reports, user Home, Investments, Profile, Status, Updates. Endpoint, model and file inventories are complete at the file/class level.

### Partially documented
- **Large UI widget files were skimmed, not read line by line.** Examples: `work_update_inline_video.dart` (about 1350 lines, Windows fullscreen details), `reports_details_section.dart` (custom painters, chart math), `legal_documentation_card.dart`, `payment_schedule_section.dart`, `staff_report_table_section.dart`, `add_new_investor` form cards, `user_status_update_screen` and its cards. Layout, spacing and exact visual behaviour are not documented.
- Responsive behaviour: breakpoints are enumerated by count in RESPONSIVE_DESIGN; per-screen behaviour is not.
- API tables: "Screen" and "Cubit" columns in API_INTEGRATION were derived from module docs and file layout; request/response field-level detail beyond what module docs list is not duplicated (consult the model files).
- Data model relationships (DATA_MODELS ER diagram) are inferred from request fields, not from backend schema.
- Per-state classes of each cubit are only summarised (STATE_MANAGEMENT notes names are inferred from file names in places).
- Platform folders (iOS, macOS, Windows, web) were checked only for presence and generated plugin files; their native configuration is minimally covered.
- Tests: only the smoke test exists; it was read but not executed.

### Not documented
- Backend contracts beyond what the client sends/parses (error codes, authorisation rules, server validation).
- Firebase project configuration (values intentionally excluded; no secrets are in docs).
- Git history and the uncommitted working-tree changes (the working tree has many modified files; docs describe the working-tree state).

## 4. Unused, dead or placeholder code

| Item | Location | Evidence |
|---|---|---|
| `ChangeRequestScreen` | `U/profile/screens/personal_info_screen/widgets/change_request_screen.dart` | Entry button commented out; calls no API |
| Local-only Admin Settings / staff permissions + `dummyAdminStaff` | `A/settings/screens/admin_settings/*` | Card commented out in `settings_option_cards.dart` yet still wired in `_showAdminSettings`; seeded with dummy data, no API |
| `work_progress_big_cards.dart` | `A/work_progress/screens/work_progress/widgets/` | Reported fully commented out (module doc); not re-verified line by line |
| Old `main()` | `lib/main.dart` | Commented-out earlier `main` kept above the live one |
| Team Overview tile | user Profile | Empty handler |
| Share action | user Status | Placeholder |
| `ProjectPhaseUpdate`/`MediaUpdate` local models, `_mediaUpdates` list | `A/work_progress/models/add_update_models.dart`, `AddUpdateScreen` | Possibly unused (module doc Unclear) |
| Duplicate endpoint constants | `getBanner`/`getBanners`, `workPhaseList`/`workProgressDetails` | Same path, two names |
| Empty test directories | `test/admin/settings/`, `test/core/constants/` | No files |
| "Excel" export | Manage Users | Generates CSV, not xlsx |
| Typos in names | `funding&payents`, `projcet_model`, `montly_*`, `update_status_stroies`, `user_complaints_respository` | Cosmetic; renaming not attempted |

## 5. Unclear business logic (aggregated; preserved from module docs)

Dashboard
- "Active Investors" card shows the same value as "Total Investors" - intentional?
- `fundingProgress` scale (0-1 fraction or percent): details card normalises heuristically, stats card appends "%".

Funding and Payments
- Relationship/permissions between admin `AddInvestorPayment` and staff-submitted requests (`ReviewPaymentRequest`).
- Purpose of UI-only "due" fields in Add Fund.
- Medical allowance semantics (String amount + days).

Investors
- Exact second-staff / nominee payload naming beyond listed fields; whether "Active Investors" uses `isActive` only; add/edit screen creates its own cubit instead of the `get_it` factory.

Monthly Payment List
- Whether Admin should have access (`canAccessMonthlyList` passes Admin, SuperAdmin, FinancialManager).
- `receiptNumber`, `entryNo`, `investorId`, `userId` parsed but not obviously displayed.

Pending Requests
- Whether approve creates the payment entry server-side (response has `entryNo`).
- Whether `isFullSettlement`, `discountAmount`, `medicalAllowance`, `remarks` are displayed on the review screen.
- Terminated-investor approval semantics.

Reports
- Custom date range limits; meaning of `staffAllocatedAmount`, `refundAmount`, `netAmount` (only `paymentAmount` shown); staff report does not refetch on tab re-activation.

Settings
- Whether Create Admin refetches the list; whether alternate phone is required; purpose of local permissions screen; backend meaning of `ProjectModel.status`; `status` vs `success` envelope inconsistency.

User Management
- Whether the server returns terminate remarks; role-to-screen mapping; why "Excel" is CSV; exact fields in `UserBenefitsSummaryCard`.

Work Progress
- How backend identifies a phase on update (request has only `stageId`); status stories display/expiry rules in the user app; need for local update models; `work_progress_big_cards.dart` dead.

Navigation and auth
- Permissions are client-side only ("until backend permissions arrive"); planned backend model.
- `refreshToken` handling (no refresh token in login model, no 401 handling); `LoginDataModel.phoneNumber` not saved; whether the 900px switch to admin login in the investor build is intentional; redirect is by build flag `isAdmin`, not stored role.

User app
- Notification tap only marks read (no deep link using `type`/`relatedId`); `TopInvestorsCarousel` rules; `registerDevice` body keys (documented now: `deviceToken`, `platform`, from `RegisterDeviceRequestModel.toJson`).
- Work-progress stages are global (not per investor); single project per investor.
- All five tabs built eagerly by `IndexedStack`.
- `WorkStatusModel.status`/`googleDriveFileId` purpose; `WorkUpdateModel.status` meaning; staff phone/percent display in the manager card.

Design/config
- Hardcoded colors vs `AppColors`; only Montserrat Bold bundled while other weights are used; no pinned Flutter version; applicationId before store release; tablet behaviour; standard empty-state component; whether tables use `DataTable` or custom rows.

## 6. Items needing human clarification (action list)

1. Confirm the intended relationship between admin-added payments, staff payment requests and the monthly verification list (single biggest unknown for workflow documentation).
2. Confirm role access matrix (Admin access to Monthly List; Manage Users/Due Payments mapping) and whether backend enforces it.
3. Confirm token refresh/expiry strategy.
4. Decide fate of dead/placeholder code listed in section 4.
5. Confirm intended applicationId, signing, and environment (base URL) strategy for release.
6. Confirm `fundingProgress` units and the "Active Investors" definition.
7. Confirm the meaning of report amounts (`staffAllocatedAmount`, `refundAmount`, `netAmount`).

## 7. Security observations

These are factual observations from source and existing docs, with no secret values reproduced:
- **Auth token stored in plain `SharedPreferences`** (`auth_token`, `refresh_token` keys in `lib/core/storage/local_storage.dart`); no secure storage.
- **Authorization header is logged in debug builds.** The Dio interceptor prints method, URI, headers and body under `kDebugMode`, which includes the bearer token. Release builds are not affected by this branch; repositories also contain `log()` calls (for example form data fields) that should be reviewed.
- **No 401/session-expiry handling** in the Dio interceptor; no token refresh; expired tokens surface as ordinary errors (repositories map 401/403 messages in some places only).
- **Release build uses debug signing** (`signingConfig = signingConfigs.getByName("debug")`).
- **Placeholder applicationId** `com.example.maribel_wellness_centre_application`.
- **Cleartext HTTP** to an IP-addressed backend (`http://`, `usesCleartextTraffic="true"` on Android); no certificate pinning; single environment, no staging/prod separation.
- **Client-side-only role enforcement** (`AdminNavPermissions`); backend authorisation not visible from the client.
- **Hardcoded configuration**: base URL and Firebase options live in source. `android/app/google-services.json` is tracked; whether Firebase keys are restricted server-side is Unclear - needs human clarification.
- **Build flag decides interface**: an admin build can be produced from the same source; a stored admin session opened in a user build is only guarded at login time (NAVIGATION.md).
- **Account block check is client-driven**: `AccountStatusMonitor` reacts to `isActive` in Login/InvestorDetails responses; enforcement on the server is not documented.
- WhatsApp reminders open `wa.me` links containing investor name, amounts and code in the URL text; this transmits personal data to WhatsApp by design (user-initiated).
- Upload paths accept user-picked files; client-side size/type limits exist (photo 10 MB, video 50 MB, banner 5 MB) but server-side validation is unknown.

## 8. How to keep this current

When a module changes: update its `docs/modules/*.md`, then the rows in API_INTEGRATION (new endpoint constants), DATA_MODELS and FEATURE_MODULES, and re-check section 4 above. Working-tree changes at the time of writing touched dashboard, funding, investors, monthly payment list, pending requests, reports, settings, user management, work progress, login, API endpoints and generated plugin registrants; those module docs describe the working-tree state, not the last commit.
