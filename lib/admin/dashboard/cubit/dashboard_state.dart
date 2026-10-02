part of 'dashboard_cubit.dart';

@immutable
class DashboardState {
  const DashboardState({
    this.dashboard,
    this.dashboardLoading = false,
    this.dashboardError,
    this.dashboardLoaded = false,
    this.workPhases = const [],
    this.workProgressLoading = false,
    this.workProgressError,
    this.workProgressLoaded = false,
    this.topInvestors = const [],
    this.topInvestorsLoading = false,
    this.topInvestorsError,
    this.topInvestorsLoaded = false,
    this.recentPayments = const [],
    this.recentPaymentsLoading = false,
    this.recentPaymentsError,
    this.recentPaymentsLoaded = false,
    this.recentUpdates = const [],
    this.recentUpdatesLoading = false,
    this.recentUpdatesError,
    this.recentUpdatesLoaded = false,
  });

  final DashboardModel? dashboard;
  final bool dashboardLoading;
  final String? dashboardError;
  final bool dashboardLoaded;

  final List<WorkPhaseListModel> workPhases;
  final bool workProgressLoading;
  final String? workProgressError;
  final bool workProgressLoaded;

  final List<TopInvestorsModel> topInvestors;
  final bool topInvestorsLoading;
  final String? topInvestorsError;
  final bool topInvestorsLoaded;

  final List<TransactionHistoryModel> recentPayments;
  final bool recentPaymentsLoading;
  final String? recentPaymentsError;
  final bool recentPaymentsLoaded;

  final List<WorkUpdateModel> recentUpdates;
  final bool recentUpdatesLoading;
  final String? recentUpdatesError;
  final bool recentUpdatesLoaded;

  DashboardState copyWith({
    DashboardModel? dashboard,
    bool clearDashboard = false,
    bool? dashboardLoading,
    String? dashboardError,
    bool clearDashboardError = false,
    bool? dashboardLoaded,
    List<WorkPhaseListModel>? workPhases,
    bool? workProgressLoading,
    String? workProgressError,
    bool clearWorkProgressError = false,
    bool? workProgressLoaded,
    List<TopInvestorsModel>? topInvestors,
    bool? topInvestorsLoading,
    String? topInvestorsError,
    bool clearTopInvestorsError = false,
    bool? topInvestorsLoaded,
    List<TransactionHistoryModel>? recentPayments,
    bool? recentPaymentsLoading,
    String? recentPaymentsError,
    bool clearRecentPaymentsError = false,
    bool? recentPaymentsLoaded,
    List<WorkUpdateModel>? recentUpdates,
    bool? recentUpdatesLoading,
    String? recentUpdatesError,
    bool clearRecentUpdatesError = false,
    bool? recentUpdatesLoaded,
  }) {
    return DashboardState(
      dashboard: clearDashboard ? null : (dashboard ?? this.dashboard),
      dashboardLoading: dashboardLoading ?? this.dashboardLoading,
      dashboardError: clearDashboardError
          ? null
          : (dashboardError ?? this.dashboardError),
      dashboardLoaded: dashboardLoaded ?? this.dashboardLoaded,
      workPhases: workPhases ?? this.workPhases,
      workProgressLoading: workProgressLoading ?? this.workProgressLoading,
      workProgressError: clearWorkProgressError
          ? null
          : (workProgressError ?? this.workProgressError),
      workProgressLoaded: workProgressLoaded ?? this.workProgressLoaded,
      topInvestors: topInvestors ?? this.topInvestors,
      topInvestorsLoading: topInvestorsLoading ?? this.topInvestorsLoading,
      topInvestorsError: clearTopInvestorsError
          ? null
          : (topInvestorsError ?? this.topInvestorsError),
      topInvestorsLoaded: topInvestorsLoaded ?? this.topInvestorsLoaded,
      recentPayments: recentPayments ?? this.recentPayments,
      recentPaymentsLoading:
          recentPaymentsLoading ?? this.recentPaymentsLoading,
      recentPaymentsError: clearRecentPaymentsError
          ? null
          : (recentPaymentsError ?? this.recentPaymentsError),
      recentPaymentsLoaded: recentPaymentsLoaded ?? this.recentPaymentsLoaded,
      recentUpdates: recentUpdates ?? this.recentUpdates,
      recentUpdatesLoading: recentUpdatesLoading ?? this.recentUpdatesLoading,
      recentUpdatesError: clearRecentUpdatesError
          ? null
          : (recentUpdatesError ?? this.recentUpdatesError),
      recentUpdatesLoaded: recentUpdatesLoaded ?? this.recentUpdatesLoaded,
    );
  }
}
