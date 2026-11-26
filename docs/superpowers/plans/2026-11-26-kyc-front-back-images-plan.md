# Plan: KYC front and back images (investor and nominee Aadhaar / PAN)

Spec: not written yet. It goes to `docs/superpowers/specs/2026-11-26-kyc-front-back-images-design.md` after the PM gives final approval.
Status: **Implemented and tested 2026-11-26 after PM final approval (Revision 2 plus D1–D7). Results and open items: `2026-11-26-kyc-front-back-images-phase-report.md`. Nothing committed.**
Repos: Flutter app (this repo) · API `C:\Users\LENOVO\StudioProjects\investmentmanagmentAppApi\Maribel.Wellness.Api`
Branch: **the current active branch `feature/high-priority-reports` in both repos (C9)**. No new branch.
DB rule: **only the local `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE` (C8)**. See §3.9. Production is never touched.
Reviews: database-architect (Design mode) and solution-architect both reviewed the approach on 2026-11-26 and agree with it.

---

## 0. PM clarifications (revision 2) and where they are covered

| ID | PM clarification | Covered in |
|---|---|---|
| C1 | Support 16 document images in total: 4 investor and 12 nominee (3 nominees × 4) | §1.1, §3.2, §3.8, T1, T3, T5–T8 |
| C2 | GetInvestors, GetAllInvestors and InvestorDetails return the same front/back properties for investors and nominees | §3.2.1, T2 |
| C3 | Updating one side never changes the other side, and updating one nominee never affects another | §3.3, T9–T15 |
| C4 | × is replace-only: × on a newly picked image cancels it and restores the existing image. Existing server files are never deleted. | §3.6, T16–T19 |
| C5 | A failed register or update cleans up only the files uploaded in that request, never files stored earlier | §3.7, T20–T25 |
| C6 | Check multipart size limits across ASP.NET Core, IIS and the hosting configuration | §3.8, T26–T30 |
| C7 | Regression tests for existing investors with only one image; all existing screens keep working | §6.5, T31–T40 |
| C8 | All database changes and tests only on the local `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE`; production is never touched | §3.9, §8 |
| C9 | Work only on the current active branch | Header, §5 |

---

## 1. Requirement

### 1.1 Image count (C1)

Each investor has up to **16 KYC document images**:

| Owner | Aadhaar | PAN | Images |
|---|---|---|---|
| Investor | Front, Back | Front, Back | 4 |
| Nominee 1 | Front, Back | Front, Back | 4 |
| Nominee 2 | Front, Back | Front, Back | 4 |
| Nominee 3 | Front, Back | Front, Back | 4 |
| **Total** | | | **16** (4 investor + 12 nominee) |

The **profile photos** (1 investor and up to 3 nominees) are not KYC documents and do not change. A register or update request can therefore carry up to **20 files**: 16 document images and 4 profile photos. The size checks in §3.8 use 20 files.

### 1.2 Scope

- **Register investor:** upload front and back for all four document types, for the investor and every nominee.
- **Update investor:** show the existing images, and replace the front or the back on its own without changing the other side or any other nominee.
- **Investor retrieval APIs** (GetInvestors, GetAllInvestors, InvestorDetails): return the front and back paths for all four document types, with the same property names.

Constraints:

- Keep the existing register and update flows.
- Images uploaded before this change must stay accessible.
- Front and back are independent. A partial upload (one side only) is allowed.
- Do not change unrelated modules. Keep the Flutter and API contracts consistent.

---

## 2. Current implementation (verified in code and the local DB, 2026-11-26)

### 2.1 Database

| Table | Column | Type |
|---|---|---|
| `dbo.UserRegistration` | `AadhaarPhoto`, `PanCardPhoto` | `varchar(500) NULL` |
| `dbo.UserRegistration` | `ProfileImage` | `nvarchar(500) NULL` |
| `dbo.InvestorNominee` | `in_aadhaarphoto`, `in_pancardphoto`, `in_profilephoto` | `varchar(500) NULL` |

- Values are relative paths under `wwwroot`, for example `/investordocuments/aadhaar/<guid>.jpg`.
- Folders: `investordocuments/aadhaar`, `investordocuments/pan`, `nomineedocuments/aadhaar`, `nomineedocuments/pan`.
- Local data: 4 investors and 1 nominee. **None of them has an Aadhaar or PAN photo**, so test data must be created (§6.1).
- Database objects that reference the photo columns on the local DB: `Api_InvestorManage` (modified 2026-11-24) and `Api_GetConfirmedInvestorsData`.
- **`Api_GetAllInvestors` is not deployed on the local DB**, even though `GET /api/Investor/GetAllInvestors` calls it (R1).

### 2.2 Stored procedure `Sql/Api_InvestorManage.sql`

| Part | Lines (approx.) | What it does with the photos |
|---|---|---|
| Parameters | ~81-83 | `@AadhaarPhoto`, `@PanCardPhoto VARCHAR(500) = NULL`, `@NomineesJson NVARCHAR(MAX)` |
| Action 1 (register) | ~370-415 | Inserts `AadhaarPhoto`, `PanCardPhoto` into `UserRegistration` |
| Action 1 (register) | ~555-615 | Inserts nominees from `OPENJSON(@NomineesJson)` with `NomineeAadhaarPhoto`, `NomineePanCardPhoto` |
| Action 2 (GetInvestors) | ~708-770 | Selects `UR.AadhaarPhoto`, `UR.PanCardPhoto`; nominees as a `FOR JSON PATH` subquery |
| Action 3 (InvestorDetails) | ~1185-1210, ~1930-1950 | Investor row, plus result set 4 with active nominees |
| Action 16 (update) | ~4360-4380 | `CASE WHEN NULLIF(LTRIM(RTRIM(@AadhaarPhoto)),'') IS NOT NULL THEN @AadhaarPhoto ELSE AadhaarPhoto END`: **a blank parameter keeps the old value** |
| Action 16 (update) | ~4500-4680 | `@NomineeInput` table from OPENJSON. Ownership check (`in_userid = @UserId`, otherwise THROW 50001) and duplicate-id check (THROW 50002). The UPDATE joins **on `in_id = NomineeId`**, one row per nominee, with `COALESCE(NULLIF(...),'', old)` for each photo. Nominees with id 0 are inserted. A legacy single-nominee branch (~4679) writes no photos. |

