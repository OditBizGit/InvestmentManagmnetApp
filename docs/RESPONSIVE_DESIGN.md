# Responsive Design

Source of truth: code in `lib/`. No central breakpoint class exists; thresholds are literals repeated in widgets. Nothing here is a proposal.

## Targets
- Admin app (`isAdmin = true` in `lib/main.dart`): web/desktop, rooted at `lib/admin/navigation/admin_main_screen.dart`; has `kIsWeb` checks.
- Investor app (`lib/user`): mobile, locked to portrait via `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` in `lib/main.dart` (~line 83, non-admin init branch). Layouts therefore do not handle orientation.
- Whole app is wrapped in `Sizer(builder: (context, orientation, screenType) ...)` (`lib/main.dart`); the `orientation`/`screenType` args are unused.

## Techniques
1. Sizer units (`sizer` ^3.1.3): `.sp` font sizes, `.w`/`.h` percentages. About 2,000 usages in both apps.
2. `LayoutBuilder` + `constraints.maxWidth` (admin): per-widget thresholds, about 50 admin files.
3. `MediaQuery`: `size.width` in e.g. `lib/auth/admin_web_login_screen.dart`; `MediaQuery.textScalerOf` in `lib/user/home/widgets/top_investors_carousel.dart`.
4. `Wrap`/`GridView` in ~21 files; `SafeArea`/`viewInsets` in ~26 files.
5. `ScrollConfiguration(... scrollbars: false)` in admin main screen (comment there warns not to use `scrollbars: true`).

## Breakpoint literals found (grep, by frequency)
`<600` (27), `<560` (18), `>=560` (13), `<980` (7), `<640` (7), `<760` (6), `>=900` (7), `>=420` (5), `<900` (5), `<520` (4), `>=720`/`<720`, `>=700`, `>=1100`, `<1100`, `<820`, `<420`, `<480`. Drawer uses `1050`/`1180`. There is no single canonical set; the applicable value depends on the widget. Unclear - needs human clarification whether any are intended standards.

Most consistent ones:
- `constraints.maxWidth < 600 ? 16.0 : 24.0` = admin screen horizontal padding (`dashboard_screen.dart`, `investors_screen.dart`, others), passed to `AdminMainScreenLayout(horizontalPadding:)`.
- `constraints.maxWidth < 560` = compact top bar (`lib/core/utils/admin_top_bar.dart`, `isCompact`).
- Login: `cardWidth = (size.width * 0.34).clamp(360.0, 460.0)`; padding `size.width < 1100 ? 32 : 64` (`lib/auth/admin_web_login_screen.dart`).

## Admin adaptive navigation
`lib/admin/navigation/admin_main_screen.dart`:
- `AdminMainScreen.collapseBelow = 1050`, `expandAbove = 1180` (hysteresis to avoid Chrome scrollbar width flicker); `_syncCollapsedForWidth(width)` sets `_isCollapsed`.
- `AdminSideDrawer` (`admin_side_drawer.dart`): `sidebarWidth = 248`, `collapsedWidth = 72`; icon 20 compact / 24 expanded; `animate: !kIsWeb`.
- Layout: `Row[AdminSideDrawer, Expanded(Column[Expanded(IndexedStack of screens), AdminFooter])]`. There is no hamburger/modal drawer: below 1050 the sidebar only shrinks to icons.
- `IndexedStack` keeps all tab screens alive; each gets an `isActive` flag.
- Role-based drawer items: `lib/admin/navigation/admin_nav_permissions.dart`.

## Admin page layouts
- Shell: `AdminMainScreenLayout` (`lib/core/utils/admin_main_screen_layout.dart`) = padded `AdminTopBar` + optional `AdminRefetchProgressBar` + body.
- Page background: `ColoredBox(color: AppColors.screenBg)` wrapping a `LayoutBuilder`.
- Overview cards and tables use `LayoutBuilder` per module (`*_overview_section.dart`, `*_table_section.dart`).
- Add/edit forms: form column plus fixed right side panel (`AddInvestorSidePanel`, `add_fund_side_panel.dart`).
- Dialogs constrain width (`ConstrainedBox(maxWidth: 300)` in `showLogoutConfirmDialog`).

## User (mobile) layouts
- Bottom nav `lib/user/navigation/user_bottom_nav.dart` (`UserBottomNav`, height `8.h`, icon boxes `9.w`/`5.5.w`); tabs in `user_main_screen.dart`, with `TabReselectNotifier`.
- Sizing is Sizer-based, no width breakpoints; designed for portrait phones. Tablet behavior: Unclear - needs human clarification.
- `GoToTopButton` (`lib/core/utils/go_to_top_button.dart`) appears on scroll.

## Text scaling
No global `textScaler` override; size follows Sizer `.sp`. Receipt/PDF code uses `TextScaler.noScaling` (`lib/user/investments/transaction_receipt_screen.dart`).

## Orientation
User: portrait locked. Admin: unconstrained; no orientation-specific code found.
