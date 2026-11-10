# Plan: Security Hardening (client) — 2026-11-09

Source: QA security review 2026-11-09. Decisions: docs/DECISIONS.md (D1–D10).

## Findings and status
| ID | Finding | Owner | Status |
|---|---|---|---|
| C1 | Plain HTTP to raw IP, cleartext allowed | Backend/infra, then client | Open — backend planned |
| H1 | Tokens in SharedPreferences; Android backup on | Frontend | Done (mobile/desktop); web deferred to cookies |
| H2 | Role checks client-only | Backend | Open — backend planned |
| M1 | Release signed with debug key | Build | Open (PM: leave as is) |
| M2 | No global 401 handling | Frontend | Done |
| M3 | CSV formula injection | Frontend | Done |
| L1 | Debug logs show Authorization/password | Frontend | Done |
| L2 | Financial bodies logged | Frontend | Done |
| L3 | Document URLs launched without scheme check | Frontend | Done |

## Tasks
| # | Task | Agent | Status |
|---|---|---|---|
| T1 | Implement client fixes | frontend-developer | Done |
| T2 | QA re-review + low follow-ups | qa-team-head / frontend-developer | Done (Ready) |
| T3 | Tests: LocalStorage token migration, SessionExpiryHandler, URL scheme guard | frontend-developer | Done — 21 tests in `test/core/`, full suite 22/22 (Tester confirmed 2026-11-09) |
| T4 | Full suite + scenarios | tester | Re-run 2026-11-10: PASSED, 35/35, analyze 68, D1 closed. (First run failed — defect D1 (~50 unguarded response-body `log()` calls in 38 files); fix in T4a, then retest |
| T4a | Route all `dart:developer` logging through a debug-only helper; remove response-body logs | frontend-developer | Done — 67 log calls removed, 10 converted to `appLog`; `log_redaction.dart` kept for interceptor lines; leak-scan test added; dev run 31/31, analyze 68 |
| T5 | Final security check on changed code | qa-team-head | Done (Ready, 2026-11-09) |
| T6 | Phase checklist, report, commit (PM: commit mixed files whole) | Team Head | Done 2026-11-10 — signed off; report in docs/plans/SECURITY_HARDENING_PHASE_REPORT.md |
| T7 | Project docs updated: SECURITY, DECISIONS, LOCAL_STORAGE, API_CLIENT_CORE, AUTHENTICATION, CONFIGURATION, DEPENDENCIES, AI_CONTEXT | Team Head | Done |

| T4b | QA fix round on T4a (stopped mid-way by PM 2026-11-09; tree may be partly edited): (1) remove ungated debugPrint in add_new_investor.dart:195 (name + Aadhaar/PAN URLs); (2) log_redaction.dart requestLogLine → method/URI + body field names only; (3) migrate ~28 raw `dart:developer` log() files to appLog, drop unused imports; (4) remove ungated debugPrint in add_investor_form_cards.dart:1758; (5) extend no_sensitive_logging_test: ungated debugPrint/print, raw log(), aadhaar/pan/imageUrl | frontend-developer | Done 2026-11-10 — fixed compile error in log_redaction.dart; leak test caught 3 more leaks (investors_table_section.dart, investors_cubit.dart), removed; dev run 35/35, analyze 68 |

## Resume point (2026-11-10) — completed
1. Run `flutter test` + `flutter analyze` (baseline 68) and `git diff --stat` to see how far T4b got.
2. New frontend-developer agent: finish T4b items 1–5 (check which are done first).
3. Tester: re-run T4 (full suite, analyze, logging grep, control-flow check of script removals).
4. QA: diff review of T4a+T4b → Ready.
5. Team Head: Phase Completion Checklist, phase report, update SECURITY.md, then commit security files (mixed files whole, D11).

## Acceptance criteria
- Tokens never written to SharedPreferences on non-web; legacy prefs token migrated and deleted.
- Logout clears tokens from memory, secure storage and prefs.
- 401 with current token → single logout to login screen; login request 401 and stale-token 401 do not log out.
- CSV cells starting with formula characters are prefixed with `'`; numbers unchanged.
- No Authorization header, password or financial response body in logs.
- Only http/https document URLs open.
- `flutter analyze` adds no issues (baseline 68); `flutter test` all pass.

## Manual verification still required (PM)
- Run investor build on an Android/iOS device: login, restart app (stays logged in), logout.
