# Plan: SuperAdmin read-only access — Monthly List and Pending Requests

Spec: `docs/superpowers/specs/2026-11-25-superadmin-readonly-monthly-list-pending-requests-design.md`
Status: **PM approved 2026-11-25 with decisions G1–G6 (§6). Implementation, QA review, automated tests and security check done 2026-11-25; API role checks run on the local DB; manual UI checks (M1-M11), Admin/Investor API cases and the production role check are still open (§8). Nothing is committed (PM instruction).**
Repos: Flutter app (this repo) · API `C:\Users\LENOVO\StudioProjects\investmentmanagmentAppApi\Maribel.Wellness.Api`
DB rule: all checks and tests use only the local `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE`. The API under test runs with its connection string overridden to the local DB.

---

## 1. Current implementation analysis (verified in code 2026-11-25)

### 1.1 Frontend role checks

| Place | Current rule |
|---|---|
| `lib/admin/navigation/admin_nav_permissions.dart` `allowedDrawerItems` | MarketingManager → `{pendingRequests}`; FinancialManager → `{monthlyList}`; **Admin, SuperAdmin, other or null → all items except `pendingRequests`** (Monthly List included) |
| same, `defaultDrawerItem` | MarketingManager → pendingRequests; FinancialManager → monthlyList; else dashboard |
| same, `canAccessPendingRequests` | MarketingManager only |
| same, `canAccessMonthlyList` | `canOpen(monthlyList)`, so today Admin, SuperAdmin and FinancialManager pass |
| `admin_main_screen.dart` `_onSelect` / `_screenFor` / `initState` | Uses `canOpen`. A tab the role cannot open is never built (`SizedBox.shrink`), so its fetch never runs. `AdminNavigateNotification` also goes through `_onSelect` and is blocked by `canOpen`. |
| `admin_side_drawer.dart` `destinationsForRole` (line 151) | Builds the drawer from `allowedDrawerItems`. Groups with no allowed child are hidden. |
| `monthly_payments_list_screen.dart:32-34` | Gate `canAccessMonthlyList`, otherwise `_MonthlyPaymentListAccessDenied` |
| `montly_payment_table.dart` | Modify controls: header select-all checkbox (~l.723), per-row approve checkbox (~l.358), Actions column with Approve, Reject and Save (~l.411-460), "Approve All" button (~l.598). Read controls: search, From/To dates, "View history" (~l.578). The table shows these for every role that reaches it, with no role check. |
| `monthly_payments_list_screen.dart` `_onSaveRow`, `_onApproveAll` | Call `PaymentListCubit.reviewPaymentVerification` / `approvePaymentsBatch`, which POST `ReviewPaymentVerification` |
| `pending_requests_screen.dart:34-35` | Gate `canAccessPendingRequests` (MarketingManager only) |
| `pending_request_card.dart` `_StatusAndAction` (~l.426) | Button "Review request" for pending items, "View request" otherwise; opens the detail view |
| `review_request_screen.dart:202-207` | Passes `onAccept`/`onReject` only when `request.isAwaitingReview`. `review_request_details_section.dart:144` `canAct` hides the buttons when either is null. |
| `terminated_investors_section.dart:167-171` | Passes `onApprove`/`onReject` only for pending items. `_ActionsColumn` (l.783) hides the buttons when either is null. Calls `ManageUsersCubit.reviewBlockRequest` → `ReviewBlockRequest`. |

**Finding F1:** in the frontend, SuperAdmin (and Admin) already see Monthly List **with approve/reject controls**. The backend returns 403 on all three Monthly List endpoints, so the tab shows the not-authorized error. Target matrix: SuperAdmin view yes, modify no. Admin is not in the matrix → **G1**.

### 1.2 Backend authorization (`Controllers/InvestorController.cs`)

The class has no `[Authorize]` (the line is commented out). Each action has its own attribute. No service-level role checks exist in `InvestorServices.cs`; services only read `ClaimTypes.NameIdentifier` (for example `@VerifiedBy`).