### 2.3 Other procedures

- `Sql/Api_GetAllInvestors.sql`: used by `GetAllInvestorsAsync`. Selects `UR.AadhaarPhoto`, `UR.PanCardPhoto` (~45) and the nominee `FOR JSON` (~74-89).
- `Sql/Api_GetConfirmedInvestorsData.sql`: no C# caller found.
- Full copies of `Api_InvestorManage` also exist in the repo: `Api_InvestorManage_FixPaymentPendingWithRefund.sql`, `Api_InvestorManage_FixTransactionHistoryTotals.sql`, `Deploy_PendingRequestStaffName_2026-11-24.sql` (R2).

### 2.4 API (`Maribel.Wellness.Api`, .NET 9)

| File | Notes |
|---|---|
| `Controllers/InvestorController.cs` `RegisterInvestor` (~28-170) | `[FromForm] InvestorRegistrationFormRequest`, flat fields `Nominee*`, `Nominee2*`, `Nominee3*`, mapped into `InvestorRegistrationRequest.Nominees`. **No `[RequestSizeLimit]` or `[RequestFormLimits]`** (§3.8). |
| `Controllers/InvestorController.cs` `UpdateInvestor` (~368) | `[RequestSizeLimit(104857600)]` and `[RequestFormLimits(MultipartBodyLengthLimit = 104857600)]` |
| `Program.cs` ~51 | `FormOptions.MultipartBodyLengthLimit = 100 MB`. No `IISServerOptions` or `KestrelServerOptions` configuration. Default System.Text.Json (camelCase, nulls are written). |
| `web.config` | `requestFiltering/requestLimits maxAllowedContentLength="104857600"`, `hostingModel="inprocess"` |
| `Properties/launchSettings.json` | Profiles `http` / `https` (Kestrel) and `IIS Express`. IIS Express is installed on this machine. |
| `InvestorServices.cs` `RegisterInvestorAsync` (52-568) | Saves files with `SavePublicImageAsync` (JPG/JPEG/PNG only, GUID file names). Tracks them in `uploadedRegistrationFiles` and deletes them through `CleanupRegistrationUploads` when the SP reports an error, on exceptions, and on the nominee-photo extension check. |
| `InvestorServices.cs` `GetInvestorsAsync` (~800-945), `GetAllInvestorsAsync` (~947-1045) | Hand-written mapping (`AadhaarPhoto = (string?)row.AadhaarPhoto`, ~857 and ~993). Nominees deserialized from JSON into `NomineeResponse`. |
| `InvestorServices.cs` `GetInvestorDetailsAsync` (~1046-1200) | Investor row mapped by hand (~1133). Nominees read with `ReadAsync<InvestorNomineeResponse>` (mapped by column name). |
| `InvestorServices.cs` `UpdateInvestorAsync` (2602-3180) | Validation and the "investor exists" check run **before** any upload. Reads old paths for the investor and each nominee (`oldNomineePhotos[nomineeId]`). New files are saved as tracked uploads (`newlyUploadedFiles`), and NULL is sent for files that were not sent. Deletes an old file **only for a column that got a new file, and only after the SP succeeds** (~3070-3115). Deletes new files when the SP reports an error or an exception is thrown. |

### 2.5 Flutter app

| File | Notes |
|---|---|
| `lib/admin/investors/model/investor_model.dart` | `aadhaarCardImage` / `panCardImage` read from `aadhaarPhoto` / `AadhaarPhoto` / … (~288-304). URL getters at ~150-167. |
| `lib/admin/investors/model/investor_nominee_record.dart` | `aadhaarCardImage` / `panCardImage` from `nomineeAadhaarPhoto` / … (~105-120). URL getters at ~31-33. |
| `lib/admin/investors/model/investor_nominee_entry.dart` | Form state: `aadhaarCardPhoto`, `existingAadhaarCardImageUrl`, `panCardPhoto`, `existingPanCardImageUrl`; `hasAnyData`, `applyFromRecord`, `nomineeRecordsFromInvestor` |
| `lib/admin/investors/model/investor_nominee_submit.dart` | Register keys `NomineeAadhaarPhoto` / `Nominee2…` / `Nominee3…` (~140-162). Update sends 3 slots, each with `NomineeId{,2,3}` and keys `NomineeAadhaarPhoto{1,2,3}` (~165-220). A file is added only when it is not null. |
| `register_investor_model.dart` (~132-135), `update_investor_model.dart` (~133-137) | Add `AadhaarPhoto` / `PanCardPhoto` files only when one was picked |
| `screens/add_new_investor/add_new_investor.dart` | **One form for register and edit.** Pre-fill (~194), reset (~600), submit (~717-836), pick and clear handlers (~1004-1066). Today the clear handlers set **both** the picked photo **and** the existing URL to null. |
| `…/widget/add_investor_additional_information.dart` | KYC card (~199-320) and nominee block (~405-650) use `AddInvestorPhotoUploadBox` |
| `…/widget/add_investor_form_cards.dart` | Passes values through (~96-252). `AddInvestorPhotoUploadBox` (~1770) shows × whenever any image is shown, and its subtitle always says "Current profile photo" for an existing image. |
| `lib/core/utils/photo_picker_helper.dart:25` | Each image is limited to 2 MB (`maxBytes`) |
| `lib/core/network/service_locator.dart:91-93` | Dio 5.8: `connectTimeout` and `sendTimeout` are 30 s for every request |

How editing works today: the edit screen gets the existing images from the **list API** (`InvestorModel`). So the list APIs must return the back images, or edit cannot show them.

Read-only screens that show document images:

- `lib/user/profile/model/investor_details_model.dart` and `investor_nominee_model.dart`, with the mobile document screen widgets `additional_information_card.dart` and `nominee_details_card.dart`.
- `lib/admin/funding&payments/model/investor_details_models.dart`, which feeds the pending-request review `review_request_details_section.dart` (~655-700, ~962).

---

## 3. Design

### 3.1 Database: add columns, not a document table

New nullable columns, with no default, constraint or index:

| Table | New columns |
|---|---|
| `dbo.UserRegistration` | `AadhaarBackPhoto varchar(500) NULL`, `PanCardBackPhoto varchar(500) NULL` |
| `dbo.InvestorNominee` | `in_aadhaarbackphoto varchar(500) NULL`, `in_pancardbackphoto varchar(500) NULL` |

