# UI Implementation Guide

How to build new UI consistent with existing code. See DESIGN_SYSTEM.md, UI_COMPONENTS.md, RESPONSIVE_DESIGN.md.

## Rules
1. Colors only from `AppColors` (`lib/core/constants/app_colors.dart`); icons/images via `ImageConstants` / `LottieConstants`.
2. Text: Montserrat comes from the theme; use `fontSize: N.sp` (`package:sizer/sizer.dart`) and `AppColors.textPrimary/textSecondary/textMuted`.
3. Corners 8/10/12/14/16, flat (`elevation: 0`), 1px `AppColors.border` outlines.
4. Imports: `package:maribel_wellness_centre_application/...`.
5. State: `flutter_bloc` cubits; on failure call `AppToast.error(state.message, context: context)`.

## New admin tab screen (from `lib/admin/dashboard/dashboard_screen.dart`)
```dart
return ColoredBox(
  color: AppColors.screenBg,
  child: LayoutBuilder(builder: (context, constraints) {
    final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;
    return AdminMainScreenLayout(
      horizontalPadding: horizontalPadding,
      showRefetchProgress: showRefetchProgress,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _onRefresh,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(controller: _scrollController /* ... */),
        ),
      ),
    );
  }),
);
```
Register a new tab in `AdminDrawerItem` (`admin_side_drawer.dart`), `_screenFor` in `admin_main_screen.dart`, and `admin_nav_permissions.dart`. Use `AdminInitialLoadingBody` or shimmer for first load, `AdminRefetchProgressBar` for refetch with cached data.

## Compact vs wide inside a widget (from `admin_top_bar.dart`)
```dart
return LayoutBuilder(builder: (context, constraints) {
  final isCompact = constraints.maxWidth < 560;
  ...
});
```
Reuse thresholds already used by sibling widgets in the same module rather than adding new ones.

## Dialog (from `lib/core/utils/logout_confirm_dialog.dart`)
```dart
final confirmed = await showDialog<bool>(
  context: context,
  barrierDismissible: true,
  builder: (dialogContext) => Dialog(
    backgroundColor: AppColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: /* Padding > Column(mainAxisSize: MainAxisSize.min) */,
    ),
  ),
);
```
For confirmations see `admin/user_management/widgets/user_management_confirm_dialog.dart`; for reason/remarks input see `reject_payment_request_dialog.dart`.

## Feedback
- Toast: `AppToast.success(message, context: context)`, `.error`, `.info` (check exact signature in `core/utils/app_toast.dart`).
- Snackbar: `AppSnackBar.show(context, message: '...')`; downloads: `AppSnackBar.showProgress(context, onCancel: ...)` then call `update`/`close` on the returned controller.

## Shimmer (`admin/dashboard/widgets/dashboard_shimmer.dart`)
```dart
DashboardShimmer.wrap(
  child: DashboardShimmer.box(height: 80, radius: 12),
)
```

## Icons
```dart
SvgPicture.asset(
  ImageConstants.logout, width: 20, height: 20,
  colorFilter: const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
);
```
New SVGs go in `assets/svg_icons/` (registered) plus a constant in `ImageConstants`.

## Forms (add investor / add fund pattern)
Form cards on the left, fixed side panel with Cancel/Submit on the right: `AddInvestorSidePanel(onCancel:, onAdd:, isLoading:, isEditing:)`.

## User mobile screens
Size with Sizer (`4.w`, `1.h`, `12.sp`), assume portrait, use `GoToTopButton` on long scrolls and `TabReselectNotifier` for tab reselect scroll-to-top.

## Gaps to be aware of
- Only `Montserrat-Bold.ttf` is registered in pubspec.
- No shared empty-state or text-field widget, no dark theme, no bottom sheets, no central breakpoints. Confirm with a human before introducing any of these.
