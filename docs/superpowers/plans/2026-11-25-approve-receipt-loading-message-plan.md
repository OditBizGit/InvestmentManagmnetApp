# Plan: "Sending receipt" message while approving a payment request

Spec: `docs/superpowers/specs/2026-11-25-approve-receipt-loading-message-design.md` · Status: **Implemented 2026-11-25, QA Ready** · Nothing is committed (standing PM instruction for this branch).

## 1. Scope
One file of production code: `lib/admin/pending_requests/screens/review_request/review_request_screen.dart` (plus a test). No cubit, state, repository, API or backend change. No new package.

## 2. Tasks
1. **Failing tests first** (`frontend-developer`, TDD) in a new `test/admin/pending_requests/review_request_receipt_message_test.dart`, using the fake repositories pattern from `pending_requests_readonly_test.dart`.
2. **Implement** in `review_request_screen.dart`, on top of the existing uncommitted SuperAdmin `canReview` changes (keep `if (!widget.canReview) return;` as the first line of `_accept` and `_reject`; re-check `isReviewSubmitting` after the confirm dialog before setting the flag): `_isApproving` flag set before and reset in `finally` (guard `mounted`), private overlay widget with spinner and the message, message only when `isReviewSubmitting && _isApproving`.
3. **QA review** (`qa-team-head`), **tester** (targeted tests + full-suite comparison with the 3 known unrelated failures + `flutter analyze` baseline), docs update, report.

## 3. Test cases
| ID | Case | Expected |
|---|---|---|
| R1 | MarketingManager approves; fake repository holds the API call open | Overlay shows spinner and the exact text (and no frame shows the spinner without the text) "Please wait... Sending email receipt and app receipt." |
| R2 | The held call completes successfully | The message is gone; the screen goes back (existing success flow) |
| R3 | The call fails (DioException) | The message is gone, the error toast text is shown, Approve and Reject are enabled again |
| R4 | The call throws a non-Dio error | Same as R3, the loading state is reset |
| R5 | Reject while the call is held | Spinner overlay shown, the receipt message is NOT shown |
| R6 | Second tap on Approve or Reject while the call is held | Repository called exactly once (buttons disabled, overlay blocks taps) |
| R7 | Approve cancelled in the confirm dialog | No overlay, no message, no repository call |
| R8 | Narrow width (360 px) while approving | The message wraps with no overflow exception |
| R10 | Approve fails, then Reject is used | The receipt message does not show for Reject (proves the flag was reset) |
| R11 | Approve succeeds and the screen goes back | `tester.takeException()` is null (no setState after dispose) |
| R9 | `canReview: false` (SuperAdmin) | No Approve or Reject buttons, so the message can never appear |

## 4. Acceptance criteria
- The text is exactly "Please wait... Sending email receipt and app receipt." and only for Approve.
- The loading state is reset in every outcome; no duplicate review call; Reject behaviour unchanged.
- `flutter analyze` adds no issue; the existing 47 pending/monthly/navigation tests still pass.
- No change outside the review screen and its new test (plus docs).

## 5. Risks
- The message shows for the whole API call, including the approval itself. That is accurate, because the backend returns only after the receipts are sent.
- If the investor has no email, the backend skips the email; the message is still shown (it describes the attempt). No UI change proposed.