| Endpoint | Line | Current roles | Used by screen | Target |
|---|---|---|---|---|
| GET `/api/Investor/PaymentVerificationList` | 1260 | FinancialManager | Monthly List load | **FinancialManager, SuperAdmin** |
| GET `/api/Investor/PaymentVerificationHistory` | 1311 | FinancialManager | Monthly List "View history" | **FinancialManager, SuperAdmin** |
| POST `/api/Investor/ReviewPaymentVerification` | 1362 | FinancialManager | Monthly List approve, reject, Approve All | unchanged (FinancialManager) |
| GET `/api/Investor/GetPaymentRequests` | 733 | Admin, SuperAdmin, FinancialManager, MarketingManager | Pending Requests list | unchanged (SuperAdmin already allowed) |
| POST `/api/Investor/ReviewPaymentRequest` | 742 | MarketingManager | Accept/reject request | unchanged (SuperAdmin already blocked) |
| GET `/api/Investor/GetBlockRequests` | 1086 | Admin, SuperAdmin, FinancialManager, MarketingManager | Terminated Investor tab | unchanged |
| POST `/api/Investor/ReviewBlockRequest` | 1095 | MarketingManager | Terminated tab approve/reject | unchanged |
| GET `/api/Investor/InvestorDetails/{userId}` | 643 | Admin, SuperAdmin, FinancialManager, Investor, MarketingManager | Request detail (KYC, bank, nominees) | unchanged |
| GET `/api/Investor/MonthlyPaymentList` (legacy) | 1210 | Admin, SuperAdmin, FinancialManager | not used by this screen | unchanged, out of scope |

**Stored procedures:** `Api_PaymentVerificationList`, `Api_PaymentVerificationHistory`, `Api_ReviewPaymentVerification`, `Api_InvestorPaymentRequests`, `Api_InvestorBlockRequests`. None of them checks the caller's role; they only use `UserRole = 'Investor'` to pick investor rows. The DB has no role or permission tables (checked on the local DB). **No DB change is needed.**

**JWT role claim:** `UserServices.GenerateToken` (l.703-740) puts `ClaimTypes.Role` = the DB `UserRegistration.UserRole`, at login (l.231) and on refresh (l.602). The login request role is normalised in `UserController` (l.55-100) only to look the user up. `[Authorize(Roles)]` uses `IsInRole`, which is **ordinal and case-sensitive**. Local DB values are exactly `SuperAdmin`, `Admin`, `FinancialManager`, `MarketingManager` and `Investor` (1, 4, 1, 1 and 4 users). A row stored as `Super Admin` or `superadmin` would get 403. G5 includes a read-only check of the production value, run by the PM.

---

## 2. Backend changes

| File | Change | Purpose |
|---|---|---|
| `Maribel.Wellness.Api/Controllers/InvestorController.cs` l.1260 | `[Authorize(Roles = "FinancialManager")]` → `[Authorize(Roles = "FinancialManager,SuperAdmin")]` on `GetPaymentVerificationList` | SuperAdmin can read the Monthly List |
| same, l.1311 | Same change on `GetPaymentVerificationHistory` | SuperAdmin can read the verification history |
| same, l.1362 | **No change**, stays `FinancialManager` | SuperAdmin cannot approve or reject a payment, even by calling the API directly |
| same, l.742 and l.1095 | **No change**, stay `MarketingManager` | SuperAdmin cannot accept/reject a request or a block request |
| `docs/API_ENDPOINTS.md` rows 27-28 and §2.25-2.26 | "FM only" → "FM, SA" | Docs match the code |
| `docs/AUTHENTICATION.md` l.45 | Move PaymentVerificationList and History out of "FinancialManager only" into "FinancialManager, SuperAdmin" | Docs match the code |

Reused as they are: all endpoints in the table in §1.2. No new endpoint, DTO, service or SQL. `dotnet build` must pass.

## 3. Frontend changes

