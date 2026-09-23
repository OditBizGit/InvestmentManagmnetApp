import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:maribel_wellness_centre_application/admin/settings/repository/settings_repository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_project/model/projcet_model.dart';

part 'create_project_state.dart';

class CreateProjectCubit extends Cubit<CreateProjectState> {
  CreateProjectCubit({
    required ProjectRepository repository,
  })  : _repository = repository,
        super(CreateProjectInitial());

  final ProjectRepository _repository;

  List<ProjectModel> projects = const [];

  Future<void> getProjects() async {
    emit(ProjectsLoading());
    try {
      final response = await _repository.getProjects();

      if (response == null) {
        emit(
          ProjectsFailure(
            'Failed to load projects. Please try again.',
          ),
        );
        return;
      }

      if (!response.status) {
        emit(
          ProjectsFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load projects',
          ),
        );
        return;
      }

      projects = List<ProjectModel>.unmodifiable(response.data);
      emit(ProjectsSuccess(projects));
    } catch (e) {
      emit(
        ProjectsFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> createProject(ProjectRequestModel request) async {
    emit(CreateProjectLoading());
    try {
      final response = await _repository.createProject(request);

      if (response == null) {
        emit(
          CreateProjectFailure(
            'Failed to create project. Please try again.',
          ),
        );
        return;
      }

      if (!response.status) {
        emit(
          CreateProjectFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to create project',
          ),
        );
        return;
      }

      emit(
        CreateProjectSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Project created successfully',
          data: response.data,
        ),
      );
      await getProjects();
    } catch (e) {
      emit(
        CreateProjectFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> updateProject(ProjectRequestModel request) async {
    emit(UpdateProjectLoading());
    try {
      final response = await _repository.updateProject(request);

      if (response == null) {
        emit(
          UpdateProjectFailure(
            'Failed to update project. Please try again.',
          ),
        );
        return;
      }

      if (!response.status) {
        emit(
          UpdateProjectFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to update project',
          ),
        );
        return;
      }

      emit(
        UpdateProjectSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Project updated successfully',
          data: response.data,
        ),
      );
      await getProjects();
    } catch (e) {
      emit(
        UpdateProjectFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
