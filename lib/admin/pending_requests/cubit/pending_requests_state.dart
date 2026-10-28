part of 'pending_requests_cubit.dart';

@immutable
sealed class PendingRequestsState {
  const PendingRequestsState();
}

final class PendingRequestsInitial extends PendingRequestsState {
  const PendingRequestsInitial();
}

final class PendingRequestsLoading extends PendingRequestsState {
  const PendingRequestsLoading({
    this.statusFilter = PendingRequestsListFilter.all,
  });

  final PendingRequestsListFilter statusFilter;
}

final class PendingRequestsSuccess extends PendingRequestsState {
  const PendingRequestsSuccess({
    required this.requests,
    required this.overview,
    required this.statusFilter,
    this.isListLoading = false,
    this.investorDetails,
    this.isInvestorDetailsLoading = false,
    this.investorDetailsError,
    this.isReviewSubmitting = false,
    this.reviewFeedback,
  });

  final List<PendingRequestModel> requests;
  final PendingRequestsOverviewStats overview;
  final PendingRequestsListFilter statusFilter;
  final bool isListLoading;
  final InvestorDetailsModel? investorDetails;
  final bool isInvestorDetailsLoading;
  final String? investorDetailsError;
  final bool isReviewSubmitting;
  final PendingRequestReviewFeedback? reviewFeedback;

  PendingRequestsSuccess copyWith({
    List<PendingRequestModel>? requests,
    PendingRequestsOverviewStats? overview,
    PendingRequestsListFilter? statusFilter,
    bool? isListLoading,
    InvestorDetailsModel? investorDetails,
    bool clearInvestorDetails = false,
    bool? isInvestorDetailsLoading,
    String? investorDetailsError,
    bool clearInvestorDetailsError = false,
    bool? isReviewSubmitting,
    PendingRequestReviewFeedback? reviewFeedback,
    bool clearReviewFeedback = false,
  }) {
    return PendingRequestsSuccess(
      requests: requests ?? this.requests,
      overview: overview ?? this.overview,
      statusFilter: statusFilter ?? this.statusFilter,
      isListLoading: isListLoading ?? this.isListLoading,
      investorDetails:
          clearInvestorDetails ? null : (investorDetails ?? this.investorDetails),
      isInvestorDetailsLoading:
          isInvestorDetailsLoading ?? this.isInvestorDetailsLoading,
      investorDetailsError: clearInvestorDetailsError
          ? null
          : (investorDetailsError ?? this.investorDetailsError),
      isReviewSubmitting: isReviewSubmitting ?? this.isReviewSubmitting,
      reviewFeedback: clearReviewFeedback
          ? null
          : (reviewFeedback ?? this.reviewFeedback),
    );
  }
}

final class PendingRequestsFailure extends PendingRequestsState {
  const PendingRequestsFailure({
    required this.message,
    required this.statusFilter,
    this.overview = PendingRequestsOverviewStats.empty,
  });

  final String message;
  final PendingRequestsListFilter statusFilter;
  final PendingRequestsOverviewStats overview;
}

@immutable
class PendingRequestReviewFeedback {
  const PendingRequestReviewFeedback({
    required this.isSuccess,
    required this.message,
    this.status,
  });

  final bool isSuccess;
  final String message;
  final PendingRequestStatus? status;
}
