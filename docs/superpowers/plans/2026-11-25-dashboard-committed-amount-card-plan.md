# Plan: Dashboard Committed Amount card

Spec: `docs/superpowers/specs/2026-11-25-dashboard-committed-amount-card-design.md`

## Tasks
1. **Frontend** (frontend-developer): test first, then edit `lib/admin/dashboard/widgets/dashboard_overview.dart` `_buildStats`: add Committed Amount card, remove Active Investors card, set order. Widget test in `test/admin/dashboard/`. Backend, DB and architecture agents are not needed (no API, schema or structure change).
2. **QA review** (qa-team-head): diff review against acceptance criteria, security check.
3. **Tester**: run test cases below, `flutter analyze`, `flutter test`.
4. **Docs** (Team Head): `docs/modules/ADMIN_DASHBOARD.md` (stat cards, Unclear item, files table); fix stale endpoint path in `docs/API_INTEGRATION.md` (`GetDashboard`, not `GetFundingDashboard`); decision rows in `docs/DECISIONS.md`.

## Test cases
| ID | Case | Expected |
|---|---|---|
| T1 | Dashboard loaded with `totalInvestmentAmount = 2500000` | "Committed Amount" card shows the formatted amount |
| T2 | Same state | No card labelled "Active Investors"; exactly 6 cards |
| T3 | Card order | Total Funding, Committed Amount, Amount Received, Amount Remaining, Total Investors, Funding Progress |
| T4 | `totalInvestmentAmount = 0` | Card shows zero amount, no crash |
| T5 | Width 1024 and 1440 | No overflow error |
| T6 | Loading state | Shimmer with 6 placeholders |
| T7 | `flutter analyze`, `flutter test` | No new issues; all pass |
