class ApiEndpoints {

  static const String login = "/api/User/Login";
  static const String investorsList = "/api/Investor/GetInvestors";
  static const String registerInvestor = "/api/Investor/RegisterInvestor";
  static const String investorTypes = "/api/Investor/GetInvestorTypes";
  static const String addInvestorPayment = "/api/Investor/AddInvestorPayment";
  static const String investorDetails = "/api/Investor/InvestorDetails/";
  static const String transactionHistory = "/api/Investor/AllInvestorTransactionHistory";
  static const String workProgressDetails = "/api/Project/WorkProgressDetails";
  static const String getBanners = "/api/Project/GetBanners";
  static const String registerComplaint = "/api/Investor/RegisterComplaint";
  static const String getMyComplaints = "/api/Investor/GetMyComplaints";
  static const String workProgressGraph = "/api/Project/WorkProgressGraph";
  static const String getWorkUpdates = "/api/Project/GetWorkUpdates";
  static const String registerDevice = "/api/Notification/RegisterDevice";
  static const String getMyNotifications = "/api/Notification/GetMyNotifications";
  static const String getUnreadCount = "/api/Notification/GetUnreadCount";
  static const String markAsRead = "/api/Notification/MarkAsRead/";
  static const String markAllAsRead = "/api/Notification/MarkAllAsRead";

  /// funding & payments
  static const String topInvestors = "/api/Investor/GetTopInvestors";
  static const String investorTransactionHistory = "/api/Investor/InvestorTransactionHistory/";
  static const String createProject = "/api/Project/CreateProject";
  static const String getProject = "/api/Project/GetProjects";
  static const String addStage = "/api/Project/AddProjectStage";
  static const String stageList = "/api/Project/ProjectStageList";
  static const String addOrUpdatePhase = "/api/Project/AddOrUpdateProjectProgress";
  static const String workPhaseList = "/api/Project/WorkProgressDetails";
  static const String addBanner = "/api/Project/AddBanner";
  static const String getBanner = "/api/Project/GetBanners";
  static const String deleteBanner = "/api/Project/DeleteBanner";
  static const String userComplaints = "/api/Investor/GetComplaints";
  static const String viewComplaint = "/api/Investor/ViewComplaint";
  static const String solveComplaint = "/api/Investor/SolveComplaint";
  static const String createAdmin = "/api/User/CreateAdmin";
  static const String fundingPaymentOverview = "/api/Investor/FundingPaymentOverview";
  static const String investorTypeCount = "/api/Investor/InvestorTypeCount";
  static const String workUpdate = "/api/Project/AddWorkUpdate";
  static const String deleteWorkUpdate = "/api/Project/DeleteWorkUpdate/";
  static const String addWorkStatus = "/api/Project/AddWorkStatus";
  static const String getWorkStatus = "/api/Project/GetWorkStatus";
  static const String deleteWorkStatus = "/api/Project/DeleteWorkStatus/";
  static const String getDashboard = "/api/Dashboard/GetDashboard";




}