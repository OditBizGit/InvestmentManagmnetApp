# Decisions Log

Format: date — decision — approved by — status.

## 2026-11-21 — Team Overview screen, user Profile (spec: docs/superpowers/specs/2026-11-21-team-overview-screen-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| T0 | UI-only screen from Figma frame `376:3233`; hardcoded content (the PM-approved exception to the no-mock-data rule); no API, model, repository, service or DI change | PM (request) | Done |
| T1 | Project font Montserrat instead of the Figma font Poppins (design system not changed, Poppins not bundled) | Team Head | Done |
| T2/T6 | Header stays inline like the sibling sub-screens (no shared widget exists; extracting it would touch unrelated screens) | Team Head (Solution Architect) | Done; tech debt noted |
| T3 | Hardcoded data in a `const` file inside the screen folder, not in `model/` | Team Head (Solution Architect) | Done |
| T4 | Original 1080x1080 PNGs kept unedited and cropped in code like Figma; bundle +~9 MB; `cacheWidth` caps decode memory | Team Head | Done; compression is a later option |
| T5 | New asset folder `assets/team/` declared in `pubspec.yaml`; icons in the existing `assets/svg_icons/` | Team Head | Done |
| T7 | Card = AspectRatio > LayoutBuilder > ClipRect > Stack with fractional positions; runtime card width (no fixed 171) | Team Head (Solution Architect) | Done |
| T8 | Text sizes use `.sp` values chosen for Sizer 3.1.3's quadratic scale (12 px -> 14.sp, 10 px -> 12.7.sp); found in the visual check, spec corrected | Team Head | Done |

## 2026-11-09 — Security hardening (plan: docs/plans/SECURITY_HARDENING_PLAN.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| D1 | API moves to HTTPS on a domain; remove `usesCleartextTraffic` and switch `kBaseUrl` to https once backend is ready | PM | Planned (backend) |
| D2 | Backend enforces roles per endpoint from the JWT and rejects mismatched `userRole` at login; client role checks only hide UI | PM | Planned (backend) |
| D3 | Investor mobile/desktop store auth + refresh tokens in `flutter_secure_storage`; admin web keeps SharedPreferences until backend issues HttpOnly Secure cookies | PM | Done (client) |
| D4 | New dependency `flutter_secure_storage ^9.2.4` | PM | Approved |
| D5 | Android `allowBackup="false"` | Team Head | Done |
| D6 | Global 401 handling = clear session + go to login (no refresh flow); only when the failed request carried the current token | PM (logout only) / Team Head (token match) | Superseded by D7 (logout now happens only after the refresh token is rejected) |
| D7 | Refresh-token flow: proactive refresh shortly before access-token `exp`, reactive 401 refresh + single replay, one shared in-flight refresh, best-effort `POST /api/User/Logout` on logout; logout only when the refresh token is rejected | PM (2026-11-10) | Done (client); backend `Jwt:EnforceExpiry` stays off until this app version is released |
| D7 | Release signing (M1) left on debug key for now | PM | Open finding |
| D8 | All client-only fixes (H1 mobile, M2, M3, L1–L3) implemented in one batch | PM | Done |
| D9 | CSV export neutralises leading `= + - @ \t \r`, except purely numeric values | Team Head | Done |
| D10 | Secure-storage write failure keeps token in memory only (not plaintext prefs); session lost on restart | Team Head | Done |
| D11 | Commit: the seven files that mix security fixes with earlier PM edits are committed whole | PM | Approved |
