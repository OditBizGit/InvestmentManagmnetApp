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
    this.statusUpdatingUserId,
    this.refundUpdatingUserId,
    this.mouUpdatingUserId,
    this.mouLoadingUserId,
    this.llpUpdatingUserId,
    this.llpLoadingUserId,
    this.statusFeedback,
    this.isTableLoading = false,
    this.isExporting = false,
  });

  final List<ManageUsersInvestor> users;
  final Map<int, DocumentProcessStatus> mouStatus;
  final Map<int, DocumentProcessStatus> llpStatus;
  final Map<int, DateTime> mouIssuedAt;
  final Map<int, DateTime> mouCompletedAt;
  final Map<int, DateTime> llpIssuedAt;
  final Map<int, DateTime> llpCompletedAt;
  final int? statusUpdatingUserId;
  final int? refundUpdatingUserId;
  final int? mouUpdatingUserId;
  final int? mouLoadingUserId;
  final int? llpUpdatingUserId;
  final int? llpLoadingUserId;
  final ManageUsersStatusFeedback? statusFeedback;
  final bool isTableLoading;
  final bool isExporting;

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
  }) {
    return ManageUsersSuccess(
      users: users ?? this.users,
      mouStatus: mouStatus ?? this.mouStatus,
      llpStatus: llpStatus ?? this.llpStatus,
      mouIssuedAt: mouIssuedAt ?? this.mouIssuedAt,
      mouCompletedAt: mouCompletedAt ?? this.mouCompletedAt,
      llpIssuedAt: llpIssuedAt ?? this.llpIssuedAt,
      llpCompletedAt: llpCompletedAt ?? this.llpCompletedAt,
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
