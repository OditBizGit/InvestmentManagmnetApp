# Decisions Log

Format: date — decision — approved by — status.

## 2026-11-25 — Web fixes: receipt download and MOU/LLP upload

| # | Decision | Approved by | Status |
|---|---|---|---|
| WF1 | Root cause, receipt download: `TransactionReceiptPdf.download` saved the PDF with `dart:io` `File`, `path_provider` and `OpenFilex`, none of which work in a browser, so nothing was downloaded on web. Fix: when `kIsWeb`, build the same PDF and save it with the existing `saveExportFile` (browser Blob + anchor download, already used by exports and the investor statement). File name logic moved to `fileNameFor` (same name as before). Non-web path unchanged. `download` now returns `Future<void>` (no caller used the file). | PM request 2026-11-25 | Implemented, QA Ready |
| WF2 | Root cause, MOU/LLP upload: in file_picker 8.3.7 `PlatformFile.path` throws on web, so `UserStatusCheckboxCard._pickFile` aborted before staging the picked file and there was nothing to upload. Fix: read `path` inside try/catch (null on web); the picked bytes (`withData: true`) were already used by the upload chain, which is web-safe (`MultipartFile.fromBytes`). No change to cubit, repository, API or backend. | PM request 2026-11-25 | Implemented, QA Ready |
| WF3 | Not verified yet: manual browser check of both flows (Chrome, local API), and the web compile result (see report). Known low items: the web saver is chosen by `dart.library.html`, so a `--wasm` build would need a different saver (pre-existing for all exports); the user-side receipt file now imports an admin util (precedent exists); signature image in the PDF needs CORS on web; for a staged non-image file on web the view icon says it cannot open it until uploaded (pre-existing). | QA review | Open |

## 2026-11-25 — Receipt message while approving a payment request (spec: docs/superpowers/specs/2026-11-25-approve-receipt-loading-message-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| AR1 | While a payment request is approved on the review screen, the loading overlay also shows "Please wait... Sending email receipt and app receipt." until the approval call returns. UI only: a local `_isApproving` flag in `ReviewRequestScreen`; no cubit, repository, API or backend change. | PM (request 2026-11-25) | Implemented, QA Ready |
| AR2 | Approve only. The backend sends the "Payment Received" push notification, the PDF receipt and the email inside the one `ReviewPaymentRequest` call, awaited before it responds, so the existing `isReviewSubmitting` window covers them. Reject sends no receipt, so Reject keeps the spinner-only overlay (the PM asked that the message reflect the real process). | Team Head, from the PM's accuracy requirement | Recorded |
| AR3 | Duplicate clicks stay blocked by the opaque overlay, disabled buttons, the cubit's `isReviewSubmitting` guard and a new re-check after the confirm dialog. The flag resets in `finally` for success, DioException and other errors. Receipt failures are swallowed by the backend, so a receipt failure still ends as a successful approval. | QA review | Recorded |
| AR4 | Test gaps found by QA and tester were closed: R12 covers the two-confirm-dialog re-check, and R3/R4 now prove the flag reset (each verified by removing the guard and seeing the test fail). Tester: 12 new tests pass, 59 in the three related folders, full suite 3 known unrelated failures, `flutter analyze` still 68 (none in touched code). Still open: no manual visual check on web or mobile. | QA review, tester | Closed, visual check open |

