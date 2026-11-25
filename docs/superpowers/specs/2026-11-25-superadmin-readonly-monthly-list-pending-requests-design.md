# Spec: SuperAdmin read-only access to Monthly List and Pending Requests

Date: 2026-11-25 · Status: **PM approved 2026-11-25; implemented, not committed** · Plan: `docs/superpowers/plans/2026-11-25-superadmin-readonly-monthly-list-pending-requests-plan.md`

## 1. Goal

Give the `SuperAdmin` role **view-only** access to two admin screens, enforced in both the Flutter admin app and the ASP.NET API:

| Feature | FinancialManager | MarketingManager | SuperAdmin |
|---|---|---|---|
| Monthly List — view (list, overview, history) | Yes | No | **Yes (new)** |
| Monthly List — modify (approve / reject / Approve All) | Yes (unchanged) | No | **No** |
| Pending Requests — view (list, detail, Terminated Investor tab) | No | Yes | **Yes (new)** |
| Pending Requests — accept / reject payment request | No | Yes | **No** |
| Terminated Investor — approve / reject block request | No | Yes | **No** |

FinancialManager and MarketingManager behaviour does not change. No new endpoints, tables, packages or architecture.

## 2. What the code does today (verified 2026-11-25)

The brief said "only Financial Manager can access Monthly List today". The code does not fully match that:

**Frontend** (`lib/admin/navigation/admin_nav_permissions.dart`, `allowedDrawerItems`):
- MarketingManager → `{pendingRequests}`; FinancialManager → `{monthlyList}`.
- **Admin, SuperAdmin, and any other or null role → every drawer item except `pendingRequests`, so Monthly List is included.** The Monthly List screen shows them the full approve/reject UI.
- `canAccessPendingRequests` = MarketingManager only.

**Backend** (`Maribel.Wellness.Api/Controllers/InvestorController.cs`):
- `PaymentVerificationList`, `PaymentVerificationHistory` and `ReviewPaymentVerification` are `[Authorize(Roles = "FinancialManager")]`. Admin and SuperAdmin get **403** when the tab loads, so in practice only FinancialManager can use Monthly List. The Admin and SuperAdmin tab is visible but broken.
- `GetPaymentRequests`, `GetBlockRequests`: `Admin,SuperAdmin,FinancialManager,MarketingManager`. SuperAdmin can **already read** them.
- `InvestorDetails/{userId}` (used by the request detail screen): includes SuperAdmin.
- `ReviewPaymentRequest`, `ReviewBlockRequest`: `MarketingManager` only. SuperAdmin is **already blocked**.
- No service-level role checks. The stored procedures (`Api_PaymentVerificationList`, `Api_PaymentVerificationHistory`, `Api_ReviewPaymentVerification`, `Api_InvestorPaymentRequests`, `Api_InvestorBlockRequests`) only filter on `UserRole = 'Investor'` for the investor rows they return, not on the caller's role. The database has no role or permission table.

**JWT role claim:** `UserServices.GenerateToken` puts the **database** `UserRegistration.UserRole` value into `ClaimTypes.Role` at login and on refresh. `[Authorize(Roles=…)]` compares role strings with `ClaimsPrincipal.IsInRole`, which is ordinal and case-sensitive. The local DB (`.\SQLEXPRESSMICTCO`, `MARIBEL_WELLNESS_CENTRE`) stores exactly `SuperAdmin`, `Admin`, `FinancialManager`, `MarketingManager` and `Investor`. The frontend compares roles with `normalizeRole`, which lowercases and strips spaces.

## 3. Design

### 3.1 Backend (smallest possible change)
- `GetPaymentVerificationList` and `GetPaymentVerificationHistory`: change `[Authorize(Roles = "FinancialManager")]` to `[Authorize(Roles = "FinancialManager,SuperAdmin")]`.
- `ReviewPaymentVerification` stays `FinancialManager` only.
- Pending Requests endpoints: **no change**. Read access for SuperAdmin already exists, and accept/reject is already MarketingManager only.
- No service, SQL, DTO or response-contract change. No DB script.

### 3.2 Frontend
`AdminNavPermissions` stays the single source of truth for role rules. Screens ask it questions and never compare role strings themselves.
- New `isSuperAdmin(role)`.
- `allowedDrawerItems`: add an explicit SuperAdmin branch that returns all items, including `pendingRequests` and `monthlyList`. Admin's set depends on PM gate G1.
- `canAccessPendingRequests` = MarketingManager or SuperAdmin.
- New `canReviewPendingRequests` = MarketingManager only. It covers payment-request accept/reject and block-request approve/reject.
- `canAccessMonthlyList` is unchanged: `canOpen(monthlyList)`.
- New `canModifyMonthlyList` = FinancialManager only.
- `defaultDrawerItem` is unchanged: SuperAdmin still lands on Dashboard.

Screens get the "can act" flag as a **required constructor parameter**, so no call site can silently fall back to a default:
- **Monthly List:** a `MonthlyPaymentTable(readOnly: …)` with `readOnly: true` hides the header select-all checkbox, the per-row approve checkbox column, the Actions column (Approve, Reject, Save) and the "Approve All" button. It keeps search, the From/To date filters, the status badges, the overview cards and "View history". The screen handlers `_onSaveRow` and `_onApproveAll` also return early when the view is read-only. The history screen already has no actions.
- **Pending Requests:** `canReview` is passed from `PendingRequestsScreen` down to the list section, the card (button label becomes "View request"), `ReviewRequestScreen` (passes `onAccept`/`onReject` as `null`, which the existing `canAct` logic already uses to hide the buttons) and `TerminatedInvestorsSection` (passes `onApprove`/`onReject` as `null`, which `_ActionsColumn` already hides). `_accept`/`_reject` also return early.

### 3.3 Security model
The backend is the real control. The frontend only hides controls, because a user can edit the role stored in local storage on web. Every modify endpoint stays restricted by `[Authorize]`, so a SuperAdmin token calling it directly gets 403.

## 4. PM decisions needed (see plan §6)
G1 Admin (and the null/unknown fallback) and Monthly List · G2 Terminated Investor tab for SuperAdmin · G3 local test logins · G4 leave the existing wider API reads as they are · G5 production deploy and role-spelling check · G6 SuperAdmin wording on Pending Requests.

Reviews (2026-11-25): solution-architect "Approve with changes", database-architect "No DB change needed", qa-team-head "Needs Fixes". All changes are applied in the plan.

## 5. Out of scope
The pre-existing wider read access on `GetPaymentRequests`/`GetBlockRequests` for Admin and FinancialManager at API level (G4). The legacy `/api/Investor/MonthlyPaymentList` endpoint, which this screen does not use. The fallback that gives an unknown role the full admin menu. Backend-driven permissions.