| File | Change | Purpose |
|---|---|---|
| `lib/admin/navigation/admin_nav_permissions.dart` | Add `isSuperAdmin`. In `allowedDrawerItems` add an **explicit** SuperAdmin branch (`AdminDrawerItem.values.toSet()`) that does **not** call the shared fallback helper, so a later fallback change cannot widen or shrink SuperAdmin. G1 sets the fallback set, which Admin **and null/unknown roles** share. `canAccessPendingRequests` → MarketingManager or SuperAdmin. Add `canReviewPendingRequests` (MarketingManager only) and `canModifyMonthlyList` (FinancialManager only). `defaultDrawerItem` unchanged. | One place for role rules |
| `lib/admin/monthly_payment_list/screen/monthly_payments_list_screen.dart` | Read `canModifyMonthlyList(role)` next to the access gate and pass it to `_MonthlyPaymentListView(canModify:)`, then to `MonthlyPaymentTable(readOnly: !canModify)`. `_onSaveRow`, `_onApproveAll`, `_selectAllApprove`, `_setApproveIntent` and `_setRejectIntent` (l.196-214) return at once when `!canModify`. | Read-only Monthly List for SuperAdmin |
| `lib/admin/monthly_payment_list/screen/widgets/montly_payment_table.dart` | New **required** `readOnly` parameter. When true, do not build: the header select-all checkbox column, the row checkbox column, the Actions header and column, and the "Approve All" button. Keep "View history", search and dates. Shrink the minimum table width by the hidden columns (36 + 16 + 148), so 1080 → about 880. | Hide every modify control |
| `lib/admin/pending_requests/screens/pending_requests/pending_requests_screen.dart` | Compute `canReview = canReviewPendingRequests(role)` and pass it to `_PendingRequestsView`, `PendingRequestsListSection` and `ReviewRequestScreen`. **Only if G6 is approved:** the subtitle "Review and approve investor payment requests" (l.214, and `pending_requests_overview_section.dart:88`) becomes "View investor payment requests" when `!canReview`, and the access-denied text (l.264) "available only for Marketing Manager accounts" becomes role-neutral ("not available for your account role", matching Monthly List). | Pass the role decision down; wording per G6 |
| `test/admin/pending_requests/payment_request_staff_name_test.dart` l.38 | Add `canReview: true` to the existing `PendingRequestCard(...)`. Without it the build fails once the parameter is required. | Keeps the existing test compiling; it becomes part of the W5 regression |
| `.../pending_requests/widgets/pending_requests_list_section.dart` | New required `canReview`, passed to `PendingRequestCard` and `TerminatedInvestorsSection`. (G2 decided: SuperAdmin sees the Terminated Investor tab read-only, so the filter tab stays.) | |
| `.../pending_requests/widgets/pending_request_card.dart` | New required `canReview`. The label is "Review request" only when `canReview && isAwaitingReview`, otherwise "View request". | No "Review" wording for view-only users |
| `.../review_request/review_request_screen.dart` | New required `canReview`. Pass `onAccept`/`onReject` only when `canReview && isAwaitingReview`. `_accept`/`_reject` return early if `!canReview`. | Existing `canAct` hides the Approve/Reject buttons |
| `.../pending_requests/widgets/terminated_investors_section.dart` | New required `canReview`. Pass `onApprove`/`onReject` only when `canReview && isPendingReview`. `_approve`/`_reject` return early if `!canReview`. | Existing `_ActionsColumn` hides the buttons |

Not changed: the cubits, repositories, models, endpoints, `admin_main_screen.dart` and `admin_side_drawer.dart` (both follow `AdminNavPermissions`). The cubits do not need role logic. The UI hides the actions and the API is the guard.

Existing workflows kept: FinancialManager `canModify = true`, so the table is the same as today. MarketingManager `canReview = true`, so the card, detail screen and Terminated tab are the same as today. Regression tests cover both (§5).

## 4. Security and edge cases

