import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

import '../model/expected_vs_actual_model.dart';
import '../repository/expected_vs_actual_repository.dart';

part 'expected_vs_actual_state.dart';

const String _genericError = 'Something went wrong. Please try again.';

class ExpectedVsActualCubit extends Cubit<ExpectedVsActualState> {
  ExpectedVsActualCubit(this.repository) : super(const ExpectedVsActualState());

  final ExpectedVsActualRepository repository;

  /// Ignore answers of requests that were superseded.
  int _listRequest = 0;
  int _detailsRequest = 0;

  Future<void> fetchReport({
    required DateTime fromMonth,
    required DateTime toMonth,
  }) async {
    final request = ++_listRequest;
    emit(
      state.copyWith(
        listStatus: ExpectedVsActualListStatus.loading,
        clearListError: true,
      ),
    );
    try {
      final response = await repository.getReport(
        fromMonth: fromMonth,
        toMonth: toMonth,
      );
      if (isClosed || request != _listRequest) return;
      if (response.success) {
        emit(
          state.copyWith(
            listStatus: ExpectedVsActualListStatus.success,
            report: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            listStatus: ExpectedVsActualListStatus.failure,
            listErrorMessage: response.message.isEmpty
                ? _genericError
                : response.message,
          ),
        );
      }
    } catch (e) {
      if (isClosed || request != _listRequest) return;
      emit(
        state.copyWith(
          listStatus: ExpectedVsActualListStatus.failure,
          listErrorMessage: ApiErrorMessage.from(e),
        ),
      );
    }
  }

  /// Leaves the month list untouched so Back needs no refetch.
  Future<void> fetchDetails(DateTime month) async {
    final request = ++_detailsRequest;
    emit(
      state.copyWith(
        detailsStatus: ExpectedVsActualDetailsStatus.loading,
        details: const ExpectedVsActualDetails(),
        clearDetailsError: true,
      ),
    );
    try {
      final response = await repository.getDetails(month: month);
      if (isClosed || request != _detailsRequest) return;
      if (response.success) {
        emit(
          state.copyWith(
            detailsStatus: ExpectedVsActualDetailsStatus.success,
            details: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            detailsStatus: ExpectedVsActualDetailsStatus.failure,
            detailsErrorMessage: response.message.isEmpty
                ? _genericError
                : response.message,
          ),
        );
      }
    } catch (e) {
      if (isClosed || request != _detailsRequest) return;
      emit(
        state.copyWith(
          detailsStatus: ExpectedVsActualDetailsStatus.failure,
          detailsErrorMessage: ApiErrorMessage.from(e),
        ),
      );
    }
  }

  void resetDetails() {
    _detailsRequest++;
    emit(
      state.copyWith(
        detailsStatus: ExpectedVsActualDetailsStatus.initial,
        details: const ExpectedVsActualDetails(),
        clearDetailsError: true,
      ),
    );
  }
}