- **The existing columns stay as they are and now mean the front image.** They are not renamed.
- Because each nominee is its own `InvestorNominee` row, the 4 columns cover all 16 images (C1).
- Why columns:
  - The number of images is fixed.
  - The code expects flat rows: one large procedure with Action numbers, Dapper mapping by hand or by column name, one flat JSON object per nominee (`OPENJSON`), and `FOR JSON` nominee subqueries.
  - A document table would need a new table, rewrites of Actions 1, 2, 3 and 16, and pivots inside the JSON subqueries.
- No CHECK such as "back needs front": that business rule has not been approved (D3).

### 3.2 API contract

**Request (multipart)**

| Owner | RegisterInvestor field | UpdateInvestor field |
|---|---|---|
| Investor, Aadhaar front / back | `AadhaarPhoto` / `AadhaarBackPhoto` | `AadhaarPhoto` / `AadhaarBackPhoto` |
| Investor, PAN front / back | `PanCardPhoto` / `PanCardBackPhoto` | `PanCardPhoto` / `PanCardBackPhoto` |
| Nominee 1, Aadhaar front / back | `NomineeAadhaarPhoto` / `NomineeAadhaarBackPhoto` | `NomineeAadhaarPhoto1` / `NomineeAadhaarBackPhoto1` |
| Nominee 1, PAN front / back | `NomineePanCardPhoto` / `NomineePanCardBackPhoto` | `NomineePanCardPhoto1` / `NomineePanCardBackPhoto1` |
| Nominee 2, Aadhaar front / back | `Nominee2AadhaarPhoto` / `Nominee2AadhaarBackPhoto` | `NomineeAadhaarPhoto2` / `NomineeAadhaarBackPhoto2` |
| Nominee 2, PAN front / back | `Nominee2PanCardPhoto` / `Nominee2PanCardBackPhoto` | `NomineePanCardPhoto2` / `NomineePanCardBackPhoto2` |
| Nominee 3, Aadhaar front / back | `Nominee3AadhaarPhoto` / `Nominee3AadhaarBackPhoto` | `NomineeAadhaarPhoto3` / `NomineeAadhaarBackPhoto3` |
| Nominee 3, PAN front / back | `Nominee3PanCardPhoto` / `Nominee3PanCardBackPhoto` | `NomineePanCardPhoto3` / `NomineePanCardBackPhoto3` |

That is 16 document fields per endpoint (bold names are new: every `…Back…` field). The front field names are unchanged. The update nominee files stay in the same slot as `NomineeId` / `NomineeId2` / `NomineeId3`, so each file reaches the right nominee.

SP parameters are `@AadhaarBackPhoto` and `@PanCardBackPhoto VARCHAR(500) = NULL`. The nominee JSON objects get the keys `NomineeAadhaarBackPhoto` and `NomineePanCardBackPhoto`.

#### 3.2.1 Response: the same properties on all three retrieval APIs (C2)

| Level | Property (JSON, camelCase) | GetInvestors | GetAllInvestors | InvestorDetails |
|---|---|---|---|---|
| Investor | `aadhaarPhoto` (front), `aadhaarBackPhoto` | ✓ | ✓ | ✓ |
| Investor | `panCardPhoto` (front), `panCardBackPhoto` | ✓ | ✓ | ✓ |
| `nominees[]` | `nomineeAadhaarPhoto` (front), `nomineeAadhaarBackPhoto` | ✓ | ✓ | ✓ |
| `nominees[]` | `nomineePanCardPhoto` (front), `nomineePanCardBackPhoto` | ✓ | ✓ | ✓ |

How each API gets these values:

| API | Investor source → DTO | Nominee source → DTO |
|---|---|---|
| GetInvestors | `Api_InvestorManage` Action 2 → `InvestorListResponse` (hand mapping ~857) | Action 2 `FOR JSON` → `NomineeResponse` |
| GetAllInvestors | `Api_GetAllInvestors` → `InvestorListResponse` (hand mapping ~993) | `Api_GetAllInvestors` `FOR JSON` → `NomineeResponse` |
| InvestorDetails | Action 3 row → `InvestorDetailsResponse` (hand mapping ~1133) | Action 3 result set 4 → `InvestorNomineeResponse` (by column name) |

Rules that keep the three APIs the same:

- The SQL aliases are exactly `AadhaarBackPhoto`, `PanCardBackPhoto`, `NomineeAadhaarBackPhoto` and `NomineePanCardBackPhoto` in all three sources. They match the C# property names.
- All four DTOs get the same property names (`InvestorListResponse` and `InvestorDetailsResponse`; `NomineeResponse` and `InvestorNomineeResponse`).
- `FOR JSON PATH` leaves out NULL values. The C# DTO turns a missing key into `null`, and System.Text.Json writes nulls, so **every property is always present in the response**, with `null` when that side has no image. Front and back follow the same rule, and so do all three APIs.
- Test T2 compares the three responses for the same investors property by property.

### 3.3 Front and back stay independent, and nominees stay independent (C3)

#### 3.3.1 One side never changes the other side

1. **Flutter** adds a file to the form only for the side that was picked. The other side's key is not sent at all.
2. **API** saves only the files it received. It sends NULL for every other column or JSON key.
3. **Stored procedure** writes each column separately and keeps the stored value when its parameter or JSON value is NULL or blank:
   - Investor: 4 separate `CASE` expressions: `AadhaarPhoto`, `AadhaarBackPhoto`, `PanCardPhoto`, `PanCardBackPhoto`.
   - Nominee: 4 separate `COALESCE(NULLIF(LTRIM(RTRIM(N.x)),''), I.x)` expressions.
4. **API** deletes an old file only for the column that got a new file, and only after the SP succeeds. The old path is read per column before the update. New file names are GUIDs, so a new path never equals an old one.

#### 3.3.2 One nominee never affects another nominee

- **API:** each update slot is built from its own fields (`NomineeId2` with `NomineeAadhaarBackPhoto2`, and so on). Empty slots (id 0 and no data) are skipped (`AddNominee` → `hasData`).
- **SP:**
  - The UPDATE joins `InvestorNominee` to `@NomineeInput` **on `in_id = NomineeId`**, so each JSON object changes only its own row.
  - Ids that belong to another investor are rejected (THROW 50001), and duplicate ids are rejected (THROW 50002).
  - Nominees with id 0 are inserted as new rows.
