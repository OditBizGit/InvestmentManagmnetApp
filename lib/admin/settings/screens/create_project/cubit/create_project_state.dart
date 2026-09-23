part of 'create_project_cubit.dart';

@immutable
sealed class CreateProjectState {}

final class CreateProjectInitial extends CreateProjectState {}

final class ProjectsLoading extends CreateProjectState {}

final class ProjectsSuccess extends CreateProjectState {
  ProjectsSuccess(this.projects);

  final List<ProjectModel> projects;
}

final class ProjectsFailure extends CreateProjectState {
  ProjectsFailure(this.message);

  final String message;
}

final class CreateProjectLoading extends CreateProjectState {}

final class CreateProjectSuccess extends CreateProjectState {
  CreateProjectSuccess({
    required this.message,
    this.data,
  });

  final String message;
  final ProjectModel? data;
}

final class CreateProjectFailure extends CreateProjectState {
  CreateProjectFailure(this.message);

  final String message;
}

final class UpdateProjectLoading extends CreateProjectState {}

final class UpdateProjectSuccess extends CreateProjectState {
  UpdateProjectSuccess({
    required this.message,
    this.data,
  });

  final String message;
  final ProjectModel? data;
}

final class UpdateProjectFailure extends CreateProjectState {
  UpdateProjectFailure(this.message);

  final String message;
}
