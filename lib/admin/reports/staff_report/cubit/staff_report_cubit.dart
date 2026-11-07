import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/staff_report_details_model.dart';
import '../model/staff_report_model.dart';
import '../repository/staff_report_repository.dart';

part 'staff_report_state.dart';

class StaffReportCubit extends Cubit<StaffReportState> {
  StaffReportCubit(this.repository) : super(const StaffReportState());

  final StaffReportRepository repository;

  Future<void> fetchStaffReport({
    String period = 'ThisMonth',
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    try {
      emit(
        state.copyWith(
          listStatus: StaffReportListStatus.loading,
          clearListError: true,
        ),
      );

      final response = await repository.getStaffReport(
        period: period,
        fromDate: fromDate,
        toDate: toDate,
        search: search,
      );

      if (response.success) {
        emit(
          state.copyWith(
            listStatus: StaffReportListStatus.success,
            staffList: response.data,
            listMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            listStatus: StaffReportListStatus.failure,
            listErrorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: StaffReportListStatus.failure,
          listErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchStaffReportDetails({
    required int staffId,
    String period = 'ThisMonth',
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    try {
      emit(
        state.copyWith(
          detailsStatus: StaffReportDetailsStatus.loading,
          clearDetailsError: true,
        ),
      );

      final response = await repository.getStaffReportDetails(
        staffId: staffId,
        period: period,
        fromDate: fromDate,
        toDate: toDate,
        search: search,
      );

      if (response.success) {
        emit(
          state.copyWith(
            detailsStatus: StaffReportDetailsStatus.success,
            details: response.data,
            detailsMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            detailsStatus: StaffReportDetailsStatus.failure,
            detailsErrorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          detailsStatus: StaffReportDetailsStatus.failure,
          detailsErrorMessage: e.toString(),
        ),
      );
    }
  }

  void resetDetails() {
    emit(
      state.copyWith(
        detailsStatus: StaffReportDetailsStatus.initial,
        clearDetails: true,
        detailsMessage: '',
        clearDetailsError: true,
      ),
    );
  }
}