| # | Risk | How it is handled |
|---|---|---|
| S1 | SuperAdmin calls a modify API directly (Postman, devtools) | `ReviewPaymentVerification` (FinancialManager), `ReviewPaymentRequest` and `ReviewBlockRequest` (MarketingManager) are unchanged, so the API returns 403. API tests A3, A6 and A8. |
| S2 | Role edited in web local storage or prefs to show hidden controls | The UI is only a convenience. The token role comes from the DB, so the API still returns 403. |
| S3 | Accidental widening for Admin or other roles | Only the two GET attributes gain exactly `SuperAdmin`. On the frontend, SuperAdmin gets its own explicit branch, not a change to the shared fallback. Unit tests cover all four roles plus null and unknown roles (U1-U8). |
| S4 | Shared helpers used elsewhere | `allowedDrawerItems` and `canOpen` drive the drawer and shell for every role. The Reports tests (`reports_navigation_test.dart`) must stay green. `ManageUsersCubit.reviewBlockRequest` is also used by Manage Users, so its behaviour is not changed. The guard is only in the Pending Requests widgets. |
| S5 | Direct navigation | The admin app has no named or URL routes. Tabs switch through `_onSelect`, which checks `canOpen`. `AdminNavigateNotification` takes the same path. The detail screen is an in-place swap inside the guarded screen. |
| S6 | JWT role claim name and casing | The claim is `ClaimTypes.Role` from the DB value, matched ordinally. The attribute string must be exactly `SuperAdmin`, the same as the 61 existing uses. The frontend uses `normalizeRole`, which ignores case and spaces. G5 checks the production DB value. |
| S7 | Sensitive data shown to SuperAdmin | The detail screen shows investor KYC images, bank details and nominees from `InvestorDetails`. SuperAdmin can already read these through the Investors module, so no new exposure. |
| S8 | 1-minute silent refresh on Pending Requests | GET only, so it is safe for SuperAdmin. Its behaviour does not change. |
| S9 | SuperAdmin landing tab | Stays Dashboard. Both new tabs only load data when opened (`isActive`). |
| S10 | Token lifetime and role freshness (already true before this work) | `Jwt:EnforceExpiry` is off (`Program.cs:121,132`) and the role is fixed in the JWT, with no per-request role check. A demotion only takes effect at the next login. SuperAdmin tokens issued before the deploy get the new read access right away (the role claim is unchanged). **Accepted risk / existing follow-up**, not fixed here (see the security-hardening phase). |
| S11 | Unknown or null role fallback | `allowedDrawerItems` falls back to the Admin set (`admin_nav_permissions.dart:74`). Unknown roles cannot pass the web login (`canAccessAdminWebLogin`). G1 decides whether the fallback keeps Monthly List. |

## 5. Implementation sequence (MICTCO)

0. **Plan reviews done 2026-11-25:** solution-architect "Approve with changes", database-architect "No DB change needed", qa-team-head "Needs Fixes" (plan-level only). All of their changes are folded into this plan.
1. **Gate review**: the PM answers G1-G6. Decisions go into `docs/DECISIONS.md` as the next `R` numbers.
2. **DB check** (`database-architect`, read-only, local DB): confirm the role values and that no SP or table holds role rules. No migration. **Done 2026-11-25: "No DB change needed"**. Local server confirmed as `FaezLaptop\SQLEXPRESSMICTCO`. The role values were checked with a binary collation and have no casing or space variants. No SP checks the caller's role (`Api_ReviewPaymentVerification` only checks `@VerifiedBy > 0`). No role, permission or menu tables exist.
3. **Backend task B1** (`backend-developer`): two attribute edits, backend docs update, `dotnet build`.
4. **Frontend task F1** (`frontend-developer`, TDD): write the failing tests U1-U8 first, then change `AdminNavPermissions`.
5. **Frontend task F2** (`frontend-developer`, TDD): write W1-W3 first, then the Monthly List `readOnly` changes.
6. **Frontend task F3** (`frontend-developer`, TDD): write W4-W7 first, then the Pending Requests `canReview` changes.
   `qa-team-head` reviews after each task (B1, F1, F2, F3). Fixes go back to the same developer. B1 can run in parallel with F1-F3 because they are different repos.
7. **Testing** (`tester`): `flutter analyze`, `flutter test`, `dotnet build`; API authorization matrix A1-A12 against the local API on the local DB; manual UI checks M1-M10 with `flutter run -d chrome` against the local API.
8. **Security check** (`qa-team-head`): whole-branch review of both repos against S1-S9.
9. **Docs and sign-off** (Team Head): update the Flutter docs (`docs/modules/ADMIN_NAVIGATION.md`, `ADMIN_MONTHLY_PAYMENT_LIST.md`, `ADMIN_PENDING_REQUESTS.md`, `docs/AUTHENTICATION.md` role table l.40, `docs/FEATURE_MODULES.md` l.9, `docs/CODEBASE_MAP.md` l.27, `docs/DOC_COVERAGE.md` l.79) and `DECISIONS.md`; run the Phase Completion Checklist and send the phase report. The PM deploys the API (G5).

