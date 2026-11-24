# Plan: Pending Request card staff name

Spec: `docs/superpowers/specs/2026-11-24-pending-request-staff-name-design.md`

## Tasks
1. **DB design check** (database-architect, read-only): confirm columns/joins on local DB; review Action 18 SQL.
2. **Backend** (backend-developer): edit Action 18 in `Api_InvestorManage.sql` (OUTER APPLY + STRING_AGG, primary first, fallback AssignedStaffId); add `StaffName` to `PaymentRequestListResponse.cs`; `dotnet build`; apply proc change to local DB and verify.
3. **Frontend** (frontend-developer, parallel to 2): model fields, mapping, card staff line, search filter, unit test for parsing; `flutter analyze`, `flutter test`.
4. **QA review** (qa-team-head) then **Tester** run of cases below; security check by QA.
5. **Docs**: update `docs/DATA_MODELS.md`, `docs/API_INTEGRATION.md` (and module doc if present); decision note in `docs/DECISIONS.md`.

## Test cases
| ID | Case | Expected |
|---|---|---|
| T1 | Investor with 2 allocation rows | `staffName` = "Primary, Secondary", primary first |
| T2 | Investor with 1 allocation row | single name |
| T3 | Legacy investor, no allocation rows, AssignedStaffId set | name from AssignedStaffId |
| T4 | Investor with no staff | `staffName` null/empty; card shows "—" |
| T5 | All/Pending/Approved/Rejected filters | row count unchanged vs before; no duplicate rows |
| T6 | JSON without `staffName` (old API) | model parses, `staffName == ''`, no crash |
| T7 | Search by staff name | matching cards remain |
| T8 | Card at width <760 and >=760 | staff line visible, no overflow |
| T9 | `flutter analyze` / `flutter test` / `dotnet build` | clean / pass / succeed |
