part of 'update_phase_cubit.dart';

@immutable
sealed class UpdatePhaseState {
  const UpdatePhaseState();
}

final class UpdatePhaseInitial extends UpdatePhaseState {
  const UpdatePhaseInitial();
}

final class StageListLoading extends UpdatePhaseState {
  const StageListLoading();
}

final class StageListSuccess extends UpdatePhaseState {
  final List<AddPhaseModel> stages;

  const StageListSuccess(this.stages);
}

final class StageListFailure extends UpdatePhaseState {
  final String message;

  const StageListFailure(this.message);
}

final class UpdatePhaseLoading extends UpdatePhaseState {
  const UpdatePhaseLoading();
}

final class UpdatePhaseSuccess extends UpdatePhaseState {
  final AddPhaseModel phase;
  final String message;

  const UpdatePhaseSuccess({
    required this.phase,
    required this.message,
  });
}

final class UpdatePhaseError extends UpdatePhaseState {
  final String message;

  const UpdatePhaseError({
    required this.message,
  });
}

final class WorkPhaseListLoading extends UpdatePhaseState {
  const WorkPhaseListLoading();
}

final class WorkPhaseListSuccess extends UpdatePhaseState {
  final List<WorkPhaseListModel> phases;

  const WorkPhaseListSuccess(this.phases);
}

final class WorkPhaseListFailure extends UpdatePhaseState {
  final String message;

  const WorkPhaseListFailure(this.message);
}

final class SaveWorkPhaseLoading extends UpdatePhaseState {
  const SaveWorkPhaseLoading();
}

final class SaveWorkPhaseSuccess extends UpdatePhaseState {
  final AddOrUpdatePhaseResponseModel phase;
  final String message;
  final bool isUpdate;

  const SaveWorkPhaseSuccess({
    required this.phase,
    required this.message,
    required this.isUpdate,
  });
}

final class SaveWorkPhaseFailure extends UpdatePhaseState {
  final String message;

  const SaveWorkPhaseFailure(this.message);
}
