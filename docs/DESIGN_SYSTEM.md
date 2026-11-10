# Design System

Source of truth: `lib/core/constants/app_colors.dart`, `lib/main.dart`, `pubspec.yaml`, `lib/core/constants/*`. This documents what exists; there is no separate token file beyond `AppColors`.

## Build flavours
`lib/main.dart` has `const bool isAdmin = true;` (line ~39). One codebase builds either the admin web/desktop app (`lib/admin`) or the investor mobile app (`lib/user`). Title: `Maribel Admin` / `Maribel Maternity Care`.

## Colors (`AppColors`)
| Token | Value |
|---|---|
| `white` | `Colors.white` (#FFFFFF) |
| `accent` | #A28CC1 (primary purple; theme seed) |
| `accentDark` | ARGB(255,55,15,105) = #370F69 |
| `textPrimary` | #3D3D3D |
| `textSecondary` | #8A8099 |
| `textMuted` | #888888 |
| `border` | #E8E8E8 |
| `hint` | #B0B0B0 |
| `cardBg` | #F0EBF6 |
| `screenBg` | #F7F6F9 |
| `green` | #1BA752 |
| `error` | `Colors.redAccent` |
| `newBorder` | #1A727475 (10% alpha) |
| `successBg` | #A28CC1 (same as accent) |
| `disabled` | #35051C |

Hardcoded literals also exist in code, e.g. `Color(0xFFE8E6EC)` (refetch bar track, `lib/core/utils/admin_main_screen_layout.dart`), `0xFFE0E0E0`/`0xFFF5F5F5` (shimmer, `DashboardShimmer`). Unclear - needs human clarification whether these should become tokens.

## Theme (`lib/main.dart`, `MyApp`)
```dart
theme: ThemeData(
  fontFamily: fontFamily,                       // 'Montserrat'
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
  useMaterial3: true,
  textTheme: baseTextTheme, primaryTextTheme: basePrimaryTextTheme),
```
Light theme only; no dark theme, no component themes (buttons/inputs/cards are styled per widget). App is wrapped in `Sizer` and `ToastificationWrapper`.

## Typography
- Font family `Montserrat`, declared in `pubspec.yaml`. Only one file is registered: `assets/font/Montserrat-Bold.ttf` (weight 700). Other weights used in code (w400/w500/w600) are therefore not bundled. Unclear - needs human clarification.
- No shared TextStyle constants. Styles are inline `TextStyle(fontSize: N.sp, fontWeight:, color: AppColors.*)`.
- Most-used sizes (grep counts): 10.sp (249), 11.sp (187), 12.sp (92), 13.sp (83), 9.sp (69), 9.5.sp (67), 14.sp (64), 10.5.sp (36), 15.sp (29), 8.5.sp (26).
- Example: footer text `11.sp w400 textMuted` (`lib/core/utils/admin_footer.dart`); dialog title `13.sp` (`logout_confirm_dialog.dart`).
- `sp` comes from the `sizer` package, so text scales with screen width (see RESPONSIVE_DESIGN.md).

## Spacing
No spacing tokens. Observed: fixed pixel `EdgeInsets`/`SizedBox` on admin (top bar padding `fromLTRB(h, 20, h, 16)`, `SizedBox(height: 16)`, footer `symmetric(horizontal: 24, vertical: 14)`); Sizer units (`1.5.w`, `0.5.h`) on user mobile and in some shared widgets. Admin horizontal page padding is `16` (<600 wide) or `24`.

## Radius
Counts of `BorderRadius.circular(n)`: 10 (212), 8 (105), 12 (93), 14 (72), 20 (31), 4 (19), 16 (17). Dialogs use 16; toasts 12 (`AppToast`).

## Elevation / shadow
Flat style: `elevation: 0` appears 45x; `elevation: 1` 6x, `2` 4x. `BoxShadow` blurRadius 12 (40x), 10 (15x), 16 (5x). Borders (`AppColors.border`, 1px) are used on structures, e.g. side drawer right border.

## Icons and assets
- `uses-material-design: true`; some Material icons (`Icons.download_rounded` in `AppSnackBar.showProgress`).
- SVGs in `assets/svg_icons/` (about 60, e.g. `home.svg`, `dashboard.svg`, `logout.svg`) rendered with `flutter_svg`: `SvgPicture.asset(..., colorFilter: ColorFilter.mode(AppColors.accent, BlendMode.srcIn))`. Reference via `ImageConstants` (`lib/core/constants/image_constants.dart`).
- Logos in `assets/logo/` (`ImageConstants.logo`, `webLoginLogo`, `webLogin3`), GIF `assets/gif/splash_logo.gif` (`splashGif`).
- Lottie: `assets/lottie/success.json` via `LottieConstants.success` (`lib/core/constants/lottie_constants.dart`), package `lottie`.
- Network images via `cached_network_image`; error placeholders `ImageConstants.imageError` / `videoError`.
- `pubspec.yaml` asset entries are directory-level (`assets/svg_icons/`, `assets/logo/`, `assets/gif/`, `assets/lottie/`), not recursive.

## Feedback colors
Toast styling in `lib/core/utils/app_toast.dart`: white background, `textPrimary` foreground, per-type primary color from `AppColors`.
