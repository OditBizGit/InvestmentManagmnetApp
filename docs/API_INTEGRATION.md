# API Integration

Consolidated list of every backend endpoint the app calls. Client architecture (Dio, interceptors, error handling, base URL) is documented in [API_CLIENT_CORE.md](API_CLIENT_CORE.md); this file is the endpoint catalogue.

## Conventions (verified in source)

- Constants live in `lib/core/constants/api_endpoints.dart` (`ApiEndpoints`); all are relative paths. Base URL is `kBaseUrl` in `lib/core/network/service_locator.dart` (plain `http`, IP host, single environment).
- All 69 constants are referenced by at least one repository (grep of `ApiEndpoints.*`). Duplicates of the same path: `getBanners` = `getBanner` (`/api/Project/GetBanners`); `workProgressDetails` = `workPhaseList` (`/api/Project/WorkProgressDetails`).
- Path ids are string-concatenated onto constants ending with `/` (`investorDetails`, `investorTransactionHistory`, `markAsRead`, `deleteWorkUpdate`, `deleteWorkStatus`) or substituted into `{placeholder}` constants with `replaceFirst` (`getInvestorByStaff`, `getInvestorsMOU`, `getInvestorsLLP`, `getStaffReportByID`).
- The `Login` path is the only one that skips the `Authorization: Bearer` header (interceptor in `service_locator.dart`).
- Envelope: responses are generally `{ status | success, message, data, code }`. Repositories check `status`/`code` leniently and many throw `Exception(message)` or return null on failure (per module docs).
- Paths below are relative to the base URL. "Repo" paths are abbreviated: `A/` = `lib/admin/`, `U/` = `lib/user/`.
- Cubit "n/a" = no cubit; repository is called from a screen, another cubit or a service.

## Authentication

| Constant | Method | Path | Repository.method (file) | Cubit | Screen | Models (req -> resp) |
|---|---|---|---|---|---|---|
| `login` | POST | `/api/User/Login` | `AuthRepository.login` (`lib/auth/repository/login_repository.dart`) | `LoginCubit` | `LoginScreen`, `AdminWebLoginScreen` | `LoginRequestModel` -> `LoginResponseModel` (`LoginDataModel`) |

## Dashboard and reports

| Constant | Method | Path | Repository.method (file) | Cubit | Screen | Models |
|---|---|---|---|---|---|---|
| `getDashboard` | GET (query `FromDate`,`ToDate`) | `/api/Dashboard/GetFundingDashboard` | `DashboardRepository.getDashboard` (`A/dashboard/repository/dashboard_repository.dart`) | `DashboardCubit` | `AdminDashboardScreen` | `DashboardModel` |
| `topInvestors` | GET | `/api/Investor/GetTopInvestors` | `DashboardRepository.getTopInvestors`; `InvestorRatingRepository.getTopInvestors`; `HomeRepository.getTopInvestors` | `DashboardCubit`; `InvestorRatingCubit`; `HomeCubit` | Dashboard; Investor Rating; User Home | `TopInvestorsModel` (dashboard); `TopInvestorsResponse` (settings); `TopInvestorsResponseModel`/`TopInvestorModel` (user) |
| `transactionHistory` | GET | `/api/Investor/AllInvestorTransactionHistory` | `DashboardRepository.getPaymentHistory`; `InvestorPaymentRepository.getAllInvestorTransactionHistory` | `DashboardCubit`; `ReportCubit` | Dashboard activity; Reports recent transactions | `TransactionHistoryModel`; `InvestorTransactionHistoryResponseModel` (admin) |
| `fundingPaymentOverview` | POST JSON `{fromDate,toDate}` | `/api/Investor/FundingPaymentOverview` | `ReportRepository.getFundingPaymentOverview` (`A/reports/repository/report_repository.dart`) | `ReportCubit` | `AdminReportsScreen` | `FundingPaymentOverviewModel` |
| `investorTypeCount` | GET | `/api/Investor/InvestorTypeCount` | `ReportRepository.getInvestorTypeCount` | `ReportCubit` | `AdminReportsScreen` | `InvestorTypeCountModel` |
| `getStaffReport` | GET (`Period`,`FromDate`,`ToDate`,`Search`) | `/api/Staff/GetStaffReport` | `StaffReportRepository.getStaffReport` (`A/reports/staff_report/repository/`) | `StaffReportCubit` | `StaffReportScreen` | `StaffReportResponseModel`/`StaffReportModel` |
| `getStaffReportByID` | GET (same query) | `/api/Staff/GetStaffReportDetails/{staffId}` | `StaffReportRepository.getStaffReportDetails` | `StaffReportCubit` | `StaffDetailsScreen` | `StaffReportDetailsResponseModel` |