- **API cleanup:** old files are looked up in `oldNomineePhotos[nomineeId]`, so only the updated nominee's replaced file is deleted.
- **Flutter:** the edit form keeps each nominee's `nomineeId` in its `InvestorNomineeEntry`. Slot keys are built from the same index for the id and for the files.

#### 3.3.3 Checks before coding (task 1)

database-architect confirms in the deployed procedure that:

- Action 16 runs in a transaction and rolls back on an error, so a failed update never leaves some columns changed.
- No other part of Action 16 writes the photo columns.

### 3.4 Existing images

- Each existing single image becomes the **front** image. Back stays NULL.
- No backfill, no file moves, no path changes.
- The edit screen shows the old image in the Front slot. The read-only screens show it as Front (D2).
- Some older uploads may be front and back scanned together; they stay readable.

### 3.5 Backward compatibility

| Combination | Result |
|---|---|
| Old mobile/admin build + new API | Works. It never sends back fields, so stored backs are kept. It ignores the new response fields. |
| Old API + new procedure | Works. The new parameters default to NULL, and extra columns are ignored. |
| New API + old procedure | **Fails** with "too many arguments". SQL must be deployed first. |
| New app + old API | Back files are silently dropped. The API must be deployed before the app. |

Deploy order for the PM's later production release: DDL, then procedures, then API, then admin web, then the mobile app. **That deployment is the PM's own action and is not part of this work (C8).**

### 3.6 × button: replace-only (C4, decision D1 approved)

The rule for each of the 16 KYC upload boxes:

| Box state | × shown? | What × does |
|---|---|---|
| Empty (no stored image, nothing picked) | No | n/a |
| Stored image only (edit mode) | **No.** Removing a stored image is not supported. | n/a. Tapping the box still opens the picker to replace it. |
| Newly picked image, no stored image (register, or edit with an empty side) | Yes | Cancels the pick. The box goes back to empty. |
| Newly picked image over a stored image (edit) | Yes | **Cancels the pick and shows the stored image again** |

- × changes only the form state: the picked file is set to null and the stored URL is kept. Nothing is sent to the server, so no stored file can be deleted.
- After a cancel, saving sends no file for that side, so the SP keeps the stored path (§3.3.1).
- Each side has its own state, so cancelling Front never changes Back, and the reverse.
- Implementation:
  - The clear handlers set only the picked photo to null. Today they also null the existing URL, so that line is removed.
  - The KYC boxes show × only when a picked photo exists (`showClearOnlyForPicked` on `AddInvestorPhotoUploadBox`, or the same rule inside `AddInvestorKycPhotoPair`).
- **Profile photo boxes keep today's behaviour.** The PM's instruction covers the KYC documents (D7).

### 3.7 Cleanup when a register or update fails (C5)

| Failure | Files deleted | Stored files |
|---|---|---|
| Register: SP reports an error (`@IsException`, for example a duplicate username) | All files saved in this request (`uploadedRegistrationFiles`, including all 16 document images and the profile photos) | None exist yet |
| Register: exception while saving (for example a back image with a bad extension, or an IO error) | Files saved in this request before the failure | None exist yet |
| Register: the duplicate email/phone check fails | None. The check runs before any upload. | n/a |
| Update: validation fails (bad UserId, more than 3 nominees, duplicate nominee ids, investor not found) | None. The checks run before any upload. | Not touched |
| Update: SP reports an error (`@IsException`, for example a foreign nominee id) | All files in `newlyUploadedFiles` | **Not touched.** The deletion of old files is skipped because the SP did not succeed. |
| Update: exception (bad extension, IO, SQL) | All files in `newlyUploadedFiles` (`CleanupNewlyUploadedFiles`) | **Not touched** |
| Update: succeeds | n/a | Only the old file of each column that got a new file is deleted |

Rules:

- Every new back-image save goes through the same tracked-save helper (`SavePublicImageAsync` added to `uploadedRegistrationFiles`, or `SaveTrackedImageAsync` adding to `newlyUploadedFiles`). No untracked save path is added.
- The cleanup helpers delete only paths in this request's list. They also refuse paths outside `wwwroot` and absolute URLs (existing guards).
- If the old file cannot be deleted after a successful update, that is ignored (existing behaviour). The database is already correct; the only effect is an orphaned file.
- Existing behaviour that stays the same: on register, a bad file extension returns **500** (its `catch (Exception)`), while update returns **400**. Changing this is out of scope; it is noted for QA.

### 3.8 Multipart request size limits (C6)

#### 3.8.1 Worst-case request

- 20 files: 16 document images and 4 profile photos. Each is at most 2 MB (`PhotoPickerHelper.maxBytes`).
- About **40 MB**, plus about 100 text fields.
- Today's worst case (12 files) is about 24 MB.

#### 3.8.2 Every layer, current value and planned change

| Layer | Setting | Current | Register after change | Update after change |
|---|---|---|---|---|
| Flutter client | `PhotoPickerHelper.maxBytes` per image | 2 MB | 2 MB (unchanged) | 2 MB (unchanged) |
| Flutter client (Dio 5.8) | `sendTimeout` | 30 s for all requests | **Longer, through per-request `Options` (proposed 180 s)** | **Same** |
| ASP.NET Core form reader | `FormOptions.MultipartBodyLengthLimit` (`Program.cs`) | 100 MB global | 100 MB, plus `[RequestFormLimits(MultipartBodyLengthLimit = 104857600)]` | 100 MB (attribute already there) |
| ASP.NET Core form reader | `FormOptions.ValueCountLimit` (default 1024), `ValueLengthLimit` (default 4 MB) | Defaults | About 100 fields, each small: within the defaults | Same |
| Server body limit | `MaxRequestBodySize`: Kestrel and IIS in-process both default to 30,000,000 bytes (about 28.6 MB) | **Register: 30 MB default (no attribute).** Update: 100 MB (`[RequestSizeLimit]`). | **`[RequestSizeLimit(104857600)]` → 100 MB** | 100 MB (unchanged) |
| IIS request filtering | `web.config` `maxAllowedContentLength` | 100 MB (104857600) | 100 MB (unchanged) | 100 MB (unchanged) |
| Hosting model | `web.config` `hostingModel` | `inprocess`, so IIS in-process `MaxRequestBodySize` applies (the endpoint attribute overrides it) | Same | Same |
| Local development | `launchSettings.json` | Kestrel (`http`/`https`) and IIS Express | Same | Same |

