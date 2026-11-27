# High-priority finance reports — implementation plan

Spec: `docs/superpowers/specs/2026-11-23-high-priority-reports-design.md` · Decisions: `docs/DECISIONS.md` R1–R23
Status legend: Pending / In progress / Done / Blocked (blocked = waiting on the local DB backup, not failed)

## Tasks

Every task writes its tests first (Verify scripts / `.http` smoke requests / failing Dart tests), then the code.

| ID | Owner | Scope (files) | Tests first | Depends on | Status |
|---|---|---|---|---|---|
| B1 | backend-developer | `Sql/Api_CollectionAgingReport.sql`, `Sql/Api_ExpectedVsActualCollections.sql` (both procs), `Sql/Api_RefundTerminationReport.sql`, `Sql/Api_InvestorStatement.sql`, `Sql/Api_StaffReportList.sql` (ALTER, additive) | `Sql/Verify_CollectionAgingReport.sql`, `Verify_ExpectedVsActualCollections.sql`, `Verify_RefundTerminationReport.sql`, `Verify_InvestorStatement.sql` (seeded data in a rolled-back transaction, PASS/FAIL lines); widen `#List` in `Verify_StaffReportHistoricalAllocation.sql` | spec §2–3 | Done (written, not executed; DB review in progress; runtime blocked on DB) |
| B2 | backend-developer | `Controllers/ReportController.cs`, `Services/ReportServices/*`, `Dtos/Request/Report/*`, `Dtos/Response/Report/*`, `Dtos/Response/Staff/StaffReportResponse.cs` (additive), `Program.cs` (AddScoped) | `Maribel.Wellness.Api.http` smoke requests for every endpoint and error case (TC03, TC07, TC25–TC28) | spec §4 | Done (code; QA fixes in, build 0 errors; runtime blocked on DB) |
| DB-R | database-architect (review) | B1 scripts + heavy queries | — | B1 | Pending |
| DB-V | Team Head + tester | on the PM's local `MARIBEL_WELLNESS_CENTRE` (R31): record Staff Report baseline, deploy B1, run Verify scripts, run API on local DB, run smoke tests | — | B1, B2 | Done 2026-11-23 (QA Ready; TC17a/b, TC23 manual pending) |
| F1 | frontend-developer | `lib/core/constants/api_endpoints.dart` (ALL new endpoint constants), `lib/admin/navigation/*` (4 drawer items + `_screenFor`), 4 screen shells (header only), `lib/admin/reports/shared/month_range_picker.dart`, `lib/admin/reports/shared/report_period_range.dart`, Staff Report extension (`staff_report/model/*`, `staff_report/widgets/*`, `staff_details_screen.dart`; `StaffReportPeriod` and `showStaffReportCustomDateRangeDialog` keep their names/signatures) | `test/admin/navigation/`, `test/admin/reports/shared/`, `test/admin/reports/staff_report/` | spec §5 | Done (QA Ready; minors fixed) |
| F2 | frontend-developer | `lib/admin/reports/collection_aging/**`, `lib/admin/reports/refund_termination/**` (takes over the two shells from F1) | `test/admin/reports/collection_aging/`, `test/admin/reports/refund_termination/` (own fakes file per folder) | F1 | Pending |
| F3 | frontend-developer | `lib/admin/reports/expected_vs_actual/**`, `lib/admin/reports/investor_statement/**` (takes over the two shells from F1), `lib/admin/reports/shared/investor_statement_pdf.dart` | `test/admin/reports/expected_vs_actual/`, `test/admin/reports/investor_statement/` (own fakes file per folder) | F1 | Pending |
| QA | qa-team-head | review per task, then whole-branch review + security check | — | each task | Pending |
| T | tester | test-case document below, `flutter analyze`, full `flutter test` once, `dotnet build`, Verify scripts + smoke tests | — | all | Pending |
| D | Team Head | docs: `modules/ADMIN_REPORTS.md`, `FEATURE_MODULES.md`, `API_INTEGRATION.md`, `modules/ADMIN_NAVIGATION.md`, `DATA_MODELS.md`; phase report | — | all | Pending |

Order: B1 ∥ B2 ∥ F1 → F2 ∥ F3 → DB-R after B1 → DB-V when the backup arrives → T → QA final → D.
Ownership: files are disjoint between tasks running at the same time. The 4 screen shells are created by F1 and handed to F2/F3 after F1 is done. `test/core/fakes.dart` is not edited by F2/F3.
Database safety: never the remote server in `appsettings.json`. Before every SQL or API run, check the server is `.\SQLEXPRESSMICTCO`; the API runs with `ConnectionStrings__DefaultConnection=Server=.\SQLEXPRESSMICTCO;Database=MARIBEL_WELLNESS_CENTRE_TEST;Trusted_Connection=True;TrustServerCertificate=True`.

## Acceptance criteria

