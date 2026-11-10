import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/projcet_model.dart';


class ProjectRepository {
  final Dio dio;

  ProjectRepository({
    required this.dio,
  });

  /// Create Project
  Future<ProjectResponseModel?> createProject(
      ProjectRequestModel request,
      ) async {
    try {
      appLog('Creating project...');
      appLog('Project Name: ${request.name}');
      appLog('Total Fund: ${request.totalFund}');

      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.createProject,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );


      return ProjectResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      appLog(
        'Create Project DioException: '
            '${e.message}',
      );

      return null;
    } catch (e) {
      appLog('Create Project Error: $e');

      return null;
    }
  }

  /// Update Project
  ///
  /// Same endpoint is used for update.
  /// ProjectId is required.
  Future<ProjectResponseModel?> updateProject(
      ProjectRequestModel request,
      ) async {
    try {
      if (request.projectId == 0) {
        appLog('Update Project Error: ProjectId is required.');
        return null;
      }

      appLog('Updating project...');
      appLog('Project ID: ${request.projectId}');
      appLog('Project Name: ${request.name}');
      appLog('Total Fund: ${request.totalFund}');

      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.createProject,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );


      return ProjectResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      appLog(
        'Update Project DioException: '
            '${e.message}',
      );

      return null;
    } catch (e) {
      appLog('Update Project Error: $e');

      return null;
    }
  }

  Future<ProjectListResponseModel?> getProjects() async {
    try {
      appLog('Fetching projects...');

      final response = await dio.get(
        ApiEndpoints.getProject,
      );


      return ProjectListResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      appLog(
        'Get Projects DioException: '
            '${e.message}',
      );

      return null;
    } catch (e) {
      appLog('Get Projects Error: $e');

      return null;
    }
  }
}