## Investors, funding and payments

| Constant | Method | Path | Repository.method (file) | Cubit | Screen | Models |
|---|---|---|---|---|---|---|
| `investorsList` | GET | `/api/Investor/GetInvestors` | `InvestorsRepository.getInvestors`; `InvestorPaymentRepository.getFundingInvestors`; `ManageUsersRepository.getInvestors` | `InvestorsCubit`; `FundingPaymentsCubit`; `ManageUsersCubit` | Investors; Funding & Payments; Manage Users | `InvestorResponseModel`; `FundingInvestorsResponseModel`; `ManageUsersResponse` |
| `registerInvestor` | POST multipart | `/api/Investor/RegisterInvestor` | `InvestorsRepository.registerInvestor` (`A/investors/repository/investors_repository.dart`) | `InvestorsCubit` | `add_new_investor` | `RegisterInvestorRequestModel.toFormData` -> `RegisterInvestorResponseModel` |
| `updateInvestor` | POST multipart | `/api/Investor/UpdateInvestor` | `InvestorsRepository.updateInvestor` | `InvestorsCubit` | `add_new_investor` (edit) | `UpdateInvestorRequestModel` -> `UpdateInvestorResponseModel` |
| `investorTypes` | GET | `/api/Investor/GetInvestorTypes` | `InvestorsRepository.getInvestorTypes` | `InvestorsCubit` | `add_new_investor` | `InvestorTypeResponseModel` |
| `staffList` | GET | `/api/Staff/GetStaffList` | `InvestorsRepository.getStaffList`; `StaffRepository.getStaff` | `InvestorsCubit`; `StaffAllocationCubit` | `add_new_investor`; Staff & Allocation | `StaffListResponseModel`; `GetStaffResponseModel` |
| `addInvestorPayment` | POST JSON | `/api/Investor/AddInvestorPayment` | `InvestorPaymentRepository.addInvestorPayment` (`A/funding&payments/repository/`) | `FundingPaymentsCubit` | `add_new_fund` | `AddInvestorPaymentRequestModel` -> `AddInvestorPaymentResponseModel` |
| `investorDetails` | GET (id appended) | `/api/Investor/InvestorDetails/{userId}` | `InvestorPaymentRepository.getInvestorDetails` (admin); `ProfileRepository.getInvestorDetails` (user; reused by `HomeRepository.getHomeProfile`); also observed by `AccountStatusMonitor.onResponse` | `FundingPaymentsCubit`; `PendingRequestsCubit`; `ProfileCubit`; `HomeCubit` | Transaction detail; Review Request; User Profile / Home | admin `InvestorDetailsResponseModel`; user `InvestorDetailsResponseModel` -> `InvestorDetailsModel` |
| `updateDueDates` | POST JSON | `/api/Investor/UpdateInvestorInstallmentDueDate` | `InvestorPaymentRepository.updateDueDates` | `FundingPaymentsCubit` | `transaction_detail_screen` | `UpdateDueDatesRequestModel` -> `UpdateDueDatesResponseModel` |
| `investorTransactionHistory` | GET (id appended) | `/api/Investor/InvestorTransactionHistory/{userId}` | `ManageUsersRepository.getInvestorTransactionHistory`; `InvestmentsRepository.getInvestorTransactionHistory` | `ManageUsersCubit`; `InvestmentsCubit` | Manage Users detail (receipts); User Investments | `InvestorTransactionHistoryResponseModel` (user model reused by admin) |

## Pending requests, monthly payments, user management

