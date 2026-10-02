part of 'update_status_cubit.dart';

@immutable
sealed class UpdateStatusState {}

final class UpdateStatusInitial extends UpdateStatusState {}

final class UpdateStatusLoading extends UpdateStatusState {}

final class UpdateStatusSuccess extends UpdateStatusState {
  final String message;
  final WorkStatusModel? data;

  UpdateStatusSuccess({
    required this.message,
    this.data,
  });
}

final class UpdateStatusError extends UpdateStatusState {
  final String message;

  UpdateStatusError({
    required this.message,
  });
}

final class GetWorkStatusLoading extends UpdateStatusState {}

final class GetWorkStatusSuccess extends UpdateStatusState {
  final String message;
  final List<WorkStatusModel> workStatuses;

  GetWorkStatusSuccess({
    required this.message,
    required this.workStatuses,
  });
}

final class GetWorkStatusError extends UpdateStatusState {
  final String message;

  GetWorkStatusError({
    required this.message,
  });
}

final class DeleteWorkStatusLoading extends UpdateStatusState {
  final int workStatusId;

  DeleteWorkStatusLoading({
    required this.workStatusId,
  });
}

final class DeleteWorkStatusSuccess extends UpdateStatusState {
  final int workStatusId;
  final String message;

  DeleteWorkStatusSuccess({
    required this.workStatusId,
    required this.message,
  });
}

final class DeleteWorkStatusError extends UpdateStatusState {
  final String message;

  DeleteWorkStatusError({
    required this.message,
  });
}
