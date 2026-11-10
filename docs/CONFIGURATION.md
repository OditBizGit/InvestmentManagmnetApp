# Configuration

## Product selection (admin vs user)
`const bool isAdmin` in `lib/main.dart` (currently `true`). It is a source-level constant; no flavors, `--dart-define`, or `.env` found. Changing the product requires editing this file and rebuilding. Affects: Firebase/notification init, `navigatorKey`, observers, app title, `AccountBlockCubit` provider, and the home shell.

## API base URL
- Defined as `const String kBaseUrl` in `lib/core/network/service_locator.dart` (plain `http://` with an IP:port host, trailing slash; see file for the literal). Also registered as get_it `String` named `'baseUrl'`, and used for `BaseOptions.baseUrl` and media URL resolution (`resolveMediaUrl` exists in both `service_locator.dart` and `lib/core/utils/media_url.dart`, the latter also normalises `\`, `~/`, `data:` URIs).
- Endpoint paths: `lib/core/constants/api_endpoints.dart` (paths only, see API_CLIENT_CORE.md).
- Single environment; no dev/staging/prod switch. Android allows cleartext HTTP (`usesCleartextTraffic="true"`) because `kBaseUrl` is plain HTTP to a raw IP; moving to HTTPS is planned (security finding C1, D1). Android `allowBackup="false"`. Release builds are still signed with the debug key (M1, open).
- No API keys in Dart config; the Bearer token comes from login (see AUTHENTICATION.md).

## Firebase
- `lib/firebase_options.dart` (FlutterFire generated), `firebase.json`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`. Firebase project id: `maribel-wellness`. Values are client config and are not copied here. Used only by the user mobile build.

## Assets and fonts (`pubspec.yaml`)
- Assets dirs: `assets/svg_icons/`, `assets/logo/`, `assets/gif/`, `assets/lottie/`. Constants in `lib/core/constants/image_constants.dart`, `lottie_constants.dart`, colors in `app_colors.dart`.
- Font: family `Montserrat`, only `assets/font/Montserrat-Bold.ttf` declared (weight 700); other weights are synthesised/unavailable. `MyApp.fontFamily = 'Montserrat'`.
- `uses-material-design: true`.
- Launcher icons: `assets/logo/maribelAppIcon.png` for android, web, windows (256); ios disabled.

## Android (`android/app/build.gradle.kts`)
- namespace/applicationId `com.example.maribel_wellness_centre_application` (placeholder-style id; Unclear - needs human clarification before store release).
- `compileSdk = 36`, `minSdk/targetSdk = flutter.*`, Java/Kotlin 17, core library desugaring (`desugar_jdk_libs:2.1.4`), multiDex.
- Release build is signed with the **debug** signing config (no release keystore configured).
- Plugins: `com.android.application`, `com.google.gms.google-services`, `dev.flutter.flutter-gradle-plugin`.
- Manifest: INTERNET, POST_NOTIFICATIONS, WRITE_EXTERNAL_STORAGE, cleartext traffic, `allowBackup="false"`.

## iOS / macOS / Web / Windows
- iOS: `ios/Runner` with `GoogleService-Info.plist`, `Info.plist`. Orientation lock is applied in Dart (portrait) for the user build.
- Web: `web/index.html`, `web/manifest.json` (name "MaribelWellnessCenter", `display: standalone`, `orientation: portrait-primary`, theme `#0175C2`). Intended for the admin build.
- Windows: `windows/` runner; generated plugin files modified in working tree. Firebase options include a windows entry, but Firebase is not initialised on Windows.
- macOS: folder exists; `GeneratedPluginRegistrant.swift` modified in working tree.

## Build / version
- Version in `pubspec.yaml`: `1.0.3+3`; Android `versionCode/versionName` come from Flutter (`flutter.versionCode`, `versionName`).
- Typical commands: `flutter pub get`, `flutter run -d <device>`, `flutter build apk|web|windows`. After toggling `isAdmin`, rebuild. (Commands are standard Flutter; no custom scripts found.)
- Analysis: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` and excludes `build/**`, `android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`.
