part of 'staff_report_cubit.dart';

enum StaffReportListStatus { initial, loading, success, failure }

enum StaffReportDetailsStatus { initial, loading, success, failure }

@immutable
class StaffReportState {
  const StaffReportState({
    this.listStatus = StaffReportListStatus.initial,
    this.staffList = const [],
    this.listMessage = '',
    this.listErrorMessage,
    this.detailsStatus = StaffReportDetailsStatus.initial,
    this.details = const [],
    this.detailsMessage = '',
    this.detailsErrorMessage,
  });

  final StaffReportListStatus listStatus;
  final List<StaffReportModel> staffList;
  final String listMessage;
  final String? listErrorMessage;

  final StaffReportDetailsStatus detailsStatus;
  final List<StaffReportDetailsModel> details;
  final String detailsMessage;
  final String? detailsErrorMessage;

  StaffReportState copyWith({
    StaffReportListStatus? listStatus,
    List<StaffReportModel>? staffList,
    String? listMessage,
    String? listErrorMessage,
    bool clearListError = false,
    StaffReportDetailsStatus? detailsStatus,
    List<StaffReportDetailsModel>? details,
    String? detailsMessage,
    String? detailsErrorMessage,
    bool clearDetailsError = false,
    bool clearDetails = false,
  }) {
    return StaffReportState(
      listStatus: listStatus ?? this.listStatus,
      staffList: staffList ?? this.staffList,
      listMessage: listMessage ?? this.listMessage,
      listErrorMessage:
          clearListError ? null : (listErrorMessage ?? this.listErrorMessage),
      detailsStatus: detailsStatus ?? this.detailsStatus,
      details: clearDetails ? const [] : (details ?? this.details),
      detailsMessage: detailsMessage ?? this.detailsMessage,
      detailsErrorMessage: clearDetailsError
          ? null
          : (detailsErrorMessage ?? this.detailsErrorMessage),
    );
  }
}
