# Team Overview screen (user app, Profile) - design spec

Date: 2026-11-21 | Status: approved by PM request (UI-only, hardcoded data) | Owner: Team Head

## 1. Goal
Make the existing "Team Overview" tile on the investor Profile tab open a new, static "Team Overview" screen that matches the Figma frame **Team Overview** (`376:3233`, file `EKZdPubnXE1EI8ObXiQPdL`, section `17:14659`). UI only: hardcoded content, local asset photos, no API, repository, model, service or cubit.

## 2. Findings (existing code)
- `lib/user/profile/profile_screen.dart` already has `_MenuTile(label: 'Team Overview', iconPath: ImageConstants.team, onTap: () {})` - the handler is empty. Sibling tiles use `Navigator.of(context).push(MaterialPageRoute(...))`.
- Sub-screen pattern (`PersonalInfoScreen`): `Scaffold(white) > SafeArea > Column[ back-arrow + title row (InkWell, pop), Expanded(SingleChildScrollView(padding 5.w)) ]`.
- Colors already in `AppColors`: `accent` = `#A28CC1` (Figma "Invt Main Color"), `textPrimary` = `#3D3D3D`, `textMuted` = `#888888`, `white`.
- Font: project font is Montserrat (theme-wide). Figma uses Poppins. Poppins is not bundled.
- Sizer is used everywhere (`.w`, `.h`, `.sp`). Asset paths are constants in `lib/core/constants/image_constants.dart`. `pubspec.yaml` declares asset folders (`assets/svg_icons/`, `assets/logo/`, ...).
- Tests: minimal (`test/core/*`, `test/widget_test.dart`).

## 3. Design (from Figma, design width 402, content padding 20 => content width 362)
Screen = header + one vertically scrolling body.

**Header** (fixed): back arrow + "Team Overview" (Figma 16 Medium, `#3D3D3D`). Reuse the sibling sub-screen header pattern (same look as Personal Info) - no new component. The Figma status bar (9:41, signal) is a design mock, not built.

**Body** (padding 20 horizontal, first content ~12 below header, vertical gap between blocks 12):

| # | Block | Content |
|---|---|---|
| 1 | Section header "Board Members" | icon `ci:users` |
| 2-4 | 3 rows x 2 cards | Shameer - Founder & MD; AZARUDHEEN - Co-Founder & Director; MOHAMMED ALI - Director; MOIDEEN - Director; Dr. FIDHA FATHIMA - Director; MUSTHAFA - Director |
| 5 | Section header "Doctors Panel" | icon `fluent:briefcase-medical` |
| 6-8 | row, row, 1 centered card | Dr. NAEEMA - MBBS, MD (PMR), 10 Years Exp – Alshifa and Aster MIMS; Dr. ANANDHA KISHORE - Sr. Chief Ayurvedic Physician, 26 Years in Kottakkal Arya Vaidya Sala, - Ex Chief Medical Officer; Dr. FIDHA FATHIMA - MBBS, POCERT in Medical Education; Dr. SURABHILA - Sr. Ayurveda & Postnatal Consultant; Dr. ANJALI J (centered, single) - BAMS, Ayu. Cosmetology & Yoga Specialist |
| 9 | Section header "Advisory Committee Membership" | icon `uix:loyalty-member-count` |
| 10-12 | row, row, 1 centered card | Dr. NAEEMA, Dr. ANANDHA KISHORE (same as Doctors Panel); RANJITH PALLYATH - Hospitality Consultant, 25 Years Exp in Ritz Carlton and Marriott, Saudi; Dr. SURABHILA (same); MOHAMED BAVA ERANHIKKAL (centered, single) - Chief Administrative Officer |

Text is exactly as in Figma (names are rendered uppercase; keep the source casing/characters, including the en dash in "10 Years Exp – Alshifa"). Some people appear in more than one section, as in Figma - reuse one entry per person.

