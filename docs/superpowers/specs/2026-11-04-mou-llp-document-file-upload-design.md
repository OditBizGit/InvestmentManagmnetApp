# MOU / LLP Document File Upload

**Date:** 2026-11-04  
**Status:** Implemented (multipart API)

## Request

`SaveInvestorMOU` / `SaveInvestorLLP` send `multipart/form-data` via `SaveInvestorMOURequestModel.toFormData()`:

- `investorId`
- `status` (`Pending` / `Issued` / `Completed`)
- optional `Document` file (`MultipartFile`)

## Response

`SaveInvestorMOUDataModel` includes `documentPath`, timestamps, and status. Cubit stores path + updated-at per investor for MOU and LLP.

## UI

- `+` uploads one file (multipart save with current status)
- Second `+` while a file exists → validation error toast
- Cross clears local/cubit document so another upload is allowed
- Eye opens local file or remote `documentPath` (`resolveMediaUrl` + `url_launcher`)