| Constant | Method | Path | Repository.method (file) | Cubit | Screen | Models |
|---|---|---|---|---|---|---|
| `getPaymentRequests` | GET (`status`) | `/api/Investor/GetPaymentRequests` | `PaymentRequestRepository.getPaymentRequests` (`A/pending_requests/repository/`) | `PendingRequestsCubit` | `PendingRequestsScreen` | `PaymentRequestResponseModel` -> `PendingRequestModel` |
| `acceptOrRejectPaymentRequest` | POST JSON `{requestId,status,remarks}` | `/api/Investor/ReviewPaymentRequest` | `PaymentRequestRepository.acceptOrRejectPaymentRequest` | `PendingRequestsCubit` | `ReviewRequestScreen` | `AcceptOrRejectPaymentRequestModel` -> `...ResponseModel` |
| `monthlyPaymentList` | GET (`FromDate`,`ToDate`) | `/api/Investor/PaymentVerificationList` | `MonthlyPaymentListRepository.getMonthlyPaymentList` (`A/monthly_payment_list/repository/`) | `PaymentListCubit` | `MonthlyPaymentsListScreen` | `MonthlyPaymentListResponseModel` |
| `paymentVerificationHistory` | GET (`FromDate`,`ToDate`) | `/api/Investor/PaymentVerificationHistory` | `MonthlyPaymentListRepository.getPaymentVerificationHistory` | `PaymentListCubit` | `PaymentVerificationHistoryScreen` | `PaymentVerificationHistoryResponseModel` |
| `acceptOrRejectPaymentStatus` | POST JSON `{transactionId,status,remarks}` | `/api/Investor/ReviewPaymentVerification` | `MonthlyPaymentListRepository.reviewPaymentVerification` | `PaymentListCubit` | `MonthlyPaymentsListScreen` | `ReviewPaymentVerificationRequestModel` -> `...ResponseModel` |
| `getBlockRequests` | GET (`status`) | `/api/Investor/GetBlockRequests` | `ManageUsersRepository.getBlockRequests` (`A/user_management/screens/manage_users/repository/`) | `ManageUsersCubit` | `TerminatedInvestorsSection` (Pending Requests) | `InvestorBlockRequestsResponse` |
| `reviewBlockRequest` | POST JSON `{requestId,status,remarks}` | `/api/Investor/ReviewBlockRequest` | `ManageUsersRepository.reviewBlockRequest` | `ManageUsersCubit` | `TerminatedInvestorsSection` | `ReviewBlockRequestResponse` |
| `blockUser` | POST JSON `{userId,isActive,remarks?}` | `/api/Investor/UpdateInvestorStatus` | `ManageUsersRepository.blockUser` | `ManageUsersCubit` | `ManageUsersScreen` | `BlockUserRequestModel` -> `BlockUserResponseModel` |
| `refundInvestor` | POST JSON | `/api/Investor/RefundInvestor` | `ManageUsersRepository.refundInvestor` | `ManageUsersCubit` | `UserStatusUpdateScreen` (refund card) | `RefundInvestorRequestModel` -> `...ResponseModel` |
| `saveMOU` | POST multipart | `/api/Investor/SaveInvestorMOU` | `ManageUsersRepository.saveInvestorMOU` | `ManageUsersCubit` | `UserStatusUpdateScreen` | `SaveInvestorMOURequestModel` -> `SaveInvestorMOUResponseModel` |
| `getInvestorsMOU` | GET | `/api/Investor/GetInvestorMOU/{investorId}` | `ManageUsersRepository.getInvestorMOU`; `ProfileRepository.getInvestorMou` | `ManageUsersCubit`; `ProfileCubit` | `UserStatusUpdateScreen`; user Documents | `SaveInvestorMOUResponseModel`; `InvestorMouResponseModel` |
| `saveLLP` | POST multipart | `/api/Investor/SaveInvestorLLP` | `ManageUsersRepository.saveInvestorLLP` | `ManageUsersCubit` | `UserStatusUpdateScreen` | as MOU |
| `getInvestorsLLP` | GET | `/api/Investor/GetInvestorLLP/{investorId}` | `ManageUsersRepository.getInvestorLLP`; `ProfileRepository.getInvestorLlp` | `ManageUsersCubit`; `ProfileCubit` | `UserStatusUpdateScreen`; user Documents | `SaveInvestorMOUResponseModel`; `InvestorLlpResponseModel` |
| `getPdfExcel` | POST JSON `{fromDate,toDate,section}` | `/api/Investor/InvestorPaymentDetails` | `ManageUsersRepository.getPdfExcel` | `ManageUsersCubit` | `ManageUsersScreen` (export) | `PdfExcelResponseModel` |
| `paymentStatusReport` | GET (`status`, `search?`) | `/api/Investor/PaymentStatusReport` | `PaymentStatusReportRepository.getPaymentStatusReport` (`A/user_management/screens/due_payments/repository/`) | `DuePaymentsCubit` | `DuePaymentsScreen` | `PaymentStatusReportResponseModel` |