**Section header pill**: full width, fill `AppColors.accent`, radius 8, padding h10 v8, row [icon 18, gap 8, text 12 SemiBold white].

**Team member card** (card width computed at runtime = (content width - column gap) / 2, e.g. 171 at 402; never a literal 171, so it holds at 320 and 430; a centered single card uses the same computed width):
- Photo block: `AspectRatio(aspectRatio: 171 / 158.1)` (width / height). Inside: `LayoutBuilder(w, h) > ClipRect > Stack(clipBehavior: Clip.hardEdge)`.
  - Arch: `Positioned(left: .027w, top: .181h, width: .946w, height: .819h)`, top corners radius 99 (full semicircle), fill `AppColors.accent` at 12% opacity.
  - Photo: `Positioned(left: -.2463w, top: -.2331h, width: 1.4925w, height: 1.6073h)` holding `Image.asset(fit: BoxFit.cover)` (Figma crop; box is square-ish so cover = no visible distortion). Photo is drawn over the arch.
  - Decode with `cacheWidth = min(1080, (1.4925 * w * devicePixelRatio).round())` (box width, not block width); set `cacheWidth` only. Gives ~28 MB decoded for 12 photos at 3x instead of ~56 MB.
- 10 gap, then name (12 SemiBold, uppercase via `toUpperCase()` at render, `#3D3D3D`, centered) and role (10 Regular, `#888888`, centered). The Figma -2 name/role overlap is done with a tight `TextStyle.height`, not a negative offset or Stack. No `maxLines`, no ellipsis: long text wraps.
- Two-card row: `Row(crossAxisAlignment: start)` with two `Expanded` cards and a gap between (20 design px = `5.w`); row height = tallest card; no `IntrinsicHeight`.
- Section pill title is wrapped in `Expanded` with soft wrap (so "Advisory Committee Membership" cannot overflow at 320 / text scale 1.3).

**Type/size mapping**: layout dimensions as proportions of the 402 design width (`.w`, or LayoutBuilder fractions). Text via `.sp`, but **Sizer 3.1.3 `.sp` is quadratic** (measured at 402x874: `sp(v) = v*v*0.0618` px, so 11.sp = 7.5 px, 15.sp = 13.9 px), not linear. To hit the Figma size at 402 wide: 12 px -> `14.sp` (12.1 px), 10 px -> `12.7.sp` (10.0 px). The header stays as the siblings (`15.sp` = 13.9 px, consistent with the other screens; Figma 16 px). Montserrat via theme (no explicit family), weights as in Figma (w600 names, w400 roles, w600 header as sibling). Vertical rhythm at 402: pill height ~34 px (~8.45.w), name line ~16 px, role line ~15 px, name-to-photo gap 10 px.
*(Correction 2026-11-21: the first version of this spec assumed a linear mapping (12 -> 11.sp, 10 -> 9.sp). It rendered 7.5 px / 5 px text and was fixed after the visual check.)*

**Assets** (all local, no network):
- `assets/team/*.png` (new folder; add `- assets/team/` under `flutter: assets:` in `pubspec.yaml`): `shameer`, `azarudheen`, `mohammed_ali`, `moideen`, `fidha_fathima`, `musthafa`, `naeema`, `anandha_kishore`, `surabhila`, `anjali_j`, `ranjith_pallyath`, `mohamed_bava_eranhikkal` (12 unique photos, original 1080x1080 export from Figma, unedited). Already staged by Team Head.
- `assets/svg_icons/team_board_members.svg`, `team_doctors_panel.svg`, `team_advisory_committee.svg` (already declared folder). Already staged by Team Head. Do not override their root width/height (18x18) with broad 100% sizing; do not tint (they are white strokes for the accent pill - verify colour in the file).
- Constants in `ImageConstants` (e.g. `_teamPath = 'assets/team'`).