**Result:** without the change, a large register request (more than about 28.6 MB) fails with **413**, even though IIS filtering and `FormOptions` allow 100 MB. With the change, register and update have the same 100 MB limit on every layer. That leaves about 2.5× headroom over the 40 MB worst case.

Not changed:

- There is no per-file size check on the server (`SavePublicImageAsync` is shared by other uploads). This is noted for QA.
- No global `IISServerOptions` or `KestrelServerOptions` change. The per-endpoint attribute is enough and touches nothing else.

#### 3.8.3 How it is verified

1. **Config review** (task 1 and QA): the repo `web.config`, `Program.cs` and the controller attributes against the table above.
2. **Kestrel, locally:** run the API with the `http` profile and send these to RegisterInvestor and UpdateInvestor:
   - a request of about 40 MB, which must succeed (T26);
   - a request of about 35 MB, which fails before the fix and succeeds after it (T27);
   - a request over 100 MB, which must get 413 and leave no files behind (T28).
3. **IIS in-process, locally:** repeat T26 and T28 under the `IIS Express` profile (installed on this machine), with the connection string overridden to the local DB (T29).
4. **Admin web timeout:** a worst-case register from Flutter web (`flutter run -d chrome`) against the local API does not time out (T30).
5. **Production hosting (PM check, not touched by us):**
   - The deployed `web.config` must have the same `maxAllowedContentLength`.
   - The server IIS site must not set a lower `requestFiltering` limit in `applicationHost.config`.
   - Any proxy or firewall in front of the API must allow about 40 MB request bodies.

   We cannot verify these without touching production. They go into the phase report as PM deployment checks.

### 3.9 Local database only (C8)

- All DDL, procedure deployment, SQL tests, test investors and test files use **only** `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE` with Windows authentication.
- Before every `sqlcmd` run, the main session checks `SELECT @@SERVERNAME` = `FaezLaptop\SQLEXPRESSMICTCO`. If it is anything else, it stops.
- The API under test (Kestrel and IIS Express) runs with `ConnectionStrings__DefaultConnection` overridden to the local database. The connection string in `appsettings.json` is never used for testing. The startup log or a test query confirms the local server before the first request.
- No production or remote server is connected to, read from or changed. The deploy script is written for the PM to run later; we never run it against any server except the local one.
- Test files go to the local API `wwwroot` and are removed after testing.
- Sub-agents cannot run `sqlcmd` (MICTCO guard), so the main session runs every SQL step after the PM says yes.

### 3.10 UI

- New widget `AddInvestorKycPhotoPair`: two of the existing `AddInvestorPhotoUploadBox`, labelled "Front" and "Back".
  - Side by side when `twoCol` is true, stacked otherwise (the same breakpoint the KYC card uses today).
  - Used for: investor Aadhaar, investor PAN, and Aadhaar and PAN in each nominee block. With 3 nominees that is 8 pairs = 16 boxes.
- `AddInvestorPhotoUploadBox` keeps its look. It gets two optional parameters, `existingLabel` and the × rule from §3.6. The defaults keep profile photos exactly as they are.
- Labels (proposed): "Upload Aadhaar Front" / "Upload Aadhaar Back" / "Change Aadhaar Front"…, and the same pattern for PAN and the nominee documents. A stored image's subtitle reads "Current front image" / "Current back image".
- State: a small value object `KycDocumentImages` (front and back picked photo, front and back stored URL), one for the investor's Aadhaar and PAN and one for each nominee document. Pick and cancel take an enum `(KycDocument, KycSide)` instead of 16 separate handler methods.

---

## 4. Files and database objects to change

### 4.1 Database (local only)

| Object | Change |
|---|---|
| `dbo.UserRegistration` | + `AadhaarBackPhoto`, `PanCardBackPhoto` |
| `dbo.InvestorNominee` | + `in_aadhaarbackphoto`, `in_pancardbackphoto` |
| `dbo.Api_InvestorManage` | Parameters; Action 1 (investor insert and nominee OPENJSON); Action 2 (select and nominee FOR JSON); Action 3 (investor row and result set 4); Action 16 (investor CASE, `@NomineeInput`, OPENJSON WITH, nominee UPDATE COALESCE, nominee INSERT) |
| `dbo.Api_GetAllInvestors` | Deployed locally (it is missing), with the investor columns and nominee FOR JSON |
| `dbo.Api_GetConfirmedInvestorsData` | No change, unless task 1 finds a caller |

### 4.2 API repo files

| File | Change |
|---|---|
| `Sql/Api_InvestorManage.sql` | As in §4.1 |
| `Sql/Api_GetAllInvestors.sql` | As in §4.1 |
| `Sql/Deploy_KycFrontBack_2026-11-26.sql` (new) | Re-runnable DDL (`IF COL_LENGTH(...) IS NULL ALTER TABLE … ADD`), then both procedures |
| `Sql/Rollback_KycFrontBack_2026-11-26.sql` (new) | Restore the previous procedures, then `DROP COLUMN` if the column exists. It deletes back images, so it needs PM approval if data exists. |
| `Sql/Verify_KycFrontBack.sql` (new) | SQL checks for T9–T15, run inside rolled-back transactions on the local DB |
| `Sql/Api_InvestorManage_Fix*.sql`, `Sql/Deploy_PendingRequestStaffName_2026-11-24.sql` | Header note: "superseded, do not re-run" (R2) |
| `Dtos/Request/Investor/InvestorRegistrationFormRequest.cs` | + 8 `IFormFile?` back fields (investor, Nominee, Nominee2, Nominee3) |
| `Dtos/Request/Investor/InvestorRegistrationRequest.cs` | + `AadhaarBackPhoto`, `PanCardBackPhoto` |
| `Dtos/Request/Investor/InvestorNomineeRegistrationRequest.cs` | + `NomineeAadhaarBackPhoto`, `NomineePanCardBackPhoto` |
| `Dtos/Request/Investor/UpdateInvestorRequest.cs` | + `AadhaarBackPhoto`, `PanCardBackPhoto`, `NomineeAadhaarBackPhoto1..3`, `NomineePanCardBackPhoto1..3` |
| `Dtos/Response/Investor/UpdateInvestorNomineeRequest.cs` | + 2 back fields |
| `Dtos/Response/Investor/InvestorListResponse.cs`, `InvestorDetailsResponse.cs` | + `AadhaarBackPhoto`, `PanCardBackPhoto` |
| `Dtos/Response/Investor/NomineeResponse.cs`, `InvestorNomineeResponse.cs` | + `NomineeAadhaarBackPhoto`, `NomineePanCardBackPhoto` |
| `Controllers/InvestorController.cs` | Map the 8 new register fields (~68-137). Add `[RequestSizeLimit(104857600)]` and `[RequestFormLimits(MultipartBodyLengthLimit = 104857600)]` to `RegisterInvestor`. |
| `Services/InvestorServices/InvestorServices.cs` | Register: save the back files, track them for cleanup, pass them to the SP and nominee JSON. Update: `AddNominee` helper (+2 parameters), old-path SELECTs (~2754, ~2780), `oldNomineePhotos` tuple (+2), tracked saves, SP parameters and JSON keys, delete old back files after success. List and details mapping (~857, ~993, ~1133). |
| `docs/API_ENDPOINTS.md`, `docs/API_RESPONSE_CONTRACTS.md`, `docs/DATABASE_SCHEMA.md`, `docs/BUSINESS_LOGIC.md` | Document the new fields and columns, the "blank keeps the stored value" rule, and the 100 MB register limit |

