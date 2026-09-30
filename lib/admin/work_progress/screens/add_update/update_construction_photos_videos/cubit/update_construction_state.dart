part of 'update_construction_cubit.dart';

@immutable
sealed class UpdateConstructionState {}

final class UpdateConstructionInitial extends UpdateConstructionState {}

final class UpdateConstructionLoading extends UpdateConstructionState {}

final class UpdateConstructionSuccess extends UpdateConstructionState {
  final AddWorkUpdateModel response;

  UpdateConstructionSuccess({
    required this.response,
  });
}

final class UpdateConstructionError extends UpdateConstructionState {
  final String message;

  UpdateConstructionError({
    required this.message,
  });
}

final class GetWorkUpdatesLoading extends UpdateConstructionState {}

final class GetWorkUpdatesSuccess extends UpdateConstructionState {
  final List<WorkUpdateModel> updates;

  GetWorkUpdatesSuccess({
    required this.updates,
  });
}

final class GetWorkUpdatesError extends UpdateConstructionState {
  final String message;

  GetWorkUpdatesError({
    required this.message,
  });
}

final class DeleteWorkUpdateLoading extends UpdateConstructionState {
  final int workUpdateId;

  DeleteWorkUpdateLoading({
    required this.workUpdateId,
  });
}

final class DeleteWorkUpdateSuccess extends UpdateConstructionState {
  final int workUpdateId;
  final String message;

  DeleteWorkUpdateSuccess({
    required this.workUpdateId,
    required this.message,
  });
}

final class DeleteWorkUpdateError extends UpdateConstructionState {
  final String message;

  DeleteWorkUpdateError({
    required this.message,
  });
}
