# Pending Request card: show investor's staff name (design)

Date: 2026-11-24. Status: approved by PM ("Approve, implement"). Small change.

## Intent
Admins reviewing payment requests want to see which staff member(s) handle each investor, directly on `PendingRequestCard`.

## Goals / non-goals
- Goal: card shows the investor's current staff name(s); search also matches staff name.
- Non-goal: review-request screen, terminated-investors section, historical (at-request-time) staff, any schema change.
- Anti-goal: breaking the existing API contract or the app against an older API.

## Approaches considered
1. Add `StaffName` (comma-joined string) to the Action 18 result. **Chosen**: smallest change, same pattern as `Api_MonthlyPaymentList` (`STRING_AGG`).
2. Return a `StaffAllocations` JSON list like the investor list. Rejected: card only needs names; more parsing for no gain.
3. Frontend looks up staff per investor via a second API. Rejected: N+1 calls.

## Decisions (PM-approved defaults)
- Current staff (not at request time). Both staff when two: "Staff A, Staff B", primary first.
- Fallback to `UserRegistration.AssignedStaffId` when no `InvestorStaffAllocation` rows exist.
- No schema change (reads existing `InvestorStaffAllocation`, `Staff`, `UserRegistration`).

## Contract
`GET /api/Investor/GetPaymentRequests?status=` response item gains `staffName: string | null` (additive). Empty/null renders as "—".

## Parts
- DB: `Sql/Api_InvestorManage.sql`, Action 18 only (backend repo `investmentmanagmentAppApi`). Applied to local `.\SQLEXPRESSMICTCO` only; server deploy is the PM's.
- API: `PaymentRequestListResponse.StaffName`.
- Flutter: `PaymentRequestDataModel.staffName`, `PendingRequestModel.staffName` (+copyWith), staff line in `_ApplicantBlock` (icon `ImageConstants.username`), search filter.

## Rollout
SQL, then API, then app. App tolerates a missing field.