### 4.3 Flutter files

| File | Change |
|---|---|
| `lib/admin/investors/model/kyc_document_images.dart` (new) | `KycDocumentImages` value object and `KycDocument` / `KycSide` enums |
| `lib/admin/investors/model/investor_model.dart` | + `aadhaarCardBackImage`, `panCardBackImage` (camelCase and PascalCase keys), URL getters, legacy flat nominee back fields |
| `lib/admin/investors/model/investor_nominee_record.dart` | + back paths, URL getters, `isEmpty` |
| `lib/admin/investors/model/investor_nominee_entry.dart` | + back picked photos and stored URLs (through `KycDocumentImages`), `hasAnyData`, `applyFromRecord`, `nomineeRecordsFromInvestor` |
| `lib/admin/investors/model/investor_nominee_submit.dart` | + `aadhaarCardBackImage`, `panCardBackImage`, `isEmpty`, register back keys, update back keys (same slot index as the id) |
| `lib/admin/investors/model/register_investor_model.dart` | + back files, added only when picked |
| `lib/admin/investors/model/update_investor_model.dart` | + back files, added only when picked |
| `lib/admin/investors/screens/add_new_investor/add_new_investor.dart` | Back state, pre-fill, reset, submit. Pick and cancel by `(document, side)`. Cancel keeps the stored URL (§3.6). |
| `lib/admin/investors/screens/add_new_investor/widget/add_investor_additional_information.dart` | Use `AddInvestorKycPhotoPair` in the KYC card and each nominee block |
| `lib/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart` | Pass the new values through. Add `AddInvestorKycPhotoPair`, and the optional `existingLabel` and × rule on `AddInvestorPhotoUploadBox`. |
| `lib/admin/investors/repository/investors_repository.dart` | Longer `sendTimeout` through per-request `Options`, for register and update only |
| **D2 only:** `lib/user/profile/model/investor_details_model.dart`, `investor_nominee_model.dart`, `lib/user/profile/screens/document_screen/widgets/additional_information_card.dart`, `nominee_details_card.dart`, `lib/admin/funding&payments/model/investor_details_models.dart`, `lib/admin/pending_requests/screens/review_request/widgets/review_request_details_section.dart` | Read and show the back images (display only). An existing single image is labelled Front. |
| `test/admin/investors/…` (new) | Unit tests for JSON parsing and multipart keys. Widget tests for the pair and the × rule. |
| `docs/modules/ADMIN_INVESTORS.md`, `docs/modules/USER_PROFILE.md`, `docs/modules/ADMIN_PENDING_REQUESTS.md`, `docs/DATA_MODELS.md`, `docs/API_INTEGRATION.md`, `docs/DECISIONS.md` | Document the change and the decisions. `docs/DECISIONS.md` already has uncommitted edits, so entries are only appended. |

Not changed: other investor features (payments, refunds, MOU/LLP, ratings, staff allocation, reports), profile photo behaviour, the 3-nominee limit and its validation, and `PhotoPickerHelper`.

---

## 5. Implementation tasks (MICTCO order)

All work is on **`feature/high-priority-reports`** in both repos (C9).

- The Flutter working tree already has unrelated uncommitted changes (`docs/DECISIONS.md`, `docs/modules/ADMIN_USER_MANAGEMENT.md`, `user_status_checkbox_card.dart`, `transaction_receipt_pdf.dart`, and two test folders). They are left as they are. This work does not touch or stage them, apart from appending to `docs/DECISIONS.md`.
- Nothing is committed until the PM asks.

Each task follows TDD (tests first). `qa-team-head` reviews after every task, and `database-architect` (Review mode) also reviews the SQL tasks. Fixes go back to the developer who did the task.

| # | Task | Who | Depends on |
|---|---|---|---|
| 0 | Write the spec, finish this plan and the test-case document, record decisions D1–D7 in `docs/DECISIONS.md` and an ADR | Team Head; reviewed by solution-architect, database-architect, qa-team-head | PM final approval |
| 1 | DB design check, read-only. Diff the repo `Api_InvestorManage.sql` against the locally deployed proc (2026-11-24). Confirm column names and types, the Action list, the Action 16 transaction and rollback, and that no other code writes the photo columns (§3.3.3). Confirm `Api_GetConfirmedInvestorsData` has no caller. Review the size-limit configuration (§3.8.3 step 1). | database-architect (Design mode); solution-architect for §3.8 | 0 |
| 2 | SQL: DDL, `Api_InvestorManage` changes, `Api_GetAllInvestors` changes, deploy, rollback and verify scripts, "superseded" headers. Apply to the **local DB only**; the main session runs `sqlcmd -I` after the server-name check (§3.9). | backend-developer; review by database-architect | 1 |
| 3 | API DTOs, controller mapping, register size-limit attributes, service changes (register, update, list, details, cleanup lists) | backend-developer | 2 |
| 4 | Flutter models and request building, with unit tests for all 16 document keys and JSON parsing | frontend-developer | 3 (contract fixed in §3.2) |
| 5 | Flutter UI: `KycDocumentImages`, `AddInvestorKycPhotoPair`, form wiring, × replace-only rule, upload-box label, register/update timeout. Widget tests. | frontend-developer | 4 |
| 6 | Flutter read-only screens (only if D2 is approved) | frontend-developer | 4 |
| 7 | Run the test-case document (§6) on the local DB, with the API on Kestrel and IIS Express pointed at the local DB, plus regression checks | tester | 2–6 |
| 8 | Whole-branch review and security check (including the cleanup paths, public `wwwroot` exposure and size limits) | qa-team-head; database-architect for SQL | 7 |
| 9 | Update docs in both repos, Phase Completion Checklist, phase report (including the production deployment checks from §3.8.3 step 5) | Team Head | 8 |

