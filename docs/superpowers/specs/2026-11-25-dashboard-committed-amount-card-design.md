# Dashboard: Committed Amount card replaces Active Investors

Date: 2026-11-25. Branch: `feature/high-priority-reports`. Module: `lib/admin/dashboard`.

## Request (PM)
The admin Dashboard shows no committed amount by investors. Show it, remove the **Active Investors** card, and use the new card in its place so the stat row stays aligned.

## Findings
- The stat row (`_buildStats` in `widgets/dashboard_overview.dart`) has 6 cards in one `Row`: Total Funding, Amount Received, Amount Remaining, Total Investors, Active Investors, Funding Progress.
- **Active Investors** shows `dashboard.totalInvestors`, the same value as Total Investors (the module doc already flags this as unclear). Removing it loses no information.
- The API already returns the committed total. `GET /api/Dashboard/GetDashboard` returns `TotalInvestmentAmount` (backend `Api_DashboardManage.sql`: sum of `AccountTransaction` rows with `Type = 'Investment'`, filtered by the selected date range). `DashboardModel.totalInvestmentAmount` already parses it, and the Funding Overview card shows it as "Total Investment". The investor screens call the same per-investor figure "Committed" / "Total Committed Investment".
- No backend, API, model, DI or schema change is needed. Card count stays 6, so `DashboardStatsShimmer` (6 placeholders) and the `Row` layout stay valid.

## Design
| Item | Decision |
|---|---|
| Card label | `Committed Amount` |
| Value | `CurrencyFormatter.format(dashboard.totalInvestmentAmount)` |
| Icon | `ImageConstants.totalCommitment` (existing asset, already registered) |
| Colors | reuse the removed card's green: icon `0xFF3CB371`, background `0xFFE8F8EF` |
| Order | Total Funding, **Committed Amount**, Amount Received, Amount Remaining, Total Investors, Funding Progress (target, then committed, then received, then remaining) |
| Removed | Active Investors card in the dashboard only. `ImageConstants.activeInvestors` stays (used by Investors and Manage Users screens) |

Not changed: Investors screen, Manage Users and Reports "Active Investors" cards, Funding Overview "Total Investment" tile, shimmer, cubit, repository.

## Decisions
| # | Decision | Approved by |
|---|---|---|
| C1 | "Committed amount" = `totalInvestmentAmount` from the existing dashboard API | Team Head (verified in backend SQL) |
| C2 | Reuse existing card widget, icon and colors; no new UI component, so no design source is needed | Team Head |
| C3 | Card order as in the table above | Team Head |

## Acceptance criteria
1. Dashboard stat row shows 6 cards in the order above; no "Active Investors" card.
2. Committed Amount shows the rupee-formatted `totalInvestmentAmount`, and updates when the date range is applied.
3. Row has no overflow at the admin widths (web >= 1024 px) and the loading shimmer still shows 6 placeholders.
4. `flutter analyze` adds no new issues; `flutter test` passes.
5. `docs/modules/ADMIN_DASHBOARD.md` updated.
