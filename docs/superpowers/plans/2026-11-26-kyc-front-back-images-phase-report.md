# Phase report: KYC front and back images

Date: 2026-11-26. Branch: `feature/high-priority-reports` (both repos). **Nothing committed or pushed.**
Spec: `docs/superpowers/specs/2026-11-26-kyc-front-back-images-design.md`. Plan and test cases: `docs/superpowers/plans/2026-11-26-kyc-front-back-images-plan.md`. Decisions: `docs/DECISIONS.md` K1–K10.

Signed off by: **Not yet.** Waiting for the PM on the items in "PM-only items open".

## 1. What was implemented
- Each KYC document (investor Aadhaar, investor PAN, and Aadhaar/PAN of up to 3 nominees) has a **Front** and a **Back** image: up to 16 images, 20 files with the 4 profile photos.
- The existing upload workflow was extended; there is no new endpoint, service, storage or abstraction. Existing columns and field names are the Front image.
- Register: all 16 images. Update: shows stored images, replaces Front or Back independently, per nominee. Read APIs (GetInvestors, GetAllInvestors, InvestorDetails) return the same 4 investor and 4 nominee properties, always present, `null` when empty.
- × on a KYC box only cancels a newly picked image and restores the stored one. A stored file is deleted only after its replacement was saved and the database update succeeded. Profile photo behaviour is unchanged.
- Read-only screens (mobile document screen, nominee details, admin pending-request review) show Front and Back; a legacy single image shows as Front.
- `RegisterInvestor` got the same 100 MB request limits as `UpdateInvestor`. Register and update calls have a 180 s send/receive timeout set per request; no global timeout changed.

## 2. Database (local `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE` only)
New nullable `VARCHAR(500)` columns: `UserRegistration.AadhaarBackPhoto`, `PanCardBackPhoto`; `InvestorNominee.in_aadhaarbackphoto`, `in_pancardbackphoto`.
Procedures changed: `Api_InvestorManage` (Actions 1, 2, 3, 16) and `Api_GetAllInvestors`. `Api_GetConfirmedInvestorsData` unchanged (no caller).
Scripts (API repo, `Sql/`): `Deploy_KycFrontBack_2026-11-26.sql`, `Rollback_KycFrontBack_2026-11-26.sql`, `Verify_KycFrontBack.sql`; a "superseded, do not re-run" header was added to `Api_InvestorManage_FixPaymentPendingWithRefund.sql`, `Api_InvestorManage_FixTransactionHistoryTotals.sql`, `Deploy_PendingRequestStaffName_2026-11-24.sql`.
Task 1 findings: repo procedure identical to the deployed local one before the change; Action 16 runs in a transaction with rollback in CATCH. Database architect: SQL approved after fixing 2 findings in the Verify and Rollback scripts.

## 3. Files changed
API repo (20 files changed, 3 new SQL files): `Controllers/InvestorController.cs`; 5 request DTOs and 4 response DTOs; `Services/InvestorServices/InvestorServices.cs`; `Sql/Api_InvestorManage.sql`, `Sql/Api_GetAllInvestors.sql`; 3 superseded headers; 4 docs.
Flutter repo (22 files changed plus new files): `lib/admin/investors/**` (6 models, new `kyc_document_images.dart`, repository, add-investor screen and 2 widgets), `lib/user/profile/**` (2 models, 2 widgets), `lib/admin/funding&payments/model/investor_details_models.dart`, `lib/admin/pending_requests/**` (model, review section); docs (`DECISIONS.md`, `DATA_MODELS.md`, 3 module docs); new tests under `test/admin/investors/`, `test/admin/pending_requests/`, `test/user/profile/`.

## 4. API contract
Requests (multipart): every existing front field gets a `…Back…` twin, for example `AadhaarBackPhoto`, `PanCardBackPhoto`, `NomineeAadhaarBackPhoto`, `Nominee2PanCardBackPhoto` (register); `NomineeAadhaarBackPhoto1..3`, `NomineePanCardBackPhoto1..3` (update, same slot as `NomineeId`). Responses: `aadhaarBackPhoto`, `panCardBackPhoto`; per nominee `nomineeAadhaarBackPhoto`, `nomineePanCardBackPhoto`.

