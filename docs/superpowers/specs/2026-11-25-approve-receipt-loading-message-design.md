# Spec: "Sending receipt" message while a payment request is approved

Date: 2026-11-25 · Status: **Draft, written from the PM's request** · Plan: `docs/superpowers/plans/2026-11-25-approve-receipt-loading-message-plan.md`

## 1. Goal
When a MarketingManager approves a payment request on the Pending Requests review screen, show the text **"Please wait... Sending email receipt and app receipt."** under the existing loading spinner until the whole operation has finished. UI and loading-state change only. No new API call, no business-logic change.

## 2. What the code does today (verified 2026-11-25)

**Frontend**
- `ReviewRequestScreen._accept` shows a confirm dialog, then calls `PendingRequestsCubit.reviewPaymentRequest(status: 'Approved')`.
- The cubit emits `isReviewSubmitting: true`, awaits one call, `POST /api/Investor/ReviewPaymentRequest`, then emits `isReviewSubmitting: false` with feedback in all three outcomes (success, `DioException`, any other error). The state is therefore always reset.
- `ReviewRequestScreen` already shows a full-screen white overlay with a spinner while `isReviewSubmitting` is true. The overlay is opaque to taps. Approve and Reject buttons are disabled and Back is a no-op. The cubit also returns early if a review is already running.
- No Dio timeout is configured, so the request waits for the server.

**Backend** (`InvestorServices.ReviewPaymentRequestAsync`, `InvestorServices.cs` about lines 1440-1670)
- For **Approved** only, after the stored procedure succeeds and **before the response is returned**, the same request: (1) sends the app notification "Payment Received" (`_notificationService.SendNotificationAsync`), (2) builds the PDF receipt, (3) sends the email with the PDF attached (`_emailService.SendEmailAsync`). Each step is awaited and its failure is swallowed, so a receipt failure never fails the approval.
- For **Rejected**, no receipt, notification or email is sent.
- There is no separate receipt API and no background job. The receipt work finishes before the approval response arrives.

**What "app receipt" means:** the backend sends the investor a "Payment Received" push notification (the "app receipt" part of the message). The in-app receipt screen is built on the investor's device (`lib/user/investments/transaction_receipt_screen.dart`). The PDF receipt goes by email only.

**Consequence:** the existing `isReviewSubmitting` window already covers the approval and the receipt sending. No cubit or API change is needed, and the message is accurate only for Approve.

## 3. Design
- `ReviewRequestScreen` keeps a local `bool _isApproving`. `_accept` keeps `if (!widget.canReview) return;` as its first line, re-checks `isReviewSubmitting` after the confirm dialog (a double tap can open two dialogs), then sets it to true just before `await cubit.reviewPaymentRequest(...)` and resets it in a `finally` block (guarded by `mounted`). `_reject` never sets it.
- The overlay shows the message when `isReviewSubmitting && _isApproving`. For Reject the overlay is unchanged (spinner only).
- The overlay becomes a small private widget (spinner, then the centred text). The text is a constant, wraps on narrow screens and keeps existing colours.
- No change to `PendingRequestsCubit`, state, repository, endpoints or `canReview` rules (SuperAdmin never reaches `_accept`).

## 4. Out of scope
- Terminated Investor approve (block request, no receipt) and Monthly List approve (`ReviewPaymentVerification`).
- A separate receipt progress API or per-step progress (the backend gives one combined response).
- Showing a receipt-failure warning (the backend swallows receipt failures by design).
