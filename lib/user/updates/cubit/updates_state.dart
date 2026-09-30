part of 'updates_cubit.dart';

sealed class UpdatesState {
  const UpdatesState();
}

final class UpdatesInitial extends UpdatesState {
  const UpdatesInitial();
}

final class UpdatesLoading extends UpdatesState {
  const UpdatesLoading();
}

final class UpdatesSuccess extends UpdatesState {
  const UpdatesSuccess(this.updates);

  final List<WorkUpdateModel> updates;
}

final class UpdatesFailure extends UpdatesState {
  const UpdatesFailure(this.message);

  final String message;
}
