part of 'work_progress_cubit.dart';

@immutable
sealed class WorkProgressState {
  const WorkProgressState();
}

final class WorkProgressInitial extends WorkProgressState {
  const WorkProgressInitial();
}

final class WorkProgressLoading extends WorkProgressState {
  const WorkProgressLoading();
}

final class WorkProgressSuccess extends WorkProgressState {
  final List<WorkPhaseListModel> phases;

  const WorkProgressSuccess(this.phases);
}

final class WorkProgressFailure extends WorkProgressState {
  final String message;

  const WorkProgressFailure(this.message);
}