## Settings (projects, staff, admins, complaints, ratings)

| Constant | Method | Path | Repository.method (file under `A/settings/screens/...`) | Cubit | Screen | Models |
|---|---|---|---|---|---|---|
| `createProject` | POST multipart | `/api/Project/CreateProject` | `ProjectRepository.createProject` / `updateProject` (same endpoint; `ProjectId` 0 = create) (`create_project/repository/`) | `CreateProjectCubit` | `CreateProjectScreen` | `projcet_model.dart` models (file name is misspelled in source) |
| `getProject` | GET | `/api/Project/GetProjects` | `ProjectRepository.getProjects` | `CreateProjectCubit`; `FundingPaymentsCubit` (limit check); `InvestorsScreen` (direct repository use) | `CreateProjectScreen`; Add Fund / Add Investor | `ProjectListResponseModel` |
| `createStaff` | POST JSON | `/api/Staff/CreateStaff` | `StaffRepository.createStaff` (`staff_allocation/repository/`) | `StaffAllocationCubit` | `StaffAndAllocationScreen` | `CreateStaffRequestModel` -> `CreateStaffResponseModel` |
| `getInvestorByStaff` | GET | `/api/Staff/GetInvestorsByStaff/{staffId}` | `StaffRepository.getInvestorByStaff` | `StaffAllocationCubit` | `StaffInvestorAllocationsView` | `GetInvestorsByStaffResponseModel` |
| `createAdmin` | POST JSON | `/api/User/CreateAdmin` | `CreateAdminRepository.createAdmin` (`create_admin/repository/`) | `CreateAdminCubit` | `CreateAdminScreen` | `CreateAdminModel` -> `CreateAdminResult` |
| `getAdmins` | GET | `/api/User/GetAdmins` | `CreateAdminRepository.getAdmins` | `CreateAdminCubit` | `CreateAdminScreen` (list) | `AdminsResponseModel` |
| `userComplaints` | GET (`fromDate`,`toDate`) | `/api/Investor/GetComplaints` | `UserComplaintsRepository.getUserComplaints` (`user_complaints/repository/user_complaints_respository.dart`, misspelled file name) | `UserComplaintsCubit` | `UserComplaintsScreen` | `UserComplaintModel` |
| `viewComplaint` | POST `{complaintId}` | `/api/Investor/ViewComplaint` | `UserComplaintsRepository.viewComplaint` | `UserComplaintsCubit` | `UserComplaintsScreen` | `ViewComplaintModel` |
| `solveComplaint` | POST `{complaintId}` | `/api/Investor/SolveComplaint` | `UserComplaintsRepository.solveComplaint` | `UserComplaintsCubit` | `UserComplaintsScreen` | `SolveComplaintModel` |
| `investorRatingDetails` | GET | `/api/Investor/InvestorRatingDetails` | `InvestorRatingRepository.getInvestorRatingDetails` (`investor_rating/repository/`) | `InvestorRatingCubit` | `InvestorRatingScreen` | `InvestorRatingDetailsResponse` |
| `saveInvestorRating` | POST `{investorId,rating}` | `/api/Investor/SaveInvestorStarRating` | `InvestorRatingRepository.updateInvestorRating` | `InvestorRatingCubit` | `InvestorRatingScreen` | `InvestorRatingUpdateResponseModel` |
| `addTopInvestor` | POST `{investorIds:[int]}` | `/api/Investor/AddTopInvestor` | `InvestorRatingRepository.addTopInvestor` | `InvestorRatingCubit` | `InvestorRatingScreen` | `AddTopInvestorResponseModel` |
| `removeTopInvestor` | POST `{investorIds:[int]}` | `/api/Investor/RemoveTopInvestor` | `InvestorRatingRepository.removeTopInvestor` | `InvestorRatingCubit` | `InvestorRatingScreen` | `RemoveTopInvestorResponseModel` |
| `topInvestorButton` | POST `{isEnabled}` | `/api/Settings/UpdateTopInvestorsInvestorVisibility` | `InvestorRatingRepository.updateTopInvestorButton` | `InvestorRatingCubit` | `InvestorRatingScreen` | `TopInvestorButtonResponseModel` |

