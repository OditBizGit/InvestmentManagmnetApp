part of 'pending_requests_cubit.dart';

@immutable
sealed class PendingRequestsState {
  const PendingRequestsState();
}

final class PendingRequestsInitial extends PendingRequestsState {
  const PendingRequestsInitial();
}

final class PendingRequestsLoading extends PendingRequestsState {
  const PendingRequestsLoading();
}

final class PendingRequestsSuccess extends PendingRequestsState {
  const PendingRequestsSuccess({
    required this.requests,
    required this.overview,
    this.isListLoading = false,
  });

  final List<PendingRequestModel> requests;
  final PendingRequestsOverviewStats overview;
  final bool isListLoading;

  PendingRequestsSuccess copyWith({
    List<PendingRequestModel>? requests,
    PendingRequestsOverviewStats? overview,
    bool? isListLoading,
  }) {
    return PendingRequestsSuccess(
      requests: requests ?? this.requests,
      overview: overview ?? this.overview,
      isListLoading: isListLoading ?? this.isListLoading,
    );
  }
}
