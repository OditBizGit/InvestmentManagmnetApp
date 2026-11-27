# High-priority finance reports — design spec

Date: 2026-11-23 · Owner: Team Head · Decisions: `docs/DECISIONS.md` R1–R17
Repos: frontend `maribel_wellness_centre_application` (Flutter), backend `investmentmanagmentAppApi/Maribel.Wellness.Api` (.NET 9, Dapper, stored procedures).

## 1. Scope

| # | Report | Where | New API |
|---|---|---|---|
| 1 | Collection Aging | Drawer > Reports > Collection Aging | `GET /api/Report/CollectionAging` |
| 2 | Expected vs Actual collections | Drawer > Reports > Expected vs Actual | `GET /api/Report/ExpectedVsActual`, `GET /api/Report/ExpectedVsActualDetails` |
| 3 | Refund & Termination | Drawer > Reports > Refunds & Terminations | `GET /api/Report/RefundTermination` |
| 4 | Investor Statement (+ PDF) | Drawer > Reports > Investor Statement | `GET /api/Report/InvestorStatement/{userId}` |
| 5 | Staff allocation (extends Staff Report) | Existing Staff Report | Additive fields on `GET /api/Staff/GetStaffReport` |

Out of scope: commission rates (R4), new tables/indexes (R13), server-side PDF (R6), CSV export, scheduled emails, Financial/Marketing manager access (R3).

## 2. Business rules (shared)

- Countable payment: `AccountTransaction.Type='Payment'` without a Rejected `InvestorPaymentVerification` row.
- Aging and Expected vs Actual installment schedule = the one in `Api_InvestorPaymentStatusReport` (steps 3–6): effective due date (`fn_InvestorEffectiveDueDate(fn_InvestorCalculatedDueDate)`), last installment clamped at 0, advance payments excluded from the schedule, payments applied oldest-first, refunds removed from the latest installments, unpaid when pending > 0.01.
- Settled investors (`InvestorSettlement` row): outstanding 0; no installments due after the settlement date (R14).
- Population: active and blocked investors (R14). Aging excludes settled investors.
- Aging as-of: payments, refunds and settlements dated on or before `@AsOfDate` count; `DaysPastDue = DATEDIFF(DAY, dueDate, @AsOfDate)`; no grace days; due-date overrides are always current-state.
- Investor Statement schedule = `Api_InvestorManage` Action 3 result set 2 verbatim (settled → Completed), so it matches Investor Details; plus `daysOverdue`.
- All amounts `DECIMAL(18,2)`; frontend formats with `CurrencyFormatter`.

## 3. Database (all read-only procedures, scripts in `Sql/`)

| Procedure | Params | Result sets |
|---|---|---|
| `Api_CollectionAgingReport` | `@AsOfDate DATE = NULL` (→ today; future → THROW 50010), `@Search NVARCHAR(100) = NULL` | 1 rows · 2 totals |
| `Api_ExpectedVsActualCollections` | `@FromDate`, `@ToDate` (rounded to whole months; missing 50007; From>To 50008; >12 months 50009) | 1 months · 2 totals |
| `Api_ExpectedVsActualCollectionsDetails` | `@Month DATE` (any day of month; missing 50007) | 1 investors · 2 totals |
| `Api_RefundTerminationReport` | `@FromDate`, `@ToDate` (missing 50007; From>To 50008), `@Search` | 1 refunds · 2 terminated investors · 3 totals |
| `Api_InvestorStatement` | `@UserId`, `@FromDate NULL`, `@ToDate NULL` (unknown investor 50001; From>To 50008) | 1 header · 2 ledger · 3 schedule |
| `Api_StaffReportList` (ALTER) | unchanged | append `ReceivedAmount, AllocatedAmount, RefundAmount, NetAmount, InvestorCount` after `TotalAmount` |

Column lists and calculation rules: Database Architect design (recorded as R13–R17), reproduced in the API contract below. `Verify_StaffReportHistoricalAllocation.sql` `#List` widened (R17). Live checks on the local restore: `AccountTransaction` indexes and `Name` column type, `InvestorSettlement(UserId)`, `RefundDate` range scans, scalar-function cost.

## 4. API contract