## 4. Code structure
```
lib/user/profile/screens/team_overview_screen/
  team_overview_screen.dart          TeamOverviewScreen (StatelessWidget): header + scroll body
  team_overview_data.dart            const hardcoded sections + members (plain const classes; NOT a model/repository)
  widgets/team_section_header.dart   TeamSectionHeader(iconPath, title)
  widgets/team_member_card.dart      TeamMemberCard(member) : arch + photo + texts
  widgets/team_member_row.dart       (optional) two-card row / centered single, if it keeps the screen file clean
```
- No Cubit, no BlocProvider, no get_it, no Dio. The screen is const-constructible.
- `profile_screen.dart`: only change = Team Overview tile `onTap` pushes `TeamOverviewScreen` with `MaterialPageRoute` (same style as siblings). Add the import.
- `ImageConstants` gets the new path constants. `pubspec.yaml` gets `assets/team/`.
- Back header: follow the sibling inline pattern exactly (arrow `5.5.w`, title `15.sp` **w600**, `AppColors.textPrimary`). No shared back-header widget exists (checked by Solution Architect; the pattern is already inline in ~5 user screens). Do NOT extract one now: that would touch unrelated screens. Recorded as tech debt.
- Constants in `ImageConstants` use a `team` prefix to avoid clashing with the existing `ImageConstants.team` menu icon (e.g. `teamShameer`, `teamBoardMembersIcon`).
- Missing-asset behaviour: `Image.asset` gets an `errorBuilder` that shows nothing (empty box, no exception); asset existence is guaranteed by test TC-1.

## 5. Out of scope / restrictions
No backend, API, repository, model, service or DI changes. No change to other screens, `isAdmin`, or `lib/main.dart` (the working tree has a PM-local `isAdmin = false`; never commit/revert it). No new packages. No network images. No placeholders.

## 6. Decisions (Team Head, 2026-11-21, within approved scope)
| # | Decision |
|---|---|
| T1 | Use project font Montserrat, not Poppins: the design system is not changed without approval (rule 12); Poppins is not bundled. |
| T2 | Reuse the sibling sub-screen header instead of a new header: matches the other Figma screens that use the same header. |
| T3 | Hardcoded data lives in a `const` data file inside the screen folder, not in `model/`: the PM said no model/repository/service. This is the PM-approved "hardcoded data" exception to the no-mock-data rule. |
| T4 | Keep original 1080 PNGs and crop in code like Figma (no pre-editing of assets); bundle size +~9 MB accepted. Tell the PM; compression is a later option. |
| T5 | New asset folder `assets/team/` declared in `pubspec.yaml` (the only pubspec change). |
| T6 | Header stays inline (sibling pattern, w600 15.sp); extraction is tech debt, not done now (Solution Architect, accepted by Team Head). |
| T7 | Card widget approach and cacheWidth rule as in section 3 (Solution Architect review, accepted). |

## 7. Acceptance criteria
1. Tapping Profile > Team Overview opens the Team Overview screen; back arrow returns to Profile.
2. Three sections in order with the exact titles and icons; 6 + 5 + 5 cards with exact names and roles (see table).
3. Each card shows its own local photo with the lavender arch behind it and the Figma crop; photos are sharp (no network, no placeholder).
4. Two-column rows aligned at the top; last card of Doctors Panel and Advisory Committee is single and horizontally centered at one-column width.
5. Visual match to the Figma screenshot at 402 wide: spacing, colours, radius, typography proportions.
6. No overflow/exception at widths 320, 360, 402, 430 and text scale 1.0 / 1.3; long roles wrap, never clip or throw.
7. Whole body scrolls to the bottom with bottom safe-area padding; pull-to-refresh not required.
8. `flutter analyze` introduces no new issues; `flutter test` passes; no files outside the list in section 4 (plus docs) change.
9. Docs updated (`docs/modules/USER_PROFILE.md`, `docs/CODEBASE_MAP.md` / `DOC_COVERAGE.md` / `DESIGN_SYSTEM.md` assets note if they list these items).
