import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/reports/shared/report_period_range.dart';
import 'package:maribel_wellness_centre_application/admin/reports/staff_report/widgets/staff_report_table_section.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';

import '../model/refund_termination_model.dart';
import '../repository/refund_termination_repository.dart';

part 'refund_termination_state.dart';

class RefundTerminationCubit extends Cubit<RefundTerminationState> {
  RefundTerminationCubit(this.repository)
    : super(const RefundTerminationInitial());

  final RefundTerminationRepository repository;

  /// Only the latest request may emit; older responses are dropped.
  int _requestId = 0;

  Future<void> load({
    required StaffReportPeriod period,
    DateTime? customFrom,
    DateTime? customTo,
  }) async {
    final id = ++_requestId;
    emit(const RefundTerminationLoading());
    try {
      final (from, to) = reportPeriodRange(
        period,
        customFrom: customFrom,
        customTo: customTo,
      );
      final report = await repository.getReport(fromDate: from, toDate: to);
      if (isClosed || id != _requestId) return;
      emit(RefundTerminationLoaded(report));
    } on ArgumentError {
      if (isClosed || id != _requestId) return;
      emit(const RefundTerminationError('Select a valid date range.'));
    } catch (e) {
      if (isClosed || id != _requestId) return;
      emit(RefundTerminationError(ApiErrorMessage.from(e)));
    }
  }
}