New `ReportController` (`[Route("api/[controller]")]`, `[Authorize(Roles = "Admin,SuperAdmin")]`), `IReportServices`/`ReportServices` in `Services/ReportServices/`, DTOs in `Dtos/Request/Report` and `Dtos/Response/Report`, registered `AddScoped` in `Program.cs`. Envelope like `StaffController`: `{ success, message, data }`; JSON camelCase. Errors: SQL 50001 → 404, 50007–50010 → 400 with the SQL message, other → 500 with a generic message (no exception details). Dates `yyyy-MM-dd`; unparseable date, `userId <= 0` or `search` > 100 chars → 400 from model validation. Search is matched as literal text (`%`, `_`, `[` escaped in the LIKE).

### 4.1 `GET /api/Report/CollectionAging?asOfDate=&search=`
`data = { asOfDate, rows: [ { userId, investorCode, name, phoneNumber, isActive, totalPayable, amountPaid, outstanding, notYetDue, days1To30, days31To60, days61To90, days90Plus, totalOverdue, oldestDueDate, maxDaysPastDue } ], totals: { investorCount, notYetDue, days1To30, days31To60, days61To90, days90Plus, totalOverdue, outstanding } }`. Rows only where a bucket sum > 0, ordered by `totalOverdue` desc.

### 4.2 `GET /api/Report/ExpectedVsActual?fromDate=&toDate=`
`data = { fromMonth, toMonth, months: [ { month (yyyy-MM-01), expectedAmount, expectedInstallments, actualPayments, advancePayments, refunds, actualAmount, collectionRate (nullable) } ], totals: { same fields without month } }`. `actualAmount = actualPayments − refunds`; `collectionRate = actualAmount / expectedAmount * 100`, null when expected = 0. `advancePayments` is included in `actualPayments`. `expectedAmount` is the full installment amount due in the month whether paid or not.

### 4.3 `GET /api/Report/ExpectedVsActualDetails?month=`
`data = { month, rows: [ { userId, investorCode, name, phoneNumber, isActive, expectedAmount, expectedInstallments, actualPayments, advancePayments, refunds, actualAmount, collectionRate } ], totals: { investorCount, expectedAmount, expectedInstallments, actualPayments, advancePayments, refunds, actualAmount, collectionRate } }`. Rows where expected or actual ≠ 0.

### 4.4 `GET /api/Report/RefundTermination?fromDate=&toDate=&search=`
`data = { refunds: [ { refundId, requestId, userId, investorCode, name, refundDate, refundAmount, paymentMethod, remarks } ], terminated: [ { userId, investorCode, name, terminatedDate, dateSource ("BlockRequest"|"ModifiedDate"), totalPayable, totalPaid, totalRefunded, pendingRefundRequests, remainingRefundable } ], totals: { refundCount, refundAmount, terminatedCount, totalPaid, totalRefunded, remainingRefundable } }`. Refunds: `refundDate` in range. Terminated: `IsActive = 0` and `terminatedDate` in range. Search applies to both lists. `pendingRefundRequests` is an AMOUNT (sum of pending refund request amounts, DECIMAL(18,2)), not a count. `remainingRefundable = MAX(0, totalPaid − totalRefunded − pendingRefundRequests)`, 0 when settled. Totals `refundAmount` = refunds in range; `totalRefunded` = all-time for the terminated investors listed.

### 4.5 `GET /api/Report/InvestorStatement/{userId}?fromDate=&toDate=`
`data = { header: { userId, investorCode, name, phoneNumber, email, isActive, investmentStartDate, commitmentAmount, grossPaid, refunds, netPaid, discount, pending, isSettled, settlementAmount, settlementDate, openingBalance, closingBalance, fromDate, toDate }, ledger: [ { lineNo, entryDate, entryType (Investment|Payment|Discount|Refund), reference, description, paymentMethod, verificationStatus, chargeAmount, paymentAmount, runningBalance } ], schedule: [ { installmentNo, dueDate, amount, paidAmount, pendingAmount, status (Completed|Partially Completed|Pending), daysOverdue } ] }`. Header totals are as of today; ledger is filtered by the range with `openingBalance` carried in. `investmentStartDate` = `UserRegistration.InvestmentStartDate`. Ledger rules: charges = Investment and Refund; payments = Payment and Discount; `runningBalance = openingBalance + Σ charge − Σ payment` (not clamped); ordered by date, then type, then EntryNo/id; Rejected payments excluded; `verificationStatus` is Approved or Pending. `closingBalance` can differ from `pending` (pending follows the schedule rules); the UI labels them separately.

### 4.6 `GET /api/Staff/GetStaffReport` (existing, additive)
Each row gains `receivedAmount, allocatedAmount, refundAmount, netAmount, investorCount`. `totalAmount` unchanged (= `netAmount`, per-row rounding as in `Api_StaffReportDetails`). `investorCount` = distinct investors with payment/refund events in the period (R15). Existing callers unaffected.