## 6. PM approvals needed

### PM decisions (2026-11-25), recorded in `docs/DECISIONS.md` as SA1–SA6

| Gate | Decision |
|---|---|
| G1 | **Option A.** Remove Monthly List from Admin and from null/unknown roles. Only FinancialManager and SuperAdmin can access it. |
| G2 | **Option A.** SuperAdmin sees the Terminated Investor tab, read-only. |
| G3 | Use the existing local test credentials where available. **Do not reset any password without PM approval.** Local staff users exist (SuperAdmin, Admin, FinancialManager, MarketingManager) but their passwords are not known to the team; the API authorization tests that need a login for a role wait for the PM to supply it. |
| G4 | Leave the existing wider API read permissions unchanged. |
| G5 | Production deploy and production DB checks are done separately by the PM after local verification. The team never connects to or changes production. |
| G6 | Approved. SuperAdmin sees "View investor payment requests"; the access-denied text becomes role-neutral. |

Extra PM rules: local DB only (`.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE`); do not change production data or credentials; **do not commit any file**; SuperAdmin strictly read-only; no new architecture, endpoints or DB changes.

### Original questions (kept for reference)

| Gate | Question | Recommendation |
|---|---|---|
| **G1** | Admin can open Monthly List in the UI today, but every call returns 403, so the tab is broken. Admin is not in the target matrix. Should Admin (a) **lose the Monthly List drawer item**, or (b) keep it as it is today (visible, read-only after this change, still 403)? Note: Admin shares the fallback set with null/unknown roles, so (a) removes it from those too (they cannot log in on the web anyway). | **(a)** It matches "only FinancialManager and SuperAdmin view" and removes a broken tab. No working Admin workflow is lost. |
| **G2** | The Pending Requests screen includes the **Terminated Investor** tab (block requests). Should SuperAdmin (a) **see it read-only**, or (b) not see that tab? | **(a)** It is part of the screen. SuperAdmin can already read `GetBlockRequests`, and the buttons are hidden. |
| **G3** | API tests need one local login per role (Admin, SuperAdmin, FinancialManager, MarketingManager, Investor) on the **local** DB. Will you give test passwords for the existing local users, or approve resetting those **local** test users' passwords? | Give the test credentials in chat. |
| **G4** | At API level, Admin and FinancialManager can already call `GetPaymentRequests`/`GetBlockRequests`, although the UI never lets them. Leave this unchanged? | **Leave unchanged.** It is outside this request, and tightening it could break other callers. Log it as a follow-up if wanted. |
| **G5** | Production: (a) deploy the API build (no SQL script), and (b) run this read-only query on production to confirm the exact role spelling: `SELECT UserRole, COUNT(*) FROM dbo.UserRegistration GROUP BY UserRole`. The value must be exactly `SuperAdmin`. | The PM runs both; the team never touches the remote DB. |

| **G6** | UI text change. For SuperAdmin, show the Pending Requests subtitle as "View investor payment requests" instead of "Review and approve…", and make the access-denied text role-neutral instead of naming Marketing Manager. Approve? | **Yes.** The current text is wrong for a view-only user. The MarketingManager text stays the same. |

The "Super Admin" label on the login dropdown maps to `SuperAdmin`. No change there.

## 7. Test cases