## 2026-11-25 — SuperAdmin read-only Monthly List and Pending Requests (spec: docs/superpowers/specs/2026-11-25-superadmin-readonly-monthly-list-pending-requests-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| SA1 | Monthly List is visible only to FinancialManager and SuperAdmin. Admin and null/unknown roles lose the drawer item (it never worked for Admin: the API returned 403) | PM (G1, option A) | Approved |
| SA2 | SuperAdmin sees the Terminated Investor tab on Pending Requests, read-only | PM (G2, option A) | Approved |
| SA3 | Local test credentials only, as already available; no password reset without PM approval | PM (G3) | Approved |
| SA4 | The wider API read permissions on `GetPaymentRequests` / `GetBlockRequests` stay unchanged | PM (G4) | Approved |
| SA5 | Production deploy and production DB checks are done by the PM after local verification; the team never touches production | PM (G5) | Approved |
| SA6 | SuperAdmin sees "View investor payment requests"; the access-denied text is role-neutral | PM (G6) | Approved |
| SA7 | Backend: only `PaymentVerificationList` and `PaymentVerificationHistory` gain `SuperAdmin`; `ReviewPaymentVerification`, `ReviewPaymentRequest` and `ReviewBlockRequest` stay unchanged; no DB change (database-architect: none needed). Frontend: role rules in `AdminNavPermissions` (`canReviewPendingRequests`, `canModifyMonthlyList`), a required flag passed down to the widgets | Team Head (Solution Architect: approve with changes) | Approved |
| SA8 | Accepted risk, unchanged by this work: tokens do not expire (`EnforceExpiry` off) and the role is fixed in the JWT, so a role change applies at next login | Team Head | Accepted |
| SA9 | Test outcome (2026-11-25): frontend suites for navigation, monthly list and pending requests pass (47 tests); `flutter analyze` has no new issue (68 baseline); `dotnet build` 0 errors; the API diff is exactly 2 attribute lines. The full `flutter test` has 3 failures in untouched code (`no_sensitive_logging_test` on `funding_payments_repository.dart`, team overview TC-2 x2), unrelated, logged as follow-ups. **API authorization run on the local DB (`FaezLaptop\SQLEXPRESSMICTCO`) with the PM's local logins for SuperAdmin, FinancialManager and MarketingManager, all as expected:** SuperAdmin 200 on PaymentVerificationList/History, GetPaymentRequests, GetBlockRequests and InvestorDetails, and 403 on ReviewPaymentVerification, ReviewPaymentRequest and ReviewBlockRequest; FinancialManager 200 on both verification GETs and 400 (id 0, no write) on ReviewPaymentVerification, 403 on the other two review POSTs; MarketingManager 403 on both verification GETs and ReviewPaymentVerification, 400 (id 0, no write) on the other two review POSTs; no token or bad token 401; SuperAdmin and FinancialManager get identical verification response data. JWT role claims are exactly `SuperAdmin`, `FinancialManager`, `MarketingManager`. The API ran from a scratch copy whose config holds only the local DB and whose worker marker blocked the startup email catch-up. **Not run:** the Admin and Investor cases (no logins), A10 with a validly structured tampered token, and manual UI checks M1-M11. | Tester, Team Head | Open: Admin/Investor logins, M1-M11 |
| SA10 | QA review of F2 and F3: Ready (no blocker/major/minor; two optional low test gaps: screen-level role-to-flag mapping tests). Security check S1-S11: Ready, all PASS in code. One flag for the PM (G5): the API compares the role claim case-sensitively while the app lowercases it, so if production stores a different spelling of `SuperAdmin`, the tabs would show but the API would answer 403 (fails closed). | qa-team-head | Recorded |

## 2026-11-25 — Dashboard Committed Amount card (spec: docs/superpowers/specs/2026-11-25-dashboard-committed-amount-card-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| C0 | Replace the Dashboard "Active Investors" card (duplicate of Total Investors) with a "Committed Amount" card | PM (request) | Done |
| C1 | "Committed amount" = `totalInvestmentAmount` from the existing `GetDashboard` API (sum of Investment transactions, date-range filtered); no backend, model or DI change | Team Head | Done |
| C2 | Reuse the existing card widget, `ImageConstants.totalCommitment` icon and the removed card's green; no new UI component | Team Head | Done |
| C3 | Order: Total Funding, Committed Amount, Amount Received, Amount Remaining, Total Investors, Funding Progress | Team Head | Done |

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

## 2026-11-26 — KYC front and back images (spec: docs/superpowers/specs/2026-11-26-kyc-front-back-images-design.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| K1 | Replace-only for KYC images: × cancels a newly picked image and restores the stored one; stored images are never removed; a stored file is deleted only after its replacement is saved and the DB update succeeded | PM | Approved |
| K2 | Read-only screens (mobile document screen, nominee details, admin pending-request review) show Front and Back; an existing single image shows as Front | PM | Approved |
| K3 | Front and back are independently optional; no "both required" rule | PM | Approved |
| K4 | `RegisterInvestor` gets the 100 MB request-size attributes; Dio `sendTimeout` raised per request for register and update only; no global change | PM | Approved |
| K5 | DB work on local `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE` only (Windows auth, `@@SERVERNAME` checked first); production and remote servers never touched | PM | Approved |
| K6 | Work stays on `feature/high-priority-reports` in both repos; nothing committed or pushed | PM | Approved |
| K7 | Profile photo upload and × behaviour unchanged | PM | Approved |
| K8 | Four nullable columns (`AadhaarBackPhoto`, `PanCardBackPhoto`, `in_aadhaarbackphoto`, `in_pancardbackphoto`, VARCHAR(500)); existing columns stay as Front; no document table (approved schema change) | PM | Approved |
| K9 | Extend the existing upload workflow only (endpoints, DTOs, service, `SavePublicImageAsync`, SP actions, nominee-slot mapping, tracking and cleanup); no new endpoint, service or storage | PM | Approved |
| K10 | New flat request fields (`…Back…` twins) and response properties; no nested `documents[]` | Team Head (Solution Architect) | Approved |
