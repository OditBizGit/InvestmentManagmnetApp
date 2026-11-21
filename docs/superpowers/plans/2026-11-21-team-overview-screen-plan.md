# Team Overview screen - implementation plan and test cases

Spec: `docs/superpowers/specs/2026-11-21-team-overview-screen-design.md`. UI-only; no DB, no backend, so no Database Architect step and no API contract.

## Tasks (one Frontend Developer, sequential; all touch the same small feature)
| Task | Content | Verify |
|---|---|---|
| F1 | `pubspec.yaml` (+`assets/team/`), `ImageConstants` constants for 12 photos + 3 icons, `flutter pub get` | analyze; asset-existence test (TC-1) |
| F2 | `team_overview_data.dart` (3 sections, exact text) + `TeamSectionHeader` + `TeamMemberCard` (arch + cropped photo + text) | widget tests TC-2..TC-5 |
| F3 | `TeamOverviewScreen` (header, scroll body, rows, centered singles) | TC-6..TC-9 |
| F4 | Wire Profile tile `onTap` -> push `TeamOverviewScreen` | TC-10 |
| F5 | Docs: `USER_PROFILE.md` (+ CODEBASE_MAP/DOC_COVERAGE/DESIGN_SYSTEM assets mention where relevant) | docs diff reviewed |

Tests live in `test/user/profile/team_overview/` (new). Widget tests wrap the screen in `Sizer(builder: (_, __, ___) => MaterialApp(home: ...))`.

## Test-case document (Tester executes; developer writes the automated ones first)
| ID | Case | Expected | How |
|---|---|---|---|
| TC-1 | Every photo constant/ icon constant points to an existing non-empty file; all 12 photos listed in data resolve; `pubspec.yaml` declares `assets/team/` | pass | `flutter test` (reads files/pubspec) |
| TC-2 | Data: 3 sections; titles exact; counts 6/5/5; names and roles exact vs spec table (incl. en dash) | pass | unit test on const data |
| TC-3 | `TeamMemberCard` renders name (uppercase style) and role, an `Image.asset` for the member's asset; no `Image.network` anywhere in the feature folder | pass | widget test + grep |
| TC-4 | `TeamSectionHeader` shows icon (SvgPicture.asset) and title, fill `AppColors.accent`, radius 8 | pass | widget test |
| TC-5 | Photo crop: card image box = 149.25% x 160.73% of block, offset -24.63%/-23.31%, clipped; arch 94.6% wide, 12% opacity accent | pass | widget test on geometry (find sizes) |
| TC-6 | Screen shows 3 headers in order, 16 cards, 16 photos, all texts visible after scrolling | pass | widget test with `scrollUntilVisible` |
| TC-7 | Single cards (Anjali J, Mohamed Bava Eranhikkal) are one-column width and horizontally centered; pairs are two equal columns with 20-design-gap | pass | widget test geometry |
| TC-8 | No overflow/exceptions at 320x640, 360x800, 402x874, 430x932, text scale 1.0 and 1.3 (longest role: Anandha Kishore) | no `tester.takeException()` | widget tests |
| TC-9 | Header back arrow pops the route | pass | widget test with Navigator |
| TC-10 | Profile tile: tapping "Team Overview" navigates to the screen (test via a minimal harness or manual on device/emulator); other Profile tiles unchanged | pass | widget/manual |
| TC-11 | Visual comparison vs Figma screenshot at 402 wide (spacing, colours, crop, arch, fonts), light check at 360 | match / list of diffs | manual (Tester/Team Head) - emulator or `flutter run` user build |
| TC-12 | Regression: `flutter analyze` (no new issues vs baseline), `flutter test` full suite green | pass | CLI |
| TC-13 | Scope check: `git status` shows only files from spec section 4 + assets + docs + tests; `lib/main.dart` untouched by the team (PM-local `isAdmin=false` remains) | pass | git |

## Additions from QA review (2026-11-21)
- **TC-1 (extended):** each PNG is 1080x1080; each staged SVG uses only white colours (no `var(...)`).
- **TC-3/TC-5 (extended):** each card's `Image.asset` path equals that member's own constant (no swapped photo); `cacheWidth` is non-null and > 0; `errorBuilder` present.
- **TC-4/TC-6 (extended):** each section title is paired with the correct icon constant (match the `SvgPicture` asset name).
- **TC-8 (extended):** also text scale 2.0 (no-exception check only); synthetic very long role and unbreakable long name on a card at 320; missing-asset path shows no exception. Test setup: set `tester.view.physicalSize` + `devicePixelRatio` and reset in `addTearDown`; use `pump()` (not `pumpAndSettle`) with images; test fonts are Ahem, so wrapping checks are approximate and the manual 320 check stays.
- **TC-10 (changed):** manual on emulator/device with screenshot, plus review of the `onTap` line in the diff. Do not stub cubits inside production code. Rapid double-tap on the tile: manual, note the result (siblings behave the same).
- **TC-14 (new, AC7):** at 320x640 with `MediaQuery` bottom padding 34, scroll to the end: the last card (Mohamed Bava Eranhikkal) is fully visible above the bottom inset.
- **TC-15 (new, AC9):** QA reviews the docs diff against the files named in spec AC9.
- **Baselines (before any edit):** `flutter analyze` = 68 issues (recorded by Team Head, 2026-11-21); `flutter test` baseline = 56 pass, 1 fail, recorded by Team Head 2026-11-21 before any edit; the one pre-existing failure is `test/core/no_sensitive_logging_test.dart` (scans `lib/` for log calls that print bodies/auth; not caused by this task, but the new code must add no log calls) (note that `test/widget_test.dart` pumps `MyApp` and the working tree has PM-local `isAdmin=false`). Pass = no new analyze issues, no new test failures.

## Gates
- PM-only items: none open (design source given, hardcoded data approved in the request, no new package, no schema).
- Security check (QA): no network image, no URL launching, no secrets, no data/logging added; asset-only.
- Baseline for analyze: record `flutter analyze` result before edits so "no new issues" is measurable.
