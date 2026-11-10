# Decisions Log

Format: date — decision — approved by — status.

## 2026-11-09 — Security hardening (plan: docs/plans/SECURITY_HARDENING_PLAN.md)

| # | Decision | Approved by | Status |
|---|---|---|---|
| D1 | API moves to HTTPS on a domain; remove `usesCleartextTraffic` and switch `kBaseUrl` to https once backend is ready | PM | Planned (backend) |
| D2 | Backend enforces roles per endpoint from the JWT and rejects mismatched `userRole` at login; client role checks only hide UI | PM | Planned (backend) |
| D3 | Investor mobile/desktop store auth + refresh tokens in `flutter_secure_storage`; admin web keeps SharedPreferences until backend issues HttpOnly Secure cookies | PM | Done (client) |
| D4 | New dependency `flutter_secure_storage ^9.2.4` | PM | Approved |
| D5 | Android `allowBackup="false"` | Team Head | Done |
| D6 | Global 401 handling = clear session + go to login (no refresh flow); only when the failed request carried the current token | PM (logout only) / Team Head (token match) | Superseded by D7 (logout now happens only after the refresh token is rejected) |
| D7 | Refresh-token flow: proactive refresh shortly before access-token `exp`, reactive 401 refresh + single replay, one shared in-flight refresh, best-effort `POST /api/User/Logout` on logout; logout only when the refresh token is rejected | PM (2026-11-10) | Done (client); backend `Jwt:EnforceExpiry` stays off until this app version is released |
| D7 | Release signing (M1) left on debug key for now | PM | Open finding |
| D8 | All client-only fixes (H1 mobile, M2, M3, L1–L3) implemented in one batch | PM | Done |
| D9 | CSV export neutralises leading `= + - @ \t \r`, except purely numeric values | Team Head | Done |
| D10 | Secure-storage write failure keeps token in memory only (not plaintext prefs); session lost on restart | Team Head | Done |
| D11 | Commit: the seven files that mix security fixes with earlier PM edits are committed whole | PM | Approved |
