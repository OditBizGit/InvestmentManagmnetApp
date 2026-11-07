part of 'manage_users_cubit.dart';

class ManageUsersExportResult {
  const ManageUsersExportResult({
    required this.success,
    required this.message,
    this.savedLocation,
  });

  final bool success;
  final String message;
  final String? savedLocation;
}

sealed class ManageUsersState {
  const ManageUsersState();
}

final class ManageUsersInitial extends ManageUsersState {
  const ManageUsersInitial();
}

final class ManageUsersLoading extends ManageUsersState {
  const ManageUsersLoading();
}

final class ManageUsersEmpty extends ManageUsersState {
  const ManageUsersEmpty({
    this.isTableLoading = false,
    this.isExporting = false,
  });

  final bool isTableLoading;
  final bool isExporting;

  ManageUsersEmpty copyWith({
    bool? isTableLoading,
    bool? isExporting,
  }) {
    return ManageUsersEmpty(
      isTableLoading: isTableLoading ?? this.isTableLoading,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

class ManageUsersStatusFeedback {
  const ManageUsersStatusFeedback({
    required this.isSuccess,
    required this.message,
    this.title,
  });

  final bool isSuccess;
  final String message;
  final String? title;
}

final class ManageUsersSuccess extends ManageUsersState {
  const ManageUsersSuccess({
    required this.users,
    this.mouStatus = const {},
    this.llpStatus = const {},
    this.mouIssuedAt = const {},
    this.mouCompletedAt = const {},
    this.llpIssuedAt = const {},
    this.llpCompletedAt = const {},
    this.mouDocumentPath = const {},
    this.llpDocumentPath = const {},
    this.mouDocumentUpdatedAt = const {},
    this.llpDocumentUpdatedAt = const {},
    this.statusUpdatingUserId,
    this.refundUpdatingUserId,
    this.mouUpdatingUserId,
    this.mouLoadingUserId,
    this.llpUpdatingUserId,
    this.llpLoadingUserId,
    this.statusFeedback,
    this.isTableLoading = false,
    this.isExporting = false,
    this.transactionHistoryResponse,
    this.isTransactionHistoryLoading = false,
    this.transactionHistoryError,
    this.blockRequestsResponse,
    this.isBlockRequestsLoading = false,
    this.blockRequestsError,
    this.blockRequestsStatusFilter,
    this.blockRequestReviewingId,
  });

  final List<ManageUsersInvestor> users;
  final Map<int, DocumentProcessStatus> mouStatus;
  final Map<int, DocumentProcessStatus> llpStatus;
  final Map<int, DateTime> mouIssuedAt;
  final Map<int, DateTime> mouCompletedAt;
  final Map<int, DateTime> llpIssuedAt;
  final Map<int, DateTime> llpCompletedAt;
  final Map<int, String> mouDocumentPath;
  final Map<int, String> llpDocumentPath;
  final Map<int, DateTime> mouDocumentUpdatedAt;
  final Map<int, DateTime> llpDocumentUpdatedAt;
  final int? statusUpdatingUserId;
  final int? refundUpdatingUserId;
  final int? mouUpdatingUserId;
  final int? mouLoadingUserId;
  final int? llpUpdatingUserId;
  final int? llpLoadingUserId;
  final ManageUsersStatusFeedback? statusFeedback;
  final bool isTableLoading;
  final bool isExporting;
  final InvestorTransactionHistoryResponseModel? transactionHistoryResponse;
  final bool isTransactionHistoryLoading;
  final String? transactionHistoryError;
  final InvestorBlockRequestsResponse? blockRequestsResponse;
  final bool isBlockRequestsLoading;
  final String? blockRequestsError;
  final String? blockRequestsStatusFilter;
  final int? blockRequestReviewingId;

  List<InvestorBlockRequestModel> get blockRequests =>
      blockRequestsResponse?.requests ?? const [];

  int get totalUsers => users.length;

  int get activeUsers => users.where((user) => !user.isBlocked).length;

  int get blockedUsers => users.where((user) => user.isBlocked).length;

  int get usersWithPendingDues =>
      users.where((user) => user.hasPendingDues).length;

  ManageUsersSuccess copyWith({
    List<ManageUsersInvestor>? users,
    Map<int, DocumentProcessStatus>? mouStatus,
    Map<int, DocumentProcessStatus>? llpStatus,
    Map<int, DateTime>? mouIssuedAt,
    Map<int, DateTime>? mouCompletedAt,
    Map<int, DateTime>? llpIssuedAt,
    Map<int, DateTime>? llpCompletedAt,
    Map<int, String>? mouDocumentPath,
    Map<int, String>? llpDocumentPath,
    Map<int, DateTime>? mouDocumentUpdatedAt,
    Map<int, DateTime>? llpDocumentUpdatedAt,
    int? statusUpdatingUserId,
    bool clearStatusUpdatingUserId = false,
    int? refundUpdatingUserId,
    bool clearRefundUpdatingUserId = false,
    int? mouUpdatingUserId,
    bool clearMouUpdatingUserId = false,
    int? mouLoadingUserId,
    bool clearMouLoadingUserId = false,
    int? llpUpdatingUserId,
    bool clearLlpUpdatingUserId = false,
    int? llpLoadingUserId,
    bool clearLlpLoadingUserId = false,
    ManageUsersStatusFeedback? statusFeedback,
    bool clearStatusFeedback = false,
    bool? isTableLoading,
    bool? isExporting,
    InvestorTransactionHistoryResponseModel? transactionHistoryResponse,
    bool clearTransactionHistoryResponse = false,
    bool? isTransactionHistoryLoading,
    String? transactionHistoryError,
    bool clearTransactionHistoryError = false,
    InvestorBlockRequestsResponse? blockRequestsResponse,
    bool clearBlockRequestsResponse = false,
    bool? isBlockRequestsLoading,
    String? blockRequestsError,
    bool clearBlockRequestsError = false,
    String? blockRequestsStatusFilter,
    bool clearBlockRequestsStatusFilter = false,
    int? blockRequestReviewingId,
    bool clearBlockRequestReviewingId = false,
  }) {
    return ManageUsersSuccess(
      users: users ?? this.users,
      mouStatus: mouStatus ?? this.mouStatus,
      llpStatus: llpStatus ?? this.llpStatus,
      mouIssuedAt: mouIssuedAt ?? this.mouIssuedAt,
      mouCompletedAt: mouCompletedAt ?? this.mouCompletedAt,
      llpIssuedAt: llpIssuedAt ?? this.llpIssuedAt,
      llpCompletedAt: llpCompletedAt ?? this.llpCompletedAt,
      mouDocumentPath: mouDocumentPath ?? this.mouDocumentPath,
      llpDocumentPath: llpDocumentPath ?? this.llpDocumentPath,
      mouDocumentUpdatedAt:
          mouDocumentUpdatedAt ?? this.mouDocumentUpdatedAt,
      llpDocumentUpdatedAt:
          llpDocumentUpdatedAt ?? this.llpDocumentUpdatedAt,
      statusUpdatingUserId: clearStatusUpdatingUserId
          ? null
          : statusUpdatingUserId ?? this.statusUpdatingUserId,
      refundUpdatingUserId: clearRefundUpdatingUserId
          ? null
          : refundUpdatingUserId ?? this.refundUpdatingUserId,
      mouUpdatingUserId: clearMouUpdatingUserId
          ? null
          : mouUpdatingUserId ?? this.mouUpdatingUserId,
      mouLoadingUserId: clearMouLoadingUserId
          ? null
          : mouLoadingUserId ?? this.mouLoadingUserId,
      llpUpdatingUserId: clearLlpUpdatingUserId
          ? null
          : llpUpdatingUserId ?? this.llpUpdatingUserId,
      llpLoadingUserId: clearLlpLoadingUserId
          ? null
          : llpLoadingUserId ?? this.llpLoadingUserId,
      statusFeedback: clearStatusFeedback
          ? null
          : statusFeedback ?? this.statusFeedback,
      isTableLoading: isTableLoading ?? this.isTableLoading,
      isExporting: isExporting ?? this.isExporting,
      transactionHistoryResponse: clearTransactionHistoryResponse
          ? null
          : transactionHistoryResponse ?? this.transactionHistoryResponse,
      isTransactionHistoryLoading:
          isTransactionHistoryLoading ?? this.isTransactionHistoryLoading,
      transactionHistoryError: clearTransactionHistoryError
          ? null
          : transactionHistoryError ?? this.transactionHistoryError,
      blockRequestsResponse: clearBlockRequestsResponse
          ? null
          : blockRequestsResponse ?? this.blockRequestsResponse,
      isBlockRequestsLoading:
          isBlockRequestsLoading ?? this.isBlockRequestsLoading,
      blockRequestsError: clearBlockRequestsError
          ? null
          : blockRequestsError ?? this.blockRequestsError,
      blockRequestsStatusFilter: clearBlockRequestsStatusFilter
          ? null
          : blockRequestsStatusFilter ?? this.blockRequestsStatusFilter,
      blockRequestReviewingId: clearBlockRequestReviewingId
          ? null
          : blockRequestReviewingId ?? this.blockRequestReviewingId,
    );
  }
}

final class ManageUsersFailure extends ManageUsersState {
  ManageUsersFailure(this.message, {this.isExporting = false});

  final String message;
  final bool isExporting;

  ManageUsersFailure copyWith({
    String? message,
    bool? isExporting,
  }) {
    return ManageUsersFailure(
      message ?? this.message,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

final class InvestorTransactionHistoryLoading extends ManageUsersSuccess {
  const InvestorTransactionHistoryLoading({
    super.users = const [],
    super.mouStatus = const {},
    super.llpStatus = const {},
    super.mouIssuedAt = const {},
    super.mouCompletedAt = const {},
    super.llpIssuedAt = const {},
    super.llpCompletedAt = const {},
    super.mouDocumentPath = const {},
    super.llpDocumentPath = const {},
    super.mouDocumentUpdatedAt = const {},
    super.llpDocumentUpdatedAt = const {},
    super.statusUpdatingUserId,
    super.refundUpdatingUserId,
    super.mouUpdatingUserId,
    super.mouLoadingUserId,
    super.llpUpdatingUserId,
    super.llpLoadingUserId,
    super.statusFeedback,
    super.isTableLoading = false,
    super.isExporting = false,
    super.transactionHistoryResponse,
    super.isTransactionHistoryLoading = true,
    super.transactionHistoryError,
  });

  factory InvestorTransactionHistoryLoading.fromSuccess(
    ManageUsersSuccess success,
  ) {
    return InvestorTransactionHistoryLoading(
      users: success.users,
      mouStatus: success.mouStatus,
      llpStatus: success.llpStatus,
      mouIssuedAt: success.mouIssuedAt,
      mouCompletedAt: success.mouCompletedAt,
      llpIssuedAt: success.llpIssuedAt,
      llpCompletedAt: success.llpCompletedAt,
      mouDocumentPath: success.mouDocumentPath,
      llpDocumentPath: success.llpDocumentPath,
      mouDocumentUpdatedAt: success.mouDocumentUpdatedAt,
      llpDocumentUpdatedAt: success.llpDocumentUpdatedAt,
      statusUpdatingUserId: success.statusUpdatingUserId,
      refundUpdatingUserId: success.refundUpdatingUserId,
      mouUpdatingUserId: success.mouUpdatingUserId,
      mouLoadingUserId: success.mouLoadingUserId,
      llpUpdatingUserId: success.llpUpdatingUserId,
      llpLoadingUserId: success.llpLoadingUserId,
      statusFeedback: success.statusFeedback,
      isTableLoading: success.isTableLoading,
      isExporting: success.isExporting,
      transactionHistoryResponse: success.transactionHistoryResponse,
      isTransactionHistoryLoading: true,
      transactionHistoryError: null,
    );
  }
}

final class InvestorTransactionHistorySuccess extends ManageUsersSuccess {
  const InvestorTransactionHistorySuccess({
    required this.response,
    super.users = const [],
    super.mouStatus = const {},
    super.llpStatus = const {},
    super.mouIssuedAt = const {},
    super.mouCompletedAt = const {},
    super.llpIssuedAt = const {},
    super.llpCompletedAt = const {},
    super.mouDocumentPath = const {},
    super.llpDocumentPath = const {},
    super.mouDocumentUpdatedAt = const {},
    super.llpDocumentUpdatedAt = const {},
    super.statusUpdatingUserId,
    super.refundUpdatingUserId,
    super.mouUpdatingUserId,
    super.mouLoadingUserId,
    super.llpUpdatingUserId,
    super.llpLoadingUserId,
    super.statusFeedback,
    super.isTableLoading = false,
    super.isExporting = false,
    super.isTransactionHistoryLoading = false,
    super.transactionHistoryError,
  }) : super(transactionHistoryResponse: response);

  final InvestorTransactionHistoryResponseModel response;

  factory InvestorTransactionHistorySuccess.fromSuccess({
    required ManageUsersSuccess success,
    required InvestorTransactionHistoryResponseModel response,
  }) {
    return InvestorTransactionHistorySuccess(
      response: response,
      users: success.users,
      mouStatus: success.mouStatus,
      llpStatus: success.llpStatus,
      mouIssuedAt: success.mouIssuedAt,
      mouCompletedAt: success.mouCompletedAt,
      llpIssuedAt: success.llpIssuedAt,
      llpCompletedAt: success.llpCompletedAt,
      mouDocumentPath: success.mouDocumentPath,
      llpDocumentPath: success.llpDocumentPath,
      mouDocumentUpdatedAt: success.mouDocumentUpdatedAt,
      llpDocumentUpdatedAt: success.llpDocumentUpdatedAt,
      statusUpdatingUserId: success.statusUpdatingUserId,
      refundUpdatingUserId: success.refundUpdatingUserId,
      mouUpdatingUserId: success.mouUpdatingUserId,
      mouLoadingUserId: success.mouLoadingUserId,
      llpUpdatingUserId: success.llpUpdatingUserId,
      llpLoadingUserId: success.llpLoadingUserId,
      statusFeedback: success.statusFeedback,
      isTableLoading: success.isTableLoading,
      isExporting: success.isExporting,
    );
  }
}

final class InvestorTransactionHistoryFailure extends ManageUsersSuccess {
  const InvestorTransactionHistoryFailure(
    this.message, {
    super.users = const [],
    super.mouStatus = const {},
    super.llpStatus = const {},
    super.mouIssuedAt = const {},
    super.mouCompletedAt = const {},
    super.llpIssuedAt = const {},
    super.llpCompletedAt = const {},
    super.mouDocumentPath = const {},
    super.llpDocumentPath = const {},
    super.mouDocumentUpdatedAt = const {},
    super.llpDocumentUpdatedAt = const {},
    super.statusUpdatingUserId,
    super.refundUpdatingUserId,
    super.mouUpdatingUserId,
    super.mouLoadingUserId,
    super.llpUpdatingUserId,
    super.llpLoadingUserId,
    super.statusFeedback,
    super.isTableLoading = false,
    super.isExporting = false,
    super.transactionHistoryResponse,
    super.isTransactionHistoryLoading = false,
  }) : super(transactionHistoryError: message);

  final String message;

  factory InvestorTransactionHistoryFailure.fromSuccess({
    required ManageUsersSuccess success,
    required String message,
  }) {
    return InvestorTransactionHistoryFailure(
      message,
      users: success.users,
      mouStatus: success.mouStatus,
      llpStatus: success.llpStatus,
      mouIssuedAt: success.mouIssuedAt,
      mouCompletedAt: success.mouCompletedAt,
      llpIssuedAt: success.llpIssuedAt,
      llpCompletedAt: success.llpCompletedAt,
      mouDocumentPath: success.mouDocumentPath,
      llpDocumentPath: success.llpDocumentPath,
      mouDocumentUpdatedAt: success.mouDocumentUpdatedAt,
      llpDocumentUpdatedAt: success.llpDocumentUpdatedAt,
      statusUpdatingUserId: success.statusUpdatingUserId,
      refundUpdatingUserId: success.refundUpdatingUserId,
      mouUpdatingUserId: success.mouUpdatingUserId,
      mouLoadingUserId: success.mouLoadingUserId,
      llpUpdatingUserId: success.llpUpdatingUserId,
      llpLoadingUserId: success.llpLoadingUserId,
      statusFeedback: success.statusFeedback,
      isTableLoading: success.isTableLoading,
      isExporting: success.isExporting,
      transactionHistoryResponse: success.transactionHistoryResponse,
    );
  }
}