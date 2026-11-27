# KYC front and back images (investor and nominee Aadhaar / PAN) (design)

Date: 2026-11-26. Status: **approved by PM (final approval, Revision 2 plan plus decisions D1–D7 below)**.
Plan and test-case document: `docs/superpowers/plans/2026-11-26-kyc-front-back-images-plan.md` (§6 = test cases T1–T42, §3 = design detail).

## Intent
Each KYC document (Aadhaar, PAN) of the investor and of up to 3 nominees takes a **front** and a **back** image instead of one. Up to **16 KYC images** per investor (4 investor + 12 nominee). Profile photos are separate and unchanged. A request can carry up to 20 files.

## Goals / non-goals
- Goal: register with front and back for all 16 slots; edit shows existing images and replaces front or back independently; GetInvestors, GetAllInvestors and InvestorDetails return the same front/back properties; read-only screens show Front and Back.
- Goal: **extend the existing upload implementation only** (same endpoints, controller, DTOs, service methods, `SavePublicImageAsync`, GUID names and folders, `Api_InvestorManage` actions, nominee slot and `NomineeId` mapping, tracking and cleanup, image picker, multipart building). Each side only gets its own file field, DB column and mapping.
- Non-goals: removing stored images, profile photo changes, a new upload endpoint, storage system or abstraction, moving files out of `wwwroot`, a document table, `Api_GetConfirmedInvestorsData` (no caller unless task 1 finds one), unrelated investor features.
- Anti-goal: breaking old app builds or old API/procedure combinations (see Rollout).

## Approach
New nullable columns, existing columns kept as the **front** image (not renamed):
- `dbo.UserRegistration`: `AadhaarBackPhoto VARCHAR(500) NULL`, `PanCardBackPhoto VARCHAR(500) NULL`
- `dbo.InvestorNominee`: `in_aadhaarbackphoto VARCHAR(500) NULL`, `in_pancardbackphoto VARCHAR(500) NULL`

Rejected: a document table (rewrite of Actions 1, 2, 3, 16 and JSON shapes; fixed image count gives no gain) and a nested `documents[]` request (two contracts to bind).

## Contract
Request fields are the existing front names plus a `…Back…` twin (full table in plan §3.2). Examples: `AadhaarBackPhoto`, `PanCardBackPhoto`, `NomineeAadhaarBackPhoto`, `Nominee2PanCardBackPhoto` (register); `NomineeAadhaarBackPhoto1..3`, `NomineePanCardBackPhoto1..3` (update, same slot as `NomineeId{,2,3}`).
Response (camelCase, always present, `null` when no image), same on all three read APIs:
- investor: `aadhaarPhoto`, `aadhaarBackPhoto`, `panCardPhoto`, `panCardBackPhoto`
- each nominee: `nomineeAadhaarPhoto`, `nomineeAadhaarBackPhoto`, `nomineePanCardPhoto`, `nomineePanCardBackPhoto`

SP: `@AadhaarBackPhoto`, `@PanCardBackPhoto VARCHAR(500) = NULL`; nominee JSON keys `NomineeAadhaarBackPhoto`, `NomineePanCardBackPhoto`.

## Rules
- **Independence:** a NULL or blank value keeps the stored path, per column (4 investor CASEs, 4 nominee COALESCEs). Nominees are matched by `in_id`, never by slot position. Nothing writes a column the request did not supply.
- **Front/back optional (D3):** front only, back only, both or neither. No "back needs front" rule.
- **× (D1, resolves the earlier wording):** × exists only on a **newly picked** KYC image. It cancels that pick and shows the stored image again. It never calls the server and never deletes a server file. A stored image with nothing picked shows no ×. A stored file is deleted **only** when a replacement for that same column was saved **and** the database update succeeded. Profile photo × is unchanged (D7).
- **Failure cleanup:** register or update failure deletes only files saved in that request (existing `uploadedRegistrationFiles` / `newlyUploadedFiles`); stored files and paths are never touched. Existing validate-before-upload order and the register 500 / update 400 difference for a bad extension stay.
- **Legacy images:** an existing single image is the Front. Back is NULL. No backfill.
- **D2:** read-only screens show Front and Back separately: mobile document screen, nominee details, admin pending-request review. An existing single image shows as Front.

## Size and timeout (D4)
Worst case about 40 MB (20 files × 2 MB). `RegisterInvestor` gets `[RequestSizeLimit(104857600)]` and `[RequestFormLimits(MultipartBodyLengthLimit = 104857600)]` like `UpdateInvestor` (default body limit is about 28.6 MB; `FormOptions` and `web.config` already allow 100 MB). Dio `sendTimeout` raised for register and update calls only, through per-request `Options`. No global change.

## Safety
Local DB only (`.\SQLEXPRESSMICTCO`, `MARIBEL_WELLNESS_CENTRE`, Windows auth). `@@SERVERNAME` must equal `FaezLaptop\SQLEXPRESSMICTCO` before any SQL step. The API under test runs with its connection string overridden to the local DB. Branch `feature/high-priority-reports` in both repos; nothing is committed or pushed.

## Rollout (PM, later)
SQL (`Deploy_KycFrontBack_2026-11-26.sql`), then API, then admin web, then mobile app. Old API + new procedure works; new API + old procedure fails; new app + old API drops back files. Rollback drops the new columns (deletes back images) and needs PM approval if data exists.
