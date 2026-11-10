# Project Overview

## Purpose
Flutter application for **Maribel Wellness Centre** (display titles in code: "Maribel Admin" and "Maribel Maternity Care"). One codebase builds two products, selected at compile time by the constant `isAdmin` in `lib/main.dart`:

- **Admin app** (`isAdmin = true`, `lib/admin/**`): staff/admin dashboard (web/desktop oriented) for managing investors, funding and payments, project work progress, reports, users and settings.
- **User / investor app** (`isAdmin = false`, `lib/user/**`): mobile app for investors (home, investments, status, updates, profile, notifications).

Business domain (inferred from endpoints and models): investor funding for a wellness/maternity centre project - investor registration, payments and installments, MOU/LLP documents, complaints, work-progress updates, banners, top investors, staff allocation and staff reports.

## Stack
| Item | Value (source: `pubspec.yaml`) |
|---|---|
| App name / version | `maribel_wellness_centre_application`, `1.0.3+3` |
| Dart SDK | `^3.12.1` |
| Flutter | Unclear - needs human clarification (no pinned Flutter version; `.metadata` shows `stable` channel) |
| State management | `flutter_bloc` (Cubits) |
| DI | `get_it` |
| HTTP | `dio` |
| Local storage | `shared_preferences` |
| Push | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| Responsive units | `sizer` |
| Lints | `flutter_lints` via `analysis_options.yaml` (android/ios/web/windows/macos/build excluded from analysis) |

See `DEPENDENCIES.md` for every package.

## Features
Admin (drawer items, enum `AdminDrawerItem` in `lib/admin/navigation/admin_side_drawer.dart`): Dashboard, Investors, Payments (funding), Work Progress, Reports (Overview, Staff Report), User Management (Manage Users, Due Payments), Pending Requests, Monthly List, Settings. Settings sub-screens exist under `lib/admin/settings` (create project, create admin, staff allocation, investor rating, user complaints).

User (bottom tabs in `lib/user/navigation/user_bottom_nav.dart`): Home, Investment, Status, Updates, Profile; plus notification screen, complaint registration, receipt PDF export/share, status media download to gallery, work-update inline video.

Auth: role-based login (`lib/auth`), account-block overlay for blocked investors (`lib/core/account`).

Feature internals are documented in other files in `docs/`; this set covers cross-cutting concerns.

## Platform support
- Android, iOS, Web, Windows, macOS folders exist. Firebase options are generated for android, ios, macos, web, windows (`lib/firebase_options.dart`); linux throws `UnsupportedError`.
- Push notifications are initialised only on Android/iOS **and** when `isAdmin == false`.
- Admin UI is a desktop-style side-drawer layout (`AdminMainScreen`, collapse widths 1050/1180). `LoginScreen` switches to `AdminWebLoginScreen` at width >= 900.
- Windows video playback uses `video_player_win`.
- Launcher icons configured for android, web, windows (not iOS) in `pubspec.yaml`.

## Related docs
ARCHITECTURE.md, STATE_MANAGEMENT.md, NAVIGATION.md, AUTHENTICATION.md, LOCAL_STORAGE.md, DEVICE_INTEGRATIONS.md, DEPENDENCIES.md, CONFIGURATION.md, API_CLIENT_CORE.md.
