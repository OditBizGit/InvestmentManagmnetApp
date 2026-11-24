part of 'expected_vs_actual_cubit.dart';

enum ExpectedVsActualListStatus { initial, loading, success, failure }

enum ExpectedVsActualDetailsStatus { initial, loading, success, failure }

@immutable
class ExpectedVsActualState {
  const ExpectedVsActualState({
    this.listStatus = ExpectedVsActualListStatus.initial,
    this.report = const ExpectedVsActualReport(),
    this.listErrorMessage,
    this.detailsStatus = ExpectedVsActualDetailsStatus.initial,
    this.details = const ExpectedVsActualDetails(),
    this.detailsErrorMessage,
  });

  final ExpectedVsActualListStatus listStatus;
  final ExpectedVsActualReport report;
  final String? listErrorMessage;

  final ExpectedVsActualDetailsStatus detailsStatus;
  final ExpectedVsActualDetails details;
  final String? detailsErrorMessage;

  ExpectedVsActualState copyWith({
    ExpectedVsActualListStatus? listStatus,
    ExpectedVsActualReport? report,
    String? listErrorMessage,
    bool clearListError = false,
    ExpectedVsActualDetailsStatus? detailsStatus,
    ExpectedVsActualDetails? details,
    String? detailsErrorMessage,
    bool clearDetailsError = false,
  }) {
    return ExpectedVsActualState(
      listStatus: listStatus ?? this.listStatus,
      report: report ?? this.report,
      listErrorMessage: clearListError
          ? null
          : (listErrorMessage ?? this.listErrorMessage),
      detailsStatus: detailsStatus ?? this.detailsStatus,
      details: details ?? this.details,
      detailsErrorMessage: clearDetailsError
          ? null
          : (detailsErrorMessage ?? this.detailsErrorMessage),
    );
  }
}
