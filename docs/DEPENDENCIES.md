# Dependencies (`pubspec.yaml`)

Environment: Dart `^3.12.1`. App version `1.0.3+3`.

## Runtime
| Package | Version | Purpose / where used |
|---|---|---|
| flutter (sdk) | - | Framework |
| cupertino_icons | ^1.0.8 | Default iOS icon font; no specific usage checked |
| dio | ^5.8.0+1 | HTTP client; single instance in `core/network/service_locator.dart`, used by all repositories |
| flutter_bloc | ^9.1.1 | Cubits, BlocProvider/Builder everywhere |
| get_it | ^8.0.3 | Service locator `getIt` |
| shared_preferences | ^2.5.3 | `core/storage/local_storage.dart` |
| flutter_secure_storage | ^9.2.4 | Auth/refresh tokens on mobile/desktop in `core/storage/local_storage.dart` (PM-approved 2026-11-09, D4) |
| sizer | ^3.1.3 | Responsive units (`.w`, `.h`, `.sp`); wraps app in `main.dart` |
| toastification | ^3.0.2 | Toasts via `core/utils/app_toast.dart`; `ToastificationWrapper` in `main.dart` |
| file_picker | ^8.3.7 | Admin uploads, `photo_picker_helper.dart` |
| flutter_svg | ^2.3.0 | SVG icons from `assets/svg_icons/` across admin and user UI |
| lottie | ^3.5.1 | Success animation (`lottie_constants.dart`, complaint success screen) |
| carousel_slider | ^5.1.2 | User home carousels (service gallery, top investors) |
| video_player | ^2.14.0 | Admin media viewers, user inline update video |
| gif_view | ^1.0.3 | Splash GIF (`auth/splash_screen.dart`) |
| youtube_player_iframe | ^6.0.2 | Commented out in pubspec.yaml (working tree, uncommitted); no import found in `lib` |
| pointer_interceptor | ^0.10.1+2 | Commented out in pubspec.yaml (working tree, uncommitted); no import found in `lib` |
| package_info_plus | ^8.3.0 | App version text (admin drawer, login, profile) |
| shimmer | ^3.0.0 | Loading skeletons (dashboard, user home) |
| cached_network_image | ^4.0.0 | Network images (investors table, user home/status/updates) |
| pdf | ^3.13.1 | PDF generation (receipts, user export) |
| path_provider | ^2.1.6 | File locations for exports/downloads/receipts |
| open_filex | ^4.7.0 | Open saved files |
| share_plus | ^12.0.2 | Share receipt PDF |
| flutter_cache_manager | ^3.4.5 | Work-update media cache (`user/updates/utils/work_update_media_cache.dart`) |
| video_player_win | ^3.3.0 | Windows video playback support |
| gal | ^2.3.3 | Save media to gallery |
| firebase_core | ^4.15.0 | Firebase init (`main.dart`, `firebase_options.dart`) |
| firebase_messaging | ^16.7.0 | FCM (`notification_service.dart`) |
| flutter_local_notifications | ^22.3.1 | Foreground notifications |
| url_launcher | ^6.3.1 | Open links/phone/WhatsApp-style URLs |

## Dev
| Package | Version | Purpose |
|---|---|---|
| flutter_test | sdk | Tests (no tests inspected) |
| flutter_lints | ^6.0.0 | Lint rules (`analysis_options.yaml`) |
| flutter_launcher_icons | ^0.14.3 | Icon generation from `assets/logo/maribelAppIcon.png` (android, web, windows) |

Notes: usage was determined by importing-file search under `lib/`. `intl`, `http`, `equatable` and routers are not used.
