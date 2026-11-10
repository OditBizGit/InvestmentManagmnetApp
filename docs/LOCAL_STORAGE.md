# Local Storage

Single mechanism: `shared_preferences ^2.5.3`, wrapped by `LocalStorage` (`lib/core/storage/local_storage.dart`). Only this file imports `SharedPreferences` for app data (`auth/cubit/login_cubit.dart` and `account_blocked_overlay.dart` only mention it in comments). Registered as a get_it singleton; created by `await LocalStorage.init()` in `setupDi()`.

Notes: on mobile/desktop the auth and refresh tokens are stored in `flutter_secure_storage` (Keychain/Keystore); on web (`kIsWeb`) they stay in SharedPreferences (decision D3 in DECISIONS.md, web moves to HttpOnly cookies once the backend supports it). `init()` loads tokens into memory (getters stay synchronous) and migrates a legacy prefs token into secure storage, then deletes the prefs copy. If a secure write fails, the token is kept in memory only (never in plaintext prefs) and is lost on restart. All other values remain in SharedPreferences. Android `allowBackup="false"`.

## Keys
| Key | Accessors | Meaning |
|---|---|---|
| `auth_token` | `set/get/clearAuthToken` | Bearer token used by the Dio interceptor. Secure storage on non-web, prefs on web |
| `refresh_token` | `set/getRefreshToken` | Secure storage on non-web. Written by login (`saveSession`) and replaced on each refresh via `saveTokens` (D7) |
| `user_id` | `set/getUserId` | Used e.g. by `AccountStatusMonitor.refresh` |
| `username`, `full_name`, `user_email` | set/get | Profile display |
| `user_role` | `set/getUserRole` | Drives `AdminNavPermissions`, investor checks |
| `investor_code`, `profile_image` | set/get | Only stored when non-empty |
| `is_logged_in` | `setIsLoggedIn/getIsLoggedIn` | Part of `hasValidSession()` |
| `is_active` | `setIsActive/getIsActive` (default true) / `getIsActiveOrNull` | Account-block flag |
| `funding_transaction_history` | `set/get/clearFundingTransactionHistory...Json` | JSON cache for admin funding transactions; cleared on logout |
| `funding_investors_list_v2` | `set/get/clearFundingInvestorsList...Json` | JSON cache of admin funding investors; **not** removed by `clearSession` (only by its own clear method) |

## Methods of note
- `saveSession({authToken, refreshToken?, userId?, username?, fullName?, userRole?, userEmail?, investorCode?, profileImage?, isActive?})`: calls `clearSession()` first, writes values, sets `is_logged_in = true`.
- `saveTokens({authToken, refreshToken})`: replaces only the two tokens after a refresh, keeping the rest of the session (unlike `saveSession`, which clears first).
- `clearSession()`: clears in-memory tokens, deletes tokens from secure storage and prefs, and removes auth_token, refresh_token, user_id, username, full_name, user_role, user_email, investor_code, profile_image, is_logged_in, is_active, funding_transaction_history.
- `hasValidSession()`: token non-empty and `is_logged_in`.

## Other local persistence
- `flutter_cache_manager` caches work-update media on disk (`lib/user/updates/utils/work_update_media_cache.dart`); `cached_network_image` caches images.
- Files written to documents/temp/downloads by `path_provider` consumers: receipt PDFs (`user/investments/utils/transaction_receipt_pdf.dart`), exports (`admin/.../export_file_saver_io.dart`), media downloads. See DEVICE_INTEGRATIONS.md.
- No SQLite/Hive/Isar found.