### 7.1 Unit tests: `test/admin/navigation/admin_nav_permissions_test.dart` (new)
| ID | Case | Expected |
|---|---|---|
| U1 | `allowedDrawerItems('SuperAdmin')` | contains `pendingRequests` and `monthlyList`, plus every item SuperAdmin has today |
| U2 | `allowedDrawerItems('FinancialManager')` | exactly `{monthlyList}` (unchanged) |
| U3 | `allowedDrawerItems('MarketingManager')` | exactly `{pendingRequests}` (unchanged) |
| U4 | `allowedDrawerItems('Admin')`, `(null)`, `('Unknown')` | no `pendingRequests`; `monthlyList` absent (G1 decided: option A); all other items unchanged |
| U5 | `canAccessPendingRequests` | true: MarketingManager, SuperAdmin · false: Admin, FinancialManager, null, `'Investor'`, `'Unknown'` |
| U6 | `canReviewPendingRequests` | true only for MarketingManager (false for SuperAdmin) |
| U7 | `canAccessMonthlyList` / `canModifyMonthlyList` | access: FinancialManager, SuperAdmin (Admin, null, `'Unknown'`, `'Investor'` are all **false**: G1 option A) · modify: FinancialManager only (false for SuperAdmin, Admin, MarketingManager, null, `'Unknown'`) |
| U8 | Role casing and spaces: `'superadmin'`, `'Super Admin'`, `' SuperAdmin '` | same result as `'SuperAdmin'`; `defaultDrawerItem('SuperAdmin')` = dashboard |
| U9 | Existing `reports_navigation_test.dart` | still passes after SuperAdmin gets its own branch (SuperAdmin and Admin can still open the report items; FinancialManager and MarketingManager cannot) |
| U10 | `AdminSideDrawer.destinationsForRole('SuperAdmin')` | labels include "Pending Requests" and "Monthly List"; for 'Admin', neither "Pending Requests" nor "Monthly List" (G1 option A); for FinancialManager and MarketingManager, unchanged single item |

### 7.2 Widget tests
| ID | Widget | Case | Expected |
|---|---|---|---|
| W1 | `MonthlyPaymentTable` | `readOnly: true` with pending rows | no `Checkbox`, no "Approve All", no Approve/Reject tooltips, no "Save"; `onApproveIntentChanged` / `onRejectIntentChanged` / `onSelectAllApproveChanged` / `onApproveAll` / `onSaveRow` callbacks never fire (test passes recording callbacks); "View history", search and status badges visible |
| W2 | `MonthlyPaymentTable` | `readOnly: false` (FinancialManager) | checkboxes, Approve/Reject actions and "Approve All" present (regression) |
| W3 | `MonthlyPaymentTable` | `readOnly: true` at 800 px and 1400 px width | no overflow errors |
| W4 | `PendingRequestCard` | pending request, `canReview: false` | button text "View request" |
| W5 | `PendingRequestCard` | pending request, `canReview: true` | "Review request" (regression) |
| W6 | `ReviewRequestDetailsSection` | pending request, `onAccept`/`onReject` null | no "Approve"/"Reject" buttons; details shown |
| W7 | `ReviewRequestDetailsSection` | pending request, callbacks set | buttons shown (regression) |

The Terminated tab and the full `ReviewRequestScreen` need cubits backed by Dio, so they are covered by manual cases M6-M8. The project has no mocking package and none will be added.

### 7.3 API authorization tests (local API + local DB, one token per role)
Requests that would write data use **invalid ids** (`TransactionId: 0` / `RequestId: 0`). An authorised role then gets **400** from validation and a blocked role gets **403**, because authorization runs before the action. No data changes.

| ID | Call | SuperAdmin | FinancialManager | MarketingManager | Admin | Investor | No token |
|---|---|---|---|---|---|---|---|
| A1 | GET PaymentVerificationList?FromDate&ToDate | **200** | 200 | 403 | 403 | 403 | 401 |
| A2 | GET PaymentVerificationHistory?FromDate&ToDate | **200** | 200 | 403 | 403 | 403 | 401 |
| A3 | POST ReviewPaymentVerification `{transactionId:0}` | **403** | 400 | 403 | 403 | 403 | 401 |
| A4 | GET GetPaymentRequests?status=All | 200 | 200 | 200 | 200 | 403 | 401 |
| A5 | GET InvestorDetails/{validUserId} | 200 | 200 | 200 | 200 | — | 401 |
| A6 | POST ReviewPaymentRequest `{requestId:0}` | **403** | 403 | 400 | 403 | 403 | 401 |
| A7 | GET GetBlockRequests | 200 | 200 | 200 | 200 | 403 | 401 |
| A8 | POST ReviewBlockRequest `{requestId:0}` | **403** | 403 | 400 | 403 | 403 | 401 |
| A9 | A1-A2 response body for SuperAdmin | same JSON shape and totals as FinancialManager for the same dates |
| A10 | Tampered or invalid token | 401 on every call above |
| A11 | `dotnet build` | succeeds, no new warnings |
| A12 | Before any API test run | confirm the API connection string targets `.\SQLEXPRESSMICTCO`; stop otherwise. Call the **HTTPS** URL: `UseHttpsRedirection` returns a 307 on HTTP, which can drop the `Authorization` header and give a false 401. Send `Content-Type: application/json` on POSTs, otherwise allowed roles get 415 instead of 400. |

