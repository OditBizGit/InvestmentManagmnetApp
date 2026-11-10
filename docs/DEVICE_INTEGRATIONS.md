# Device Integrations

Only integrations present in source/config are listed.

## Firebase / FCM (user build, Android + iOS only)
- Packages: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`.
- Init in `main()` only when `!kIsWeb && !isAdmin && (android || iOS)`. Background handler `firebaseMessagingBackgroundHandler` (top level, `@pragma('vm:entry-point')`) re-initialises Firebase.
- Options file `lib/firebase_options.dart` (`DefaultFirebaseOptions.currentPlatform`; projectId `maribel-wellness`; configs for android, ios, macos, web, windows). Native config files tracked in repo: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase.json` (these are client config files; values not reproduced here).
- Android Gradle applies `com.google.gms.google-services`.
- `NotificationService` (`lib/core/notifications/notification_service.dart`):
  - `initialize()`: init local notifications (Android icon `@mipmap/ic_launcher`, iOS Darwin settings without auto-permission), request FCM permission and Android notification permission, foreground presentation options (alert/badge/sound), listen `onMessage` (shows a local notification), `onMessageOpenedApp`, `getInitialMessage()` (kept as pending), `onTokenRefresh`; registers token if an investor session exists.
  - Android channel: id `maribel_high_importance`, name "Maribel Notifications", importance high.
  - `registerDeviceToken()` / `_registerToken`: investors only; POST via `NotificationsRepository.registerDevice(deviceToken, platform: 'ios'|'android')` -> `ApiEndpoints.registerDevice`. Called after login and on token refresh.
  - `handlePendingInitialMessage()`: called after splash/login to open the notification screen when launched from a tap.
  - Tap handling: any notification tap opens `NotificationScreen` via `notificationNavigatorKey` (message `type`/`relatedId` only logged in debug).
- Notification APIs: `getMyNotifications`, `getUnreadCount`, `markAsRead/`, `markAllAsRead` (user `NotificationsRepository`/`NotificationsCubit`).
- Android manifest permissions: `INTERNET`, `POST_NOTIFICATIONS`, `WRITE_EXTERNAL_STORAGE` (with attributes in manifest; see file), `usesCleartextTraffic="true"` (needed for HTTP API).
- No push on admin builds, web or Windows (by design, comments in `main.dart`).

## File picking / photos
- `file_picker`: admin uploads (banners, construction media, status stories, user documents) and `lib/core/utils/photo_picker_helper.dart`.

## Saving, opening, sharing files
- `pdf`: generates PDFs - receipts (`user/investments/utils/transaction_receipt_pdf.dart`) and admin user exports (`manage_users_export_file.dart`).
- `path_provider`: locations for generated/downloaded files.
- `open_filex`: opens saved files (receipts, exports, media).
- `share_plus`: share receipt PDFs.
- `gal`: saves status media to device gallery (`user/status/utils/status_media_download.dart`).

## Media playback
- `video_player`: admin media viewers and user inline video (`user/updates/widgets/work_update_inline_video.dart`).
- `video_player_win`: Windows registration/support (`admin/.../windows_video_play_support/win_local_video_player.dart`).
- `gif_view`: splash GIF. `lottie`: success animation (`assets/lottie/success.json`).
- `youtube_player_iframe`, `pointer_interceptor`: commented out in pubspec.yaml (uncommitted) and no usage found in `lib`.

## External links
- `url_launcher`: due-payment actions (WhatsApp/phone style links; see `due_payments_table_section.dart`), profile social links (e.g. YouTube channel URL in `user/profile/profile_screen.dart`), legal documents, relationship manager contact.

## Other
- `package_info_plus`: shows app version (admin drawer, login, profile).
- `SystemChrome.setPreferredOrientations([portraitUp])` for user mobile build.
- No camera, location, biometrics, or connectivity packages found.