| AC | Criterion | TCs |
|---|---|---|
| AC1 | Four new drawer items under Reports for Admin/SuperAdmin only; Financial/Marketing managers don't see them; API returns 403 for other roles, 401 without/expired token | TC01–TC03 |
| AC2 | Each screen matches the existing Reports UI: header, stat cards, table, filters, loading, empty ("No records found"), error + retry with the server message | TC04, TC21, TC29, TC30 |
| AC3 | Aging buckets/totals equal Verify expectations incl. edges; blocked included, settled excluded; future as-of rejected (UI + 400) | TC05–TC08 |
| AC4 | EvA: whole-month rounding; > 12 months, missing date, From > To rejected (UI + 400); drill-down totals equal the month row; rejected verifications excluded; rate 1 decimal | TC09–TC12 |
| AC5 | Refunds & Terminations: refunds and terminated investors in range; remaining = max(0, paid − refunded − pending), 0 when settled; From > To 400 | TC13, TC14 |
| AC6 | Statement: running balance ends at closing balance; opening balance when From set (0 when not); From > To 400; header totals as of today; PDF on web and Windows with the same figures | TC15–TC18 |
| AC7 | Staff Report: list adds Received (gross), Allocated, Refunds, Investors; Total Amount unchanged vs baseline; details rows add Allocation %, Allocated, Refund Amnt (R25) | TC19, TC20 |
| AC8 | No new package, table, index or destructive schema change; no remote DB access | TC31 |
| AC9 | `flutter analyze` no new issues; `flutter test` passes; `dotnet build` 0 errors; all Verify scripts PASS | TC24, TC32 |
| AC10 | Inputs validated, no error detail leakage, search literal | TC25–TC28 |

## Test-case document

| TC | AC | Area | Steps | Expected |
|---|---|---|---|---|
| TC01 | AC1 | Nav | Admin opens drawer > Reports | Overview, Staff Report, Collection Aging, Expected vs Actual, Refunds & Terminations, Investor Statement |
| TC02 | AC1 | Nav | `AdminNavPermissions` unit test for Admin, SuperAdmin, FinancialManager, MarketingManager | New items allowed for Admin/SuperAdmin only |
| TC03 | AC1 | API auth | Each `/api/Report/*` with SuperAdmin, FinancialManager, MarketingManager, Investor, expired and no token | 200 / 403 / 403 / 403 / 401 / 401 |
| TC04 | AC2,3 | Aging | Open screen | Loads as of today; cards = totals; rows sorted by overdue desc; footnote when bucket sum < outstanding |
| TC05 | AC3 | Aging | Verify fixtures: installments 0, 1, 30, 31, 60, 61, 90, 91 days past due + one future | 0 and future → Not yet due; 1/30 → 1–30; 31/60 → 31–60; 61/90 → 61–90; 91 → 90+ |
| TC06 | AC3 | Aging | Fixtures: blocked investor with overdue; settled investor | Blocked listed; settled not listed |
| TC07 | AC3 | Aging | Date picker; API with tomorrow | Picker blocks future dates; API 400 with message |
| TC08 | AC3 | Aging | Search by code / name / phone | Filtered rows (client-side) |
| TC09 | AC4 | EvA | Default range | Last 6 months; cards = totals = sum of rows |
| TC10 | AC4 | EvA | 13-month range in UI; API with 13 months, missing date, From > To, mid-month dates | UI clamps + info toast; API 400 / 400 / 400; mid-month rounds to whole months |
| TC11 | AC4 | EvA | Month with expected 0; fixture with rejected verification | Rate "—"; rejected payment not in actual |
| TC12 | AC4 | EvA | View a month; Details API with missing month | Investor rows sum to month row; Back keeps range; API 400 |
| TC13 | AC5 | Refunds | This Month / Last Month / Custom; API From > To | Rows in range; cards = totals; API 400 |
| TC14 | AC5 | Refunds | Fixtures: pending refund request; settled; no block request (ModifiedDate fallback); unblocked investor | Remaining per formula; settled 0; `dateSource=ModifiedDate`; unblocked absent |
| TC15 | AC6 | Statement | Pick investor, no dates | Opening 0; ledger complete; last running balance = closing; schedule matches Investor Details |
| TC16 | AC6 | Statement | From only; To only; From+To; API From > To; fixture with rejected payment; settled investor | Opening when From set; range respected; 400; rejected excluded; settled schedule Completed |
| TC17a | AC6 | Statement PDF | Export on web | File downloads; figures equal screen; ₹ renders |
| TC17b | AC6 | Statement PDF | Export on Windows; multi-page ledger; empty ledger | Saved; pages break cleanly; empty ledger shows "No records found" |
| TC18 | AC6 | Statement | API unknown investor; userId 0 / -1 / abc | 404; 400/404, no stack trace |
| TC19 | AC7 | Staff | Record Total Amount per staff before ALTER; compare after | Unchanged; netAmount = totalAmount; new columns shown |
| TC20 | AC7 | Staff | Staff details | Allocation %, Allocated, Refund Amnt columns added; Amount Received (net) unchanged, no duplicate Net column (R25); total unchanged |
| TC21 | AC2 | All | API 500 / offline | Error text + Retry; toast once |
| TC22 | AC2 | All | Switch tab away and back | Filters, drill-down and selected investor reset; refetch |
| TC23 | — | Regression | Overview, Staff Report, Due Payments, Manage Users export | Unchanged behaviour |
| TC24 | AC9 | Backend | All Verify scripts on local test DB | All PASS; transactions rolled back |
| TC25 | AC10 | Security | Dates "abc" on each endpoint | 400, no stack trace |
| TC26 | AC10 | Security | Search > 100 chars | 400 |
| TC27 | AC10 | Security | Search `' OR 1=1--`, `%`, `_` | Treated as literal text (no extra rows) |
| TC28 | AC10 | Security | Forced 500 (e.g. DB offline) | Generic message only |
| TC29 | AC2 | Empty | Each screen with no data | "No records found" |
| TC30 | AC2 | Loading | Each screen while loading | Loading indicator like Staff Report |
| TC31 | AC8 | Scope | Diff of `Sql/` and `pubspec.yaml`; server name check log | No CREATE/ALTER TABLE, INDEX, DROP; pubspec unchanged; only `.\SQLEXPRESSMICTCO` used |
| TC32 | AC9 | Build | `flutter analyze`, `flutter test`, `dotnet build` | No new issues; all pass; 0 errors |
