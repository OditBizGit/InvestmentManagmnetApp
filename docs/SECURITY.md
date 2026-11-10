# Security

Findings, fixes, open risks and review results. Sources: QA Team Head security review and re-review (2026-11-09). Plan: plans/SECURITY_HARDENING_PLAN.md. Decisions: DECISIONS.md.

## Findings
| ID | Severity | Finding | Fix | Status |
|---|---|---|---|---|
| C1 | Critical | `kBaseUrl` is `http://103.38.50.206:3052/`; Android `usesCleartextTraffic="true"`. Credentials, tokens and financial data travel unencrypted | HTTPS on a domain, then switch `kBaseUrl`, remove cleartext | Open: backend/infra planned (D1) |
| H1 | High | Tokens in SharedPreferences (web `localStorage`); Android backup on | `flutter_secure_storage` on mobile/desktop, legacy-token migration, `allowBackup="false"` | Fixed for mobile/desktop. Web deferred to HttpOnly cookies (D3) |
| H2 | High | Roles enforced only in the client; editable `user_role` unlocks admin UI | Backend authorises each endpoint by the JWT role and rejects mismatched `userRole` at login | Open: backend planned (D2) |
| M1 | Medium | Android release signed with debug key | Real release keystore via git-ignored `key.properties` | Open: PM chose to leave as is (D7) |
| M2 | Medium | No global 401 handling; expired token kept | `TokenRefreshService` refreshes + replays on 401; `SessionExpiryHandler`: logout + login screen only if the refresh token is rejected | Fixed (D6, superseded by D7) |
| M3 | Medium | CSV formula injection in user export | `escapeCsvField` (`lib/core/utils/csv_escape.dart`) prefixes `= + - @ \t \r` with `'`, numbers excluded | Fixed (D9) |
| L1 | Low | Debug logs print Authorization header and password | Masked in request logs | Fixed |
| L2 | Low | Financial response bodies and PII logged (ungated `debugPrint`, ~77 raw `log()` calls) | All logging goes through debug-only `appLog` (`lib/core/utils/app_log.dart`); interceptor lines built by `log_redaction.dart` (method/URI/field names/status only); body/PII logs removed; `no_sensitive_logging_test.dart` scans `lib/` | Fixed (D1 closed 2026-11-10) |
| L3 | Low | Server document URLs launched without scheme check | Only http/https launched (`lib/core/utils/url_scheme_guard.dart`) | Fixed |

## Open risks
- C1 and H2 are release blockers until the backend work lands.
- Admin web tokens remain readable by XSS until cookie-based auth.
- Debug-build error lines log the server `message` string as received.
- The leak scanner's `kDebugMode` lookback (250 chars) could miss an ungated print near an unrelated guard (low).
- A failed secure-storage write keeps the token in memory only; the user must log in again after restart.
- macOS has no keychain entitlement in `macos/Runner`; secure storage there is unverified.
- Secure storage not yet tested on a real Android/iOS/Windows device.

## Review results
- 2026-11-09 QA review: Needs Fixes (C1, H1, H2, M1–M3, L1–L3).
- 2026-11-09 QA re-review of client fixes: Ready, with four low follow-ups (stale-token 401, secure-write failure, remaining logs, numeric CSV values), all fixed.
- Verification (Team Head run): `flutter test` 7/7 passed; `flutter analyze` 68 issues, same as baseline.
- T3 tests added in `test/core/`: csv_escape, local_storage, session_expiry_handler, url_scheme_guard. No test covers the 401 handler's navigation path.
- 2026-11-09 QA final security check (T5): Ready; no secrets in code or tests.
- 2026-11-09 Tester run (T4): `flutter test` 22/22 passed, `flutter analyze` 68 (baseline). Failed on defect D1 (Major): ~50 unguarded `dart:developer` `log()` calls in 38 files print API response bodies. Fixed in T4a/T4b.
- 2026-11-10 T4b: fixed compile error in `log_redaction.dart`; stricter scanner caught and removed 3 more PII/image-URL logs (investors_table_section, investors_cubit) and 2 form-field-value logs (add_banner, update_construction repositories).
- 2026-11-10 Tester T4 re-run: PASSED, 35/35, analyze 68, D1 closed. QA review of T4a+T4b: Ready. Team Head run: 35/35, analyze 68.
- 2026-11-10 Phase signed off by Team Head.
- Not covered by tests: web token path (`kIsWeb`); logout-button and document-card call-site wiring; device login/restart/logout check (PM, manual).

## Checked and fine
Export filenames are timestamp-generated; WhatsApp reminder text is URL-encoded; upload pickers use extension allowlists.