Tasks 4–6 can start as soon as the contract in §3.2 is approved. They are tested end to end after task 3.

---

## 6. Test cases

All tests use the local DB only (§3.9). The API runs with its connection string overridden to the local DB. "Files" means files under the local API `wwwroot`.

### 6.1 Test data

- **INV-FULL:** registered through the new API with all 16 document images (investor and 3 nominees).
- **INV-LEGACY-1 and INV-LEGACY-2:** registered with the **old request shape** (front fields only, no back fields; exactly what the current app sends). INV-LEGACY-1 has the investor plus 1 nominee; INV-LEGACY-2 has the investor plus 3 nominees. Their rows then look exactly like existing production data (front path set, back NULL).
- **INV-NONE:** no document images.
- The existing 4 local investors (no photos) are used for regression.
- Each image file is distinct (file name and content), so every stored path can be checked against the file that was sent.
- After testing, the tester lists the test investors and files. The Team Head removes them only after the PM says yes.

### 6.2 Image count and consistency (C1, C2)

| ID | Scenario | Expected |
|---|---|---|
| T1 | Register INV-FULL with all 16 document images and 4 profile photos | 16 distinct document paths stored (2 investor columns × 2 + 3 nominee rows × 4 columns). Each path points to the file that was sent for that owner, document and side. 20 files exist. |
| T2 | Call GetInvestors, GetAllInvestors and InvestorDetails for INV-FULL, INV-LEGACY-1 and INV-NONE | All three APIs return the same 4 investor properties and the same 4 properties per nominee (§3.2.1), with the same values. Properties with no image are present with `null`. |
| T3 | Register with 3 nominees and a mix: some sides front only, some back only, some empty | Each side stored or NULL exactly as sent. No error. T2 still holds. |
| T4 | Flutter unit tests: register and update form data with all 16 document images picked | Exactly 16 document file entries with the keys from §3.2. Update nominee files go in the same slot as their `NomineeId`. |

### 6.3 Independence (C3)