## 5. Frontend

Structure (R9, R10): under `lib/admin/reports/`:
- `collection_aging/`, `expected_vs_actual/`, `refund_termination/`, `investor_statement/`, each `{cubit,model,repository,widgets}` + `<name>_screen.dart`.
- `shared/`: 12-month month-range picker (rebuilt, not moved from Overview), `investor_statement_pdf.dart` (web-safe, `pdf` MultiPage + `saveExportFile`, R12).
- Endpoints in `lib/core/constants/api_endpoints.dart`. Cubit created in the screen's `initState` with `XRepository(getIt<Dio>())`, closed in `dispose`.
- State: sealed for Collection Aging and Refund & Termination; status-enum + `copyWith` for Expected vs Actual and Investor Statement.

Navigation: 4 new `AdminDrawerItem` values in the Reports group (after Staff Report), 4 cases in `_screenFor`. `AdminNavPermissions` unchanged (Admin/SuperAdmin see them; Financial/Marketing managers do not). Fetch only while `isActive`; on re-activation reset filters/drill-down/selection and refetch.

Filters and errors (R19–R23): search is client-side; period → dates via `shared/report_period_range.dart`; error text = server `message` via `api_error_message.dart`; collection rate shown with 1 decimal + `%` ("—" when null); investor picker uses `InvestorsRepository.getInvestors`.

UI (design source = existing Reports screens, R2): `UserManagementSectionHeader`, `UserManagementStatCards`, `user_management_table_widgets.dart`, `StaffReportPeriod` + `showStaffReportCustomDateRangeDialog`, `CurrencyFormatter`, `AppToast`; loading shimmer/spinner and retry like Staff Report; empty state text "No records found".

| Screen | Stat cards | Filters | Table | Drill-down |
|---|---|---|---|---|
| Collection Aging | Total Overdue, 1–30, 31–60, 61–90, 90+ (Not yet due shown in table) | As-of date (default today), search name/code/phone | Code, Name, Status, Outstanding, Not yet due, 1–30, 31–60, 61–90, 90+, Oldest due | — |
| Expected vs Actual | Expected, Actual, Refunds, Collection rate | From/To months (default last 6 months, max 12) | Month, Expected, Installments, Payments, Refunds, Actual, Rate %, View | Month → investor table, Back |
| Refunds & Terminations | Refund count, Refunded amount, Terminated count, Remaining refundable | Period (This/Last Month/Custom), search | Two sections: Refunds; Terminated investors | — |
| Investor Statement | Commitment, Net paid, Discount, Pending | Investor picker (from `GetInvestors`, searchable), optional From/To | Ledger with running balance; installment schedule | Export PDF button |
| Staff Report | — | unchanged | list keeps Total Amount (net) and adds Received (gross), Allocated, Refunds, Investors (R19); details rows add Allocation %, Allocated, Refund Amnt; Amount Received (net) unchanged, no duplicate Net (R25) | unchanged |

## 6. Testing

- Backend (R8): one `Verify_*.sql` per new procedure with seeded test data in a transaction (rolled back) asserting totals and buckets; `Verify_StaffReportHistoricalAllocation.sql` updated; HTTP smoke tests (`.http` + curl) for each endpoint on the API run against the **local** restore with an overridden connection string: 200 shape, 400/404 errors, 401/403 for non-admin roles.
- Frontend: model `fromJson` tests, cubit tests with hand fakes (`test/core/fakes.dart` style), widget tests for each screen (loading, data, empty, error/retry, drill-down), nav permission test; `flutter analyze` clean; `flutter test` full suite once at the end.

## 7. Risks / open

- **Local database required** (global rule): no local `MARIBEL_WELLNESS_CENTRE` exists; PM must supply a backup/`.bacpac` before DB verification and API smoke tests.
- Unpaid advance is not in the schedule, so aging bucket sum can be below outstanding (shown as-is, explained in a footnote under the table).
- `receivedAmount` counts a shared investor's payment in full under each staff (labelled gross, R15).
- Unblocking leaves no history, so a re-activated investor drops out of the terminated list; the `ModifiedDate` fallback for terminated date is approximate (flagged by `dateSource`).
- Due-date overrides are current-state even with an as-of date.
- Scalar date functions per installment and the 100-installment tally limit (existing).
- `₹` glyph in PDF font (same exposure as Manage Users PDF) — check in testing.
- Rows are not paginated (single project, small investor base); revisit if investors exceed a few thousand.
