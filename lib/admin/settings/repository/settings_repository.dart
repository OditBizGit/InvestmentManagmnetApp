import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../screens/create_project/model/projcet_model.dart';

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
      log('Creating project...');
      log('Project Name: ${request.name}');
      log('Total Fund: ${request.totalFund}');

      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.createProject,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      log('Create Project Response: ${response.data}');

      return ProjectResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Create Project DioException: '
            '${e.response?.data ?? e.message}',
      );

      return null;
    } catch (e) {
      log('Create Project Error: $e');

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
        log('Update Project Error: ProjectId is required.');
        return null;
      }

      log('Updating project...');
      log('Project ID: ${request.projectId}');
      log('Project Name: ${request.name}');
      log('Total Fund: ${request.totalFund}');

      final formData = await request.toFormData();

      final response = await dio.post(
        ApiEndpoints.createProject,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      log('Update Project Response: ${response.data}');

      return ProjectResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Update Project DioException: '
            '${e.response?.data ?? e.message}',
      );

      return null;
    } catch (e) {
      log('Update Project Error: $e');

      return null;
    }
  }

  Future<ProjectListResponseModel?> getProjects() async {
    try {
      log('Fetching projects...');

      final response = await dio.get(
        ApiEndpoints.getProject,
      );

      log('Get Projects Response: ${response.data}');

      return ProjectListResponseModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      log(
        'Get Projects DioException: '
            '${e.response?.data ?? e.message}',
      );

      return null;
    } catch (e) {
      log('Get Projects Error: $e');

      return null;
    }
  }
}