## 5. Tests executed (all on the local DB; evidence in the Team Head's run)
| Area | Result |
|---|---|
| SQL `Verify_KycFrontBack.sql` | 27 passed, 0 failed, all changes rolled back |
| API T1–T3 (16 images, 3 read APIs consistent, partial uploads) | Pass |
| API T5–T11, T15 (independent front/back/nominee updates, old-client request, slot order, new nominee) | Pass |
| API T20–T25 (failed register/update cleanup, no stored file touched) | Pass |
| API T26 (≈37 MB register, ≈31 MB update) on Kestrel | Pass |
| API T27 (previous build refuses ≈37 MB, new build accepts) | Pass |
| API T28 (>100 MB refused, no row, no files, stored paths unchanged) | **Pass on behaviour.** The refusal is HTTP **400** "Request body too large" (the plan assumed 413). 2 assertions marked FAIL for that reason only. |
| API T29 (IIS Express in-process, ≈37 MB, >100 MB) | Pass (413 at the IIS layer for >100 MB) |
| API T12 (previous API build on the new procedure: register, update, list, details) | Pass |
| API T31, T33–T36 (legacy single-image investors) | Pass |
| T30 (real Flutter `registerInvestor`, 20 images, local API) | Pass, run in the Dart VM, **not in a browser** (Chrome too slow). The browser XHR adapter was not exercised. |
| Flutter `flutter test` | 420 passed, 3 failed (the 3 known pre-existing: `no_sensitive_logging_test`, 2 in `team_overview_data_test`) |
| `flutter analyze` | 68 issues, 0 errors, none in files changed by this feature |
| `dotnet build` | 0 errors, 453 warnings (same as before) |
| Tester (independent) | Same suite and build results; no new defects |
| QA Team Head | **Ready**, no Blocker or Major; security check: no new findings |

Cases covered by unit or widget tests only (no visual run): T16–T19 (× rule, now with save-path tests), T32 (edit screen of a legacy investor: model level only), T37 (mobile document screen), T38 (pending review; funding/payment details not covered), T42 (layout), T40 (unrelated features: not run live, code untouched, automated suite passes).
Not run: browser run of the admin and mobile screens; T39 as a real old app build (its API-level equivalents T12, T15 and the legacy-shape registrations pass).

## 6. Local test state and cleanup
- 9 test investors (`kyct<seed>_*`, `kyct_web_*`) remain in the local DB with all photo paths cleared; the local test Admin `kyctest_admin` is deactivated. The 84 test images were removed from `wwwroot`. The reminder marker file was restored from git. No test credential file remains.
- The API under test always used a local connection string; no connection to the remote server was made by the API (only SSMS holds one).

## 7. Open items and PM-only items
1. **Deploy (PM):** order is back up the two procedures, `Deploy_KycFrontBack_2026-11-26.sql`, then API, then admin web, then the mobile app. New API + old procedure fails; new app + old API drops back files.
2. **Production hosting checks (PM, not verified by us):** deployed `web.config` `maxAllowedContentLength` is 104857600; no lower request-size limit on the IIS site or any proxy/firewall (≈40 MB uploads).
3. **Visual check (PM or tester with the apps):** admin add/edit investor with 3 nominees; mobile document screen; pending-request review; funding/payment details.
4. **Minor layout:** on the mobile document and nominee screens a lone third tile (for example Aadhaar front and back, PAN front only) stretches to full width, while the admin review keeps it half width.
5. **Known risk, existing and now doubled:** KYC images are public files under `wwwroot` (GUID names, no login check). Update returns `ex.Message` with HTTP 500 (existing).
6. **Commit hygiene:** the untracked files in both repos are all intended (the 3 new SQL scripts in the API repo; spec, plan, this report, `kyc_document_images.dart` and the new test folders in the Flutter repo). The rollback script drops the new columns (back images are lost), so it needs PM approval if data exists.
7. Local DB test investors can be deleted by the PM if wanted (not done, to avoid cascading deletes).

## 7b. Live deployment script (added 2026-11-26, PM decision)
- The PM supplied the live `Api_InvestorManage` (`sp.txt`). It differs from the repo only by 5 extra `AND UR.IsActive = 1` filters (Action 2 list and totals, Action 7, Action 15 x2).
- **Use `Sql/Deploy_KycFrontBack_LiveBased_2026-11-26.sql` for live.** It is the live procedure plus the KYC changes (live filters kept) and the 4 columns. Do NOT use `Deploy_KycFrontBack_2026-11-26.sql` (repo-based; it would drop the live filters).
- Deployed to the local DB only; `Verify_KycFrontBack.sql` 27/27; API stages (register, list, update, cleanup, size limits) re-run: 55 passed, 2 flagged (the same T28 400-vs-413 assertions).
- **PM decision: skip `Api_GetAllInvestors`** (live definition not supplied). Consequence: `GET /api/Investor/GetAllInvestors` will NOT return the back images until that procedure is updated; GetInvestors and InvestorDetails do. The admin list/edit screens use GetInvestors; Manage Users uses GetAllInvestors (not an upload/edit screen). The repo's `Sql/Api_GetAllInvestors.sql` has the back columns but must not be run on live without comparing it with the live definition.
- The repo's `Sql/Api_InvestorManage.sql` and the 3 older full-copy scripts still lack the live `IsActive` filters (drift): do not re-run them on live.

## 8. Documents changed
Flutter: `docs/DECISIONS.md`, `docs/DATA_MODELS.md`, `docs/modules/ADMIN_INVESTORS.md`, `docs/modules/USER_PROFILE.md`, `docs/modules/ADMIN_PENDING_REQUESTS.md`, spec, plan, this report. API: `docs/API_ENDPOINTS.md`, `docs/API_RESPONSE_CONTRACTS.md`, `docs/DATABASE_SCHEMA.md`, `docs/BUSINESS_LOGIC.md`.