## Work progress, banners, status, updates

| Constant | Method | Path | Repository.method (file under `A/work_progress/screens/add_update/...`) | Cubit | Screen | Models |
|---|---|---|---|---|---|---|
| `addStage` | POST JSON `{stageName}` | `/api/Project/AddProjectStage` | `AddPhaseRepository.addPhase` (`update_phase/repository/update_phase_repository.dart`) | `UpdatePhaseCubit` | `update_project_phase_form` | `AddPhaseModel` |
| `stageList` | GET | `/api/Project/ProjectStageList` | `AddPhaseRepository.getStageList` | `UpdatePhaseCubit` | `update_project_phase_form` | `AddPhaseModel` |
| `addOrUpdatePhase` | POST JSON | `/api/Project/AddOrUpdateProjectProgress` | `AddPhaseRepository.addOrUpdatePhase` | `UpdatePhaseCubit` | `update_project_phase_form` | `AddOrUpdatePhaseRequestModel` -> `AddOrUpdatePhaseResponseModel` |
| `workPhaseList` (= `workProgressDetails`) | GET | `/api/Project/WorkProgressDetails` | `AddPhaseRepository.workPhaseList`; user `HomeRepository.getWorkProgressDetails`; `InvestmentsRepository.getWorkProgressStages` | `WorkProgressCubit`, `UpdatePhaseCubit`, `DashboardCubit`, `ReportCubit`; `HomeCubit`; `InvestmentsCubit` | Work Progress, view phases, Dashboard, Reports; User Home; User Investments | `WorkPhaseListModel`; `WorkProgressDetailsResponseModel`/`WorkProgressItemModel`; `ProjectStageModel` |
| `workProgressGraph` | GET (`stageId`) | `/api/Project/WorkProgressGraph` | `InvestmentsRepository.getWorkProgressGraph` | `InvestmentsCubit` | `WorkProgressGraphCard` | `WorkProgressGraphResponseModel`/`WorkProgressGraphPointModel` |
| `workUpdate` | POST multipart (`Title`,`Description`,`File`) | `/api/Project/AddWorkUpdate` | `WorkUpdateRepository.addWorkUpdate` (`update_construction_photos_videos/repository/`) | `UpdateConstructionCubit` | `update_construction_media_form` | `AddWorkUpdateModel` |
| `getWorkUpdates` | GET | `/api/Project/GetWorkUpdates` | `WorkUpdateRepository.getWorkUpdates`; `DashboardRepository.recentWorkUpdates`; user `UpdatesRepository.getWorkUpdates` | `UpdateConstructionCubit`; `DashboardCubit`; `UpdatesCubit` | view construction media; Dashboard; User Updates | `GetWorkUpdatesModel`; `WorkUpdateModel` (admin and user variants) |
| `deleteWorkUpdate` | DELETE (id appended) | `/api/Project/DeleteWorkUpdate/{id}` | `WorkUpdateRepository.deleteWorkUpdate` | `UpdateConstructionCubit` | `view_delete_construction_media` | `DeleteWorkUpdateModel` |
| `addWorkStatus` | POST multipart | `/api/Project/AddWorkStatus` | `AddWorkStatusRepository.addWorkStatus` (`update_status_stroies/repository/`) | `UpdateStatusCubit` | `update_status_stories_form` | `AddWorkStatusResponseModel` |
| `getWorkStatus` | GET | `/api/Project/GetWorkStatus` | `AddWorkStatusRepository.getWorkStatus`; user `StatusRepository.getWorkStatus` | `UpdateStatusCubit`; `StatusCubit` | `view_delete_status_stroies`; User Status | `GetWorkStatusResponseModel`; `WorkStatusResponseModel`/`WorkStatusModel` |
| `deleteWorkStatus` | DELETE (id appended) | `/api/Project/DeleteWorkStatus/{id}` | `AddWorkStatusRepository.deleteWorkStatus` | `UpdateStatusCubit` | `view_delete_status_stroies` | `DeleteWorkStatusModel` |
| `addBanner` | POST multipart (`Image`) | `/api/Project/AddBanner` | `AddBannerRepository.addBanner` (`add _banner/repository/`; the folder name contains a space) | `AddBannerCubit` | `add_banner_form` | `AddBannerModel` |
| `getBanner` / `getBanners` | GET | `/api/Project/GetBanners` | `AddBannerRepository.getBanners`; user `HomeRepository.getBanners` | `AddBannerCubit`; `HomeCubit` | `view_delete_banners`; User Home | `BannerModel`; `BannersResponseModel`/`BannerItemModel` |
| `deleteBanner` | DELETE JSON body `{bannerId}` | `/api/Project/DeleteBanner` | `AddBannerRepository.deleteBanner` | `AddBannerCubit` | `view_delete_banners` | `DeleteBannerModel` |