| ID | Scenario | Expected |
|---|---|---|
| T5 | Update INV-FULL: replace investor Aadhaar **back** only | Aadhaar back path changed, and the old back file deleted. The other 15 paths and their files unchanged. |
| T6 | Update INV-FULL: replace investor PAN **front** only | PAN front path changed, and the old front file deleted. The other 15 unchanged. |
| T7 | Update INV-FULL: replace **nominee 2** Aadhaar front only | Only nominee 2's Aadhaar front changes. Nominee 2's other 3 images, nominees 1 and 3 (8 images) and the investor (4 images) unchanged. |
| T8 | Update INV-FULL: replace nominee 1 PAN back **and** nominee 3 Aadhaar back in one request | Exactly those 2 paths change and those 2 old files are deleted. The other 14 unchanged. Nominee 2 unchanged. |
| T9 | Update INV-FULL: text fields only, no files | All 16 paths and files unchanged |
| T10 | Update INV-FULL with the slot order changed (nominee 3's id sent in slot 1 with a new back image) | The image goes to nominee 3's row (matched by id, not slot). The other nominees unchanged. |
| T11 | Edit INV-LEGACY-1: add nominee 2 with front and back images | New nominee row has both paths. The existing nominee and the investor unchanged. |
| T12 | SQL (rolled back): Action 16 with a back value for one nominee and NULL for everything else | Only that column changes |
| T13 | SQL (rolled back): Action 16 with a nominee id that belongs to another investor | THROW 50001. No columns of either investor change. |
| T14 | SQL (rolled back): Action 16 with blank strings (`''`, `'  '`) for front and back | Stored values kept |
| T15 | Old-client request (front fields only, no back keys) updating INV-FULL's investor Aadhaar front | Front replaced. **The back is unchanged.** Nominees unchanged. |

### 6.4 × replace-only and cleanup (C4, C5)

| ID | Scenario | Expected |
|---|---|---|
| T16 | Widget test: a box with a stored image and nothing picked | No × shown. Tapping opens the picker. |
| T17 | Edit: pick a new Aadhaar front over a stored one, then press × | Stored front shown again. Back unchanged. Saving sends no Aadhaar front file; the path and file are unchanged. |
| T18 | Register: pick a back image, press × | Box empty. The request has no file for that side. |
| T19 | Edit: press × on a picked nominee 2 PAN back | Only that box goes back to its stored image. The other 15 boxes unchanged. No server call, no server file deleted. |
| T20 | Register with 16 document images where nominee 3's PAN back has a bad extension (`.gif`) | Error shown. **None of the files saved in this request remain.** No investor row is created. |
| T21 | Register with all images and a duplicate username (SP error) | All files from this request deleted. No row created. |
| T22 | Register with a duplicate email or phone | Rejected before any upload. No new files. |
| T23 | Update INV-FULL with new images and a nominee id from another investor (SP error) | New files deleted. **All 16 stored paths and files unchanged.** |
| T24 | Update INV-FULL with new images where one has a bad extension | New files deleted. Stored files unchanged. 400 returned. |
| T25 | Update INV-FULL with a 4th nominee (more than 3) | Rejected before any upload. No new files. Stored files unchanged. |

### 6.5 Size limits (C6)

| ID | Scenario | Expected |
|---|---|---|
| T26 | Kestrel: RegisterInvestor and UpdateInvestor with 20 files (about 40 MB) | Both succeed |
| T27 | Kestrel: RegisterInvestor with about 35 MB, before and after the attribute change | Before: 413. After: success. |
| T28 | Kestrel: RegisterInvestor and UpdateInvestor with more than 100 MB | 413. No files left. No row created or changed. |
| T29 | IIS Express (in-process, local DB): repeat T26 and T28 | Same results as Kestrel |
| T30 | Flutter web (`flutter run -d chrome`) against the local API: worst-case register and update | No send timeout. Success message. |

### 6.6 Regression: existing single-image investors and existing screens (C7)

| ID | Scenario | Expected |
|---|---|---|
| T31 | INV-LEGACY-1 and INV-LEGACY-2 in the admin investor list (GetInvestors and GetAllInvestors with All and Block) | Listed as before, with totals and filters unchanged. Front paths returned, back `null`. |
| T32 | Open INV-LEGACY-2 in edit | Every stored image shows in its **Front** box. Back boxes empty. Other fields pre-filled as before. |
| T33 | Save INV-LEGACY-2 without changes | All front paths and files unchanged. Backs still NULL. |
| T34 | INV-LEGACY-1: add a back image to the investor Aadhaar only | Back stored. Front unchanged. |
| T35 | INV-LEGACY-1: replace the front only | Front replaced and the old front file deleted. Back still NULL. |
| T36 | InvestorDetails for INV-LEGACY-1 (admin and the investor's own login) | Fronts returned, backs `null`. No errors. |
| T37 | Mobile investor app (`isAdmin = false`), document screen, for INV-LEGACY-1 and INV-FULL | Legacy: the image shows as before (labelled Front if D2). Full: front and back shown (D2). No layout errors. |
| T38 | Pending-request review and funding/payment investor details for INV-LEGACY-1 and INV-FULL | Images display as before (and backs if D2). No errors. |
| T39 | A current app build (before this change) against the new API: register, edit (front only), list, details | Everything works as today, with back values kept (T15) |
| T40 | Regression of unrelated features: profile photos (investor and nominee, including today's × behaviour), MOU/LLP upload, add payment, refund, block/unblock, ratings, staff allocation, 3-nominee limit, duplicate email/phone check | Unchanged |
| T41 | `flutter analyze`, `flutter test`, API build | Clean, apart from the 3 tests that already fail at HEAD (`no_sensitive_logging_test` and 2 in `team_overview_data_test`), which are reported separately |
| T42 | Responsive check of the Front/Back pairs on wide (side by side) and narrow (stacked) widths, with 3 nominees | No overflow. Same look as the other upload boxes. |

---

## 7. Risks

| ID | Risk | Mitigation |
|---|---|---|
| R1 | `Api_GetAllInvestors` is not deployed on the local DB, so `GetAllInvestors` cannot be tested locally | Deploy it locally in task 2 |
| R2 | The repo holds full copies of `Api_InvestorManage`. Re-running one after this change silently removes back-image support. | Diff before editing (task 1). Mark the copies superseded. One new deploy script. |
| R3 | `RegisterInvestor` is capped at about 28.6 MB by the default `MaxRequestBodySize`. The worst case grows to about 40 MB. | Add the request-size attributes. Tests T26–T29. |
| R4 | 30 s Dio `sendTimeout` with about 40 MB uploads on slow links | Longer timeout for register and update only. Test T30. |
| R5 | Hand-written mapping in 3 service methods and 2 procedures. A missed line means the back image never appears, with no error. | T2 compares all three APIs |
| R6 | Wrong deploy order breaks register and update ("too many arguments") | Deploy order in §3.5, written into the phase report for the PM |
| R7 | KYC images are public files under `wwwroot` (GUID names, no login check). This change doubles that exposure. | Existing open security item. Recorded in the security check (task 8); not fixed in this scope. |
| R8 | Unrelated uncommitted work on the current branch (C9) | Not touched or staged. `docs/DECISIONS.md` is only appended to. |
| R9 | Some legacy single images are front and back on one scan | Shown as Front. Can be replaced through edit. |
| R10 | Production hosting (deployed `web.config`, IIS site limits, any proxy) may differ from the repo | PM deployment checks in the phase report (§3.8.3 step 5). We do not touch production. |
| R11 | Two admins editing the same investor at the same time | Last save wins per column (existing behaviour). At worst a file is orphaned; no stored path points to a deleted file. |

---

## 8. Migration and rollback

- **Local migration (this work):**
  - Add the 4 nullable columns on the local DB with the re-runnable script.
  - Adding a nullable column with no default only changes metadata (brief schema lock). No backfill.
  - Then deploy `Api_InvestorManage` and `Api_GetAllInvestors` locally.
- **Local rollback:** restore the previous procedures from git HEAD, then drop the columns (local test data only).
- **Production (later, PM only, not part of this work):**
  - Run `Deploy_KycFrontBack_2026-11-26.sql`, then deploy the API, admin web and the mobile app in that order.
  - Do the hosting checks in §3.8.3 step 5.
  - The rollback script deletes back images, so the PM decides on it if data exists.

---

## 9. Out of scope

- Removing a stored front or back image (D1: replace-only).
- Changing the profile photo × behaviour (D7).
- Moving KYC images out of public `wwwroot`, or adding a per-file size check on the server.
- Changing register's 500 status for a bad file extension.
- `Api_GetConfirmedInvestorsData` (no caller).
- Any other investor feature, and any production or remote database or server.

---

## 10. PM decisions

| ID | Question | Status |
|---|---|---|
| D1 | Can a front or back image be removed? | **Decided (C4): replace-only.** × cancels a newly picked image and restores the stored one. No stored file is deleted. |
| D2 | Should the read-only screens (mobile document screen, pending-request review) show back images? | **Open.** Recommended: yes, display only, and label an existing single image as Front. |
| D3 | Are front and back required? | **Open.** Recommended: both optional, as today. No "back needs front" rule. |
| D4 | Include the `RegisterInvestor` request-size fix and the longer upload timeout? | **Decided (C6): yes**, as in §3.8 |
| D5 | Local DB changes: add the 4 columns, deploy both changed procedures, and deploy the missing `Api_GetAllInvestors` | **Decided (C8): local `.\SQLEXPRESSMICTCO` / `MARIBEL_WELLNESS_CENTRE` only**, run after final approval |
| D6 | Branch | **Decided (C9): the current branch `feature/high-priority-reports` in both repos** |
| D7 | Should the profile photo × follow the same replace-only rule? | **Open.** Recommended: no, keep it as it is (outside this scope). |