### 7.4 Manual UI checks (`flutter run -d chrome`, local API)
| ID | Role | Check | Expected |
|---|---|---|---|
| M1 | SuperAdmin | Drawer | Pending Requests and Monthly List shown; lands on Dashboard |
| M2 | SuperAdmin | Monthly List | list and overview load (no 403); no checkboxes, Approve/Reject/Save or Approve All; dates and search work; View history loads |
| M3 | SuperAdmin | Pending Requests list | loads; All/Pending/Approved/Rejected filters and search work; cards say "View request"; subtitle reads "View investor payment requests" |
| M4 | SuperAdmin | Open a pending request | details, KYC and bank shown; no Approve/Reject buttons |
| M5 | SuperAdmin | Open an approved or rejected request | read-only (same as today) |
| M6 | SuperAdmin | Terminated Investor tab (G2 option A) | list loads; no Approve/Reject buttons |
| M7 | FinancialManager | Monthly List | approve one, reject one (with remark), Approve All: same as before |
| M8 | MarketingManager | Pending Requests | review → approve and reject a request; Terminated tab approve/reject: same as before |
| M9 | Admin | Drawer | no Pending Requests and no Monthly List (G1 option A); every other item unchanged |
| M10 | Any role | Widths < 1050 and > 1180 | no layout overflow on both screens |
| M11 | SuperAdmin already logged in before the new build | reload the app | the drawer shows both new items and the data loads, with no re-login needed |

M7 and M8 change data on the **local** DB only. The tester records the transaction and request ids used (or the local DB is restored from its backup afterwards).

### 7.5 Done when
- All U, W, A and M cases pass, `flutter analyze` is clean, `flutter test` is green and `dotnet build` succeeds.
- QA marks the work "Ready" and the security check finds nothing open.
- The docs in §5 step 9 are updated and the decisions are recorded in `docs/DECISIONS.md`.

## 8. Execution status (2026-11-25)

- Done: B1 (2 attributes), F1, F2, F3, QA review (Ready), tester automated runs, security check S1-S11 (Ready).
- Automated: 47 targeted tests pass; `flutter analyze` unchanged (68 baseline); `dotnet build` 0 errors. Full `flutter test`: 3 failures in untouched code (no_sensitive_logging_test on funding_payments_repository.dart; team overview TC-2 x2) - unrelated.
- **API role matrix run 2026-11-25** on the local DB with the PM's logins for SuperAdmin, FinancialManager and MarketingManager: A1, A2, A3, A4, A5, A6, A7, A8, A9 PASS (SuperAdmin 200 on reads, 403 on all three review POSTs; FM and MM unchanged; no token 401). The API ran from a scratch copy with only the local connection string and the worker's catch-up blocked by its own last-run marker, so no email could be sent. Run again only the same way.
- **Not run:** Admin and Investor API cases (no logins), A10 with a validly structured tampered token, and M1-M11 (manual UI). Earlier note, still true for any new run: needs local logins for SuperAdmin, Admin, FinancialManager, MarketingManager, Investor (G3). The API cannot be started casually: `Workers/PaymentReminderWorker.cs` runs a catch-up at startup (after 09:00 IST) and sends real email via `EmailService` with no config switch. Run it with the worker disabled by the PM, or before 09:00 IST and stopped before the 09:00 run, always with `ConnectionStrings__DefaultConnection` overridden to `.\SQLEXPRESSMICTCO` (the default `appsettings.json` points to a remote server).
- PM-only: production deploy and the production check that `UserRegistration.UserRole` is stored exactly as `SuperAdmin` (G5).
