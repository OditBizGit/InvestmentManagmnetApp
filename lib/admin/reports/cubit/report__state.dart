part of 'report__cubit.dart';

@immutable
class ReportState {
  const ReportState({
    this.phases = const [],
    this.workProgressLoading = false,
    this.workProgressError,
    this.transactions = const [],
    this.transactionsLoading = false,
    this.transactionsError,
    this.fundingOverview,
    this.fundingOverviewLoading = false,
    this.fundingOverviewError,
    this.investorTypeCount,
    this.investorTypeCountLoading = false,
    this.investorTypeCountError,
  });

  final List<WorkPhaseListModel> phases;
  final bool workProgressLoading;
  final String? workProgressError;

  final List<InvestorTransactionHistoryModel> transactions;
  final bool transactionsLoading;
  final String? transactionsError;

  final FundingPaymentOverviewModel? fundingOverview;
  final bool fundingOverviewLoading;
  final String? fundingOverviewError;

  final InvestorTypeCountModel? investorTypeCount;
  final bool investorTypeCountLoading;
  final String? investorTypeCountError;

  bool get hasWorkProgressData => phases.isNotEmpty;
  bool get hasTransactionsData => transactions.isNotEmpty;
  bool get hasFundingOverviewData =>
      fundingOverview != null &&
      (fundingOverview!.data.isNotEmpty || fundingOverview!.summary.isNotEmpty);
  bool get hasInvestorTypeCountData =>
      investorTypeCount != null &&
      (investorTypeCount!.totalInvestors > 0 ||
          investorTypeCount!.investorTypes.isNotEmpty);

  List<FundingPaymentMonthModel> get fundingOverviewMonths =>
      fundingOverview?.data ?? const [];

  FundingPaymentSummaryModel? get fundingOverviewSummary =>
      fundingOverview?.firstSummary;

  ReportState copyWith({
    List<WorkPhaseListModel>? phases,
    bool? workProgressLoading,
    String? workProgressError,
    bool clearWorkProgressError = false,
    List<InvestorTransactionHistoryModel>? transactions,
    bool? transactionsLoading,
    String? transactionsError,
    bool clearTransactionsError = false,
    FundingPaymentOverviewModel? fundingOverview,
    bool clearFundingOverview = false,
    bool? fundingOverviewLoading,
    String? fundingOverviewError,
    bool clearFundingOverviewError = false,
    InvestorTypeCountModel? investorTypeCount,
    bool clearInvestorTypeCount = false,
    bool? investorTypeCountLoading,
    String? investorTypeCountError,
    bool clearInvestorTypeCountError = false,
  }) {
    return ReportState(
      phases: phases ?? this.phases,
      workProgressLoading: workProgressLoading ?? this.workProgressLoading,
      workProgressError: clearWorkProgressError
          ? null
          : (workProgressError ?? this.workProgressError),
      transactions: transactions ?? this.transactions,
      transactionsLoading: transactionsLoading ?? this.transactionsLoading,
      transactionsError: clearTransactionsError
          ? null
          : (transactionsError ?? this.transactionsError),
      fundingOverview: clearFundingOverview
          ? null
          : (fundingOverview ?? this.fundingOverview),
      fundingOverviewLoading:
          fundingOverviewLoading ?? this.fundingOverviewLoading,
      fundingOverviewError: clearFundingOverviewError
          ? null
          : (fundingOverviewError ?? this.fundingOverviewError),
      investorTypeCount: clearInvestorTypeCount
          ? null
          : (investorTypeCount ?? this.investorTypeCount),
      investorTypeCountLoading:
          investorTypeCountLoading ?? this.investorTypeCountLoading,
      investorTypeCountError: clearInvestorTypeCountError
          ? null
          : (investorTypeCountError ?? this.investorTypeCountError),
    );
  }
}
