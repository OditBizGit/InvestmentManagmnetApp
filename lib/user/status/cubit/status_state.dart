part of 'status_cubit.dart';

sealed class StatusState {
  const StatusState();
}

final class StatusInitial extends StatusState {
  const StatusInitial();
}

final class StatusLoading extends StatusState {
  const StatusLoading();
}

final class StatusSuccess extends StatusState {
  const StatusSuccess(this.statuses);

  final List<WorkStatusModel> statuses;
}

final class StatusFailure extends StatusState {
  const StatusFailure(this.message);

  final String message;
}
