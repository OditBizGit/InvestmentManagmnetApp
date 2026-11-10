# UI Components

Paths relative to `lib/`. Source of truth is code.

## Shared (core)
| Component | File | Notes / where used |
|---|---|---|
| `AdminMainScreenLayout`, `AdminRefetchProgressBar`, `AdminInitialLoadingBody` | `core/utils/admin_main_screen_layout.dart` | Shell for admin tabs (dashboard, investors, funding, ...) |
| `AdminTopBar` | `core/utils/admin_top_bar.dart` | Username display; compact under 560 px |
| `AdminFooter` | `core/utils/admin_footer.dart` | Bottom of `AdminMainScreen` |
| `AppSnackBar.show` / `.showProgress` | `core/utils/app_snack_bar.dart` | Floating transparent snackbar; progress variant with `AppSnackBarProgressController` (downloads, cancel) |
| `AppToast.success/error/info` | `core/utils/app_toast.dart` | toastification, top-right, 3 s, flat-colored, radius 12; ~200 call sites with AppSnackBar, mostly in BlocListeners |
| `showLogoutConfirmDialog`, user variant | `core/utils/logout_confirm_dialog.dart`, `user_logout_confirm_dialog.dart` | `Dialog`, radius 16, maxWidth 300 |
| `GoToTopButton`, `GoToTopOverlay` | `core/utils/go_to_top_button.dart` | User scroll screens |
| `SuccessScreen` | `core/utils/success_screen.dart` | Lottie `success.json` |
| `showCommitmentCompletedOverlay` | `core/utils/commitment_completed_overlay.dart` | `user/home/home_screen.dart` |
| `AccountBlockedOverlay` | `core/account/account_blocked_overlay.dart` | Injected in `MaterialApp.builder` (user app only) |
| Helpers | `core/utils/` | `CurrencyFormatter` (rupee, Indian grouping, amount in words), `ApiErrorMessage.from`, `media_url.dart`, `PhotoPickerHelper` (jpg/jpeg/png, 2 MB), `string_extensions.dart` |

## Navigation
- Admin: `admin/navigation/admin_side_drawer.dart` (`AdminSideDrawer`, `AdminDrawerItem`, `_ExpandableDrawerGroup`, `_DrawerNavTile`, `_AppVersionLabel`), `admin_main_screen.dart`, `admin_nav_permissions.dart`.
- User: `user/navigation/user_bottom_nav.dart` (`UserBottomNav`), `user_main_screen.dart`, `tab_reselect_notifier.dart`.

## Loaders, shimmer, empty/error
- Shimmer: `admin/dashboard/widgets/dashboard_shimmer.dart` (`DashboardShimmer.wrap/box/line`, base #E0E0E0, highlight #F5F5F5, 1400 ms). User: private `_ShimmerBox` in `user/investments/investments_screen.dart`; shimmer also referenced in `user/home` (home_screen, notification_screen, several widgets).
- Linear refetch bar: `AdminRefetchProgressBar`; first load: `AdminInitialLoadingBody`.
- `RefreshIndicator(color: AppColors.accent)` in the dashboard.
- Empty/error states: no shared widget; each table/list section renders its own message; errors surface via `AppToast.error` in cubit listeners. Unclear - needs human clarification on a standard empty-state.
- Image/video failure SVGs: `ImageConstants.imageError` / `videoError`.

## Dialogs
All use `showDialog`; no `showModalBottomSheet` found in `lib/`.
- `admin/user_management/widgets/user_management_confirm_dialog.dart`
- `admin/user_management/screens/due_payments/widgets/payment_details_dialog.dart`, `send_reminder_preview_dialog.dart`
- `admin/user_management/screens/manage_users/screens/widgets/terminate_user_remarks_dialog.dart`
- `admin/funding&payments/widgets/funding_limit_warning_dialog.dart`
- `admin/monthly_payment_list/screen/widgets/reject_payment_verification_dialog.dart`
- `admin/pending_requests/screens/review_request/widgets/reject_payment_request_dialog.dart`, `kyc_image_preview_dialog.dart`

## Admin per-module widgets (widgets/ folders)
- dashboard: `dashboard_overview`, `dashboard_activity_section`, `dashboard_details_section`, `dashboard_shimmer`
- funding&payments: `funding_overview_section`, `funding_transactions_table`, `add_fund_form_card`, `add_fund_side_panel`, `investor_profile_overview`, `investor_profile_details_section`, `transaction_payment_history_section`, `funding_limit_warning_dialog`
- investors: `investors_overview_section`, `investors_table_section`, `add_investor_form_cards`, `add_investor_additional_information`, `add_investor_side_panel` (`AddInvestorSidePanel`, `AddInvestorActionButtons`)
- monthly_payment_list: `montly_payment_overview`, `montly_payment_table`, `reject_payment_verification_dialog`
- pending_requests: `pending_requests_overview_section`, `pending_requests_list_section`, `pending_request_card`, `terminated_investors_section`, `review_request_header`, `review_request_details_section`, plus dialogs above
- reports: `reports_overview_cards`, `reports_details_section`, `reports_recent_transactions_table`; staff: `staff_report_table_section`, `staff_details_investors_section`
- settings: `settings_option_cards`, `create_admin_form_card`, `admins_list_section`, `create_project_form_card`, `projects_list_section`, `investor_rating_table_section`, `top_rated_investors_section`, `interactive_star_rating`, `add_staff_form_card`, `staff_list_section`, `staff_allocation_header`, `staff_investor_allocations_view`, `complaint_card`, `complaints_date_filter`
- user_management: `manage_users_overview_section`, `manage_users_table_section`, `due_payments_overview_section`, `due_payments_table_section`, `user_management_list_toolbar`, `user_management_stat_cards`, `user_management_table_widgets`, `user_benefits_summary_card`, `user_receipts_card`, `user_refund_card`, `user_status_checkbox_card`, `user_status_update_header`
- work_progress: `work_progress_overview_section`, `work_progress_timeline_table`, `work_progress_big_cards`, `add_update_option_cards`, `add_banner_form`, `banner_common_widgets`, `view_delete_banners`

Naming pattern: `*_overview_section` = stat cards; `*_table_section` / `*_table` = data tables (whether built on `DataTable` or custom rows: Unclear - needs human clarification); `*_form_card` = form cards; `*_side_panel` = fixed right action column.

## User (investor) widgets
- home: `investment_summary_card`, `latest_project_updates`, `service_gallery_carousel`, `top_investors_carousel`, `work_progress_card`
- investments: `recent_transactions_section`, `work_progress_graph_card`; screen `transaction_receipt_screen.dart`
- status: `status_card_actions`, `status_image_card`, `status_video_card`
- updates: `work_update_fullscreen_image`, `work_update_inline_video`
- profile sub-screens (`personal_info_screen`, `document_screen`, `investment_details_screen`, `register_complaint_screen`) each have a `widgets/` folder.

## Forms
Form cards are per-module; inputs are styled inline (no shared text-field widget found). Photo picking via `PhotoPickerHelper`; media forms in `admin/work_progress/screens/add_update/`.