## User: notifications and complaints

| Constant | Method | Path | Repository.method (file) | Cubit | Screen | Models |
|---|---|---|---|---|---|---|
| `registerDevice` | POST `{deviceToken, platform}` | `/api/Notification/RegisterDevice` | `NotificationsRepository.registerDevice` (`U/home/repository/notifications_repository.dart`) | none; called from `NotificationService.registerDeviceToken()` after login | none | `RegisterDeviceRequestModel` -> `RegisterDeviceResponseModel` |
| `getMyNotifications` | GET | `/api/Notification/GetMyNotifications` | `NotificationsRepository.getMyNotifications` | `NotificationsCubit` | `NotificationScreen` | `NotificationsResponseModel` -> `AppNotificationModel` |
| `getUnreadCount` | GET | `/api/Notification/GetUnreadCount` | `NotificationsRepository.getUnreadCount` | `NotificationsCubit` | Home bell badge | `UnreadCountResponseModel` |
| `markAsRead` | POST (id appended) | `/api/Notification/MarkAsRead/{notificationId}` | `NotificationsRepository.markAsRead` | `NotificationsCubit` | `NotificationScreen` | `MarkAsReadResponseModel` |
| `markAllAsRead` | POST | `/api/Notification/MarkAllAsRead` | `NotificationsRepository.markAllAsRead` | `NotificationsCubit` | `NotificationScreen` | `MarkAsReadResponseModel` |
| `registerComplaint` | POST `{complaint}` | `/api/Investor/RegisterComplaint` | `ProfileRepository.registerComplaint` (`U/profile/repository/profile_repository.dart`) | `ProfileCubit` | `RegisterComplaintScreen` | `RegisterComplaintResponseModel` |
| `getMyComplaints` | GET | `/api/Investor/GetMyComplaints` | `ProfileRepository.getMyComplaints` | `ProfileCubit` | `RegisteredComplaintsSection` | `MyComplaintsResponseModel` -> `MyComplaintModel` |

## Cross-cutting observations

- Admin endpoints and investor endpoints share one `ApiEndpoints` class and the same Dio; nothing client-side separates admin-only from investor-only calls other than which UI reaches them (backend authorisation: Unclear - needs human clarification).
- `AddInvestorPayment` (admin direct) vs `GetPaymentRequests`/`ReviewPaymentRequest` (staff-submitted) vs `PaymentVerificationList`/`ReviewPaymentVerification` (financial verification): the lifecycle linking the three is Unclear - needs human clarification.
- `InvestorDetails` is reused by the admin Funding/Pending Request screens and by the investor app, and its response is also read by `AccountStatusMonitor`.
- Request body casing is camelCase for JSON bodies; multipart field names are mixed (`Title`, `Description`, `File`, `Image`, `Document` are PascalCase; `investorId`, `status` camelCase). See [DATA_MODELS.md](DATA_MODELS.md).
- Screen and cubit columns for rows not reviewed line-by-line were derived from the module docs and file layout; where a screen name is a widget file rather than a class it is written in snake_case.
