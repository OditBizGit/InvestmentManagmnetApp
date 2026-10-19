import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/data/dummy_pending_requests.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';

part 'pending_requests_state.dart';

class PendingRequestsCubit extends Cubit<PendingRequestsState> {
  PendingRequestsCubit() : super(const PendingRequestsInitial());

  List<PendingRequestModel> _requests = const [];

  Future<void> loadRequests() async {
    final previous = state;
    if (previous is PendingRequestsLoading) return;

    if (previous is PendingRequestsSuccess) {
      emit(previous.copyWith(isListLoading: true));
    } else {
      emit(const PendingRequestsLoading());
    }

    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (isClosed) return;

    if (_requests.isEmpty) {
      _requests = List<PendingRequestModel>.of(dummyPendingRequests);
    }

    emit(
      PendingRequestsSuccess(
        requests: List<PendingRequestModel>.unmodifiable(_requests),
        overview: PendingRequestsOverviewStats.from(_requests),
      ),
    );
  }

  void markCompleted(String id) {
    _updateStatus(id, PendingRequestStatus.completed);
  }

  void markRejected(String id) {
    _updateStatus(id, PendingRequestStatus.rejected);
  }

  void _updateStatus(String id, PendingRequestStatus status) {
    final current = state;
    if (current is! PendingRequestsSuccess) return;

    _requests = [
      for (final request in _requests)
        if (request.id == id) request.copyWith(status: status) else request,
    ];

    emit(
      current.copyWith(
        requests: List<PendingRequestModel>.unmodifiable(_requests),
        overview: PendingRequestsOverviewStats.from(_requests),
      ),
    );
  }
}
