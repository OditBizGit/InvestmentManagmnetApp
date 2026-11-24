# Decisions Log

Format: date — decision — approved by — status.

## 2026-11-24 — Staff name on Pending Request card (spec: docs/superpowers/specs/2026-11-24-pending-request-staff-name-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| S1 | Show the investor's staff name(s) on `PendingRequestCard`; additive `staffName` column on `GetPaymentRequests` (Action 18), no schema change, no new endpoint | PM | Approved |
| S2 | Current staff (not staff at request time); both names when two staff ("A, B", primary first); fallback to `AssignedStaffId` when no allocation rows | PM (defaults approved with plan) | Approved |
| S3 | Backend repo `investmentmanagmentAppApi` edited as part of this task; SQL applied to local DB only, server deploy by PM | PM | Approved; local DB verification T1-T5 passed 2026-11-24 (procedure applied to local `MARIBEL_WELLNESS_CENTRE` only; server deploy by PM pending) |

## 2026-11-23 — High-priority finance reports (spec: docs/superpowers/specs/2026-11-23-high-priority-reports-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| R1 | Scope: 5 reports - Collection Aging, Investor Statement, Staff allocation (extends Staff Report), Expected vs Actual collections, Refund & Termination | PM | Approved |
| R2 | Design source = existing Reports screens (Overview stat cards + Staff Report table/period filter/search); no new visual design | PM | Approved |
| R3 | New items go in the drawer Reports group, Admin/SuperAdmin only; staff allocation extends the existing Staff Report (no new drawer item) | PM | Approved |
| R4 | No commission rate exists; staff report shows existing data only: received, allocated share by %, refunds, net, investor count. No new table | PM | Approved |
| R5 | Aging buckets: Not yet due, 1-30, 31-60, 61-90, 90+ days past each unpaid installment's effective due date; payments applied oldest-first (same rule as Due Payments) | PM | Approved |
| R6 | Investor Statement: on screen + client-side PDF with the existing `pdf` package; one new data API; no new package | PM | Approved |
| R7 | Expected vs Actual: Expected = installments falling due in the month; Actual = payments dated in the month minus refunds in the month; rate = actual/expected; monthly rows, max 12-month range, per-investor breakdown for a month | PM | Approved |
| R8 | Backend tests: Verify_*.sql script per new procedure + HTTP smoke tests on the API running against the local database; no new test project | PM | Approved |
| R9 | Frontend: one folder per report under `lib/admin/reports/` (`collection_aging`, `expected_vs_actual`, `refund_termination`, `investor_statement`) mirroring `staff_report/`; cubit created by the screen with `getIt<Dio>()` (no get_it registration); pieces only the new reports use go in `lib/admin/reports/shared/`; existing Overview/Staff Report code is not moved | Team Head (Solution Architect option B) | Approved |
| R10 | State: sealed states for single-load screens (Collection Aging, Refund & Termination); single immutable status-enum state with `copyWith` for list + drill-down screens (Expected vs Actual, Investor Statement), matching `StaffReportState` | Team Head (Solution Architect) | Approved |
| R11 | Staff Report list columns (allocated share, refunds, net, investor count) come from additive columns on `Api_StaffReportList`; no per-staff detail calls from the client | Team Head | Approved |
| R13 | DB design: 6 read-only procedures (`Api_CollectionAgingReport`, `Api_ExpectedVsActualCollections`, `Api_ExpectedVsActualCollectionsDetails`, `Api_RefundTerminationReport`, `Api_InvestorStatement`) + additive columns on `Api_StaffReportList`; no new table, no index, no destructive change; schedule logic copied from `Api_InvestorPaymentStatusReport`; FundingPaymentOverview (Action 14) not reused | Team Head (Database Architect) | Approved; live check on local restore pending |
| R14 | Aging/Expected-vs-Actual population: active + blocked investors; settled investors have 0 outstanding and no installments due after settlement date; future `@AsOfDate` rejected | Team Head (Database Architect) | Approved |
| R15 | Staff `InvestorCount` = distinct investors with payment/refund events in the period; `ReceivedAmount` is gross per staff (shared investors appear under each staff) - labelled "Received (gross)" in UI | Team Head | Approved |
| R16 | Terminated date = ReviewedDate of latest Approved block request, else `UserRegistration.ModifiedDate`, with a `DateSource` flag; investors unblocked later drop out (no history) | Team Head (Database Architect) | Approved |
| R17 | Widen `#List` in `Verify_StaffReportHistoricalAllocation.sql` to match the new `Api_StaffReportList` columns | Team Head | Approved |
| R18 | Local test DB: PM provides a .bak/.bacpac; restore locally as `MARIBEL_WELLNESS_CENTRE_TEST` on `.\SQLEXPRESSMICTCO`; coding starts now, DB verification and API smoke tests wait for the file; remote server never used | PM | Superseded by R31 |
| R19 | Staff Report list keeps the existing "Total Amount" column (= net, unchanged) and adds Received (gross), Allocated, Refunds, Investors; no separate duplicate Net column | Team Head | Approved |
| R20 | Search on new report screens is client-side (like Staff Report); the API `search` parameter exists but the app does not send it; server rejects search > 100 chars (400) | Team Head | Approved |
| R21 | Period (This/Last Month/Custom) → from/to conversion in `lib/admin/reports/shared/report_period_range.dart` (F1); 400/404 errors show the server `message` (via `lib/core/utils/api_error_message.dart`), never raw Dio text | Team Head | Approved |
| R22 | `collectionRate` returned with 2 decimals; UI shows 1 decimal with `%`, "—" when null | Team Head | Approved |
| R23 | Investor Statement picker uses `InvestorsRepository.getInvestors` (from get_it if registered, else created with `getIt<Dio>()`) | Team Head | Approved |
| R24 | Month range cap = 12 months inclusive (To ≤ From + 11 months) in `shared/month_range_picker.dart`, matching the backend 50009 rule; Overview's own picker is not changed | Team Head | Approved |
| R25 | Staff details: existing "Amount Received" column (net) unchanged; added Allocation %, Allocated, Refund Amnt; no duplicate "Net" column (same reason as R19). "This Month" = 1st of month to today, matching the backend Staff period rule | Team Head | Approved |
| R26 | Multi-result-set report procedures get a trailing optional `@ResultSet TINYINT = NULL` (NULL = all sets) so Verify scripts can capture one set via INSERT…EXEC; API calls never pass it | Team Head | Approved |
| R27 | `ApiErrorMessage.from` gains a ProblemDetails fallback (after `message`: first `errors` entry, then `title`); the private error mappers in the 4 new report cubits are removed and use it | Team Head | Approved |
| R28 | Statement PDF shows only what the screen shows (drop Gross Paid and Refunds from the PDF summary) | Team Head | Approved |
| R29 | Collection Aging: the app omits `asOfDate` when the chosen date is today, so the server uses its own date (avoids device/server timezone 400s); `ReportController` logs unexpected exceptions server-side (no request data) | Team Head | Approved |
| R30 | Edits found in `lib/main.dart` (`isAdmin = true`) and Manage Users → `GetAllInvestors` (`manage_users_repository.dart`, `api_endpoints.dart` line 7) are not part of this phase; left untouched and excluded from the phase commit; PM to confirm | Team Head | Waiting for PM |
| R31 | DB verification and API smoke tests run on the PM's existing local database `MARIBEL_WELLNESS_CENTRE` on `FAEZLAPTOP\SQLEXPRESSMICTCO` (this machine, checked by `@@SERVERNAME`), not on a restored copy; the live server is never used. The previous `Api_StaffReportList` definition is saved before deploying. The PM's `appsettings.json` switch to the local server is excluded from the phase commit (2026-11-23) | PM | Approved |
| R32 | TC03 403 checks for FinancialManager, MarketingManager and Investor are skipped (no local logins); the role gate rests on `[Authorize(Roles="Admin,SuperAdmin")]` on `ReportController`, confirmed in QA code review. TC03 is run with SuperAdmin (200), no token and bad token (401) only (2026-11-23) | PM | Approved |
| R33 | TC17a/TC17b (Investor Statement PDF export on web and Windows), TC23 (visual regression) and the TC13 period buttons are run manually by the PM; the app is not re-pointed to the local API by the team. Phase sign-off waits on the PM's result (2026-11-23) | PM | Approved |
| R34 | Live SQL deploy is run by the PM, not the team: backend `Sql/Deploy_HighPriorityReports_2026-11-23.sql` (pre-check of version, target DB, 9 tables / 55 columns / 4 functions; saves the current `Api_StaffReportList`; creates the 6 procedures; lists missing per-object EXECUTE grants) and `Sql/Rollback_HighPriorityReports_2026-11-23.sql`. Tested deploy → rollback → deploy and pre-check failure on the local server only; Database Architect: Approve. Order: SQL before the new API build; rollback API before SQL (2026-11-23) | PM / Team Head | Approved |
| R35 | PM change request: (a) Staff Report frontend restored to its pre-phase state (list + details); supersedes the UI parts of R19 and R25 — the backend still returns the extra staff columns and the app ignores them; (b) Collection Aging navigation commented out (enum value, drawer entry, `_screenFor` case, import, nav-test entries) under the marker `// PM 2026-11-23: Collection Aging hidden for now — uncomment to restore.`; screen, tests, API and SQL kept; the open question whether Aging should exclude blocked investors is parked until it is restored; (c) drawer icons: Expected vs Actual `total_collection`, Refunds & Terminations `disable_user`, Investor Statement `investment_details`, Collection Aging `time_line` (in the commented block). QA: Ready (2026-11-23) | PM | Approved |
| R12 | Statement PDF is a web-safe helper on the `ManageUsersExportFile` pattern (`pdf` MultiPage + `saveExportFile`), not `TransactionReceiptPdf` (uses dart:io) | Team Head (Solution Architect) | Approved |
| R36 | Manage Users list uses `GetAllInvestors?status=all\|blocked`; chips Active (= `all`) and Blocked, All chip dropped; supersedes R30 for the `GetAllInvestors` switch (PM confirmed it is intended); `isAdmin = true` in `main.dart` still open; the Total / Active / Blocked cards keep showing real totals: they use both lists (2 parallel calls on load / re-activation; a chip switch does not refetch for the cards); approving a termination moves the row out of Active and Active -1 / Blocked +1; an export's progress flag survives chip refetches. QA: Ready; open minor: an unblock still in flight during a chip switch can double-count one investor until the next refresh. Values `all` / `blocked` come from the PM — the updated backend is not in this checkout, so not tested against the real API | PM; cards: Team Head | Approved (2026-11-23) |

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
