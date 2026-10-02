import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';

import '../model/add_work_status_model.dart';
import '../model/delete_work_status_model.dart';
import '../model/work_status_response_model.dart';

class AddWorkStatusRepository {
  final Dio dio = getIt<Dio>();

  Future<AddWorkStatusResponseModel?> addWorkStatus({
    required String title,
    required String description,
    required MultipartFile file,
  }) async {
    try {
      log('Adding work status...');
      log('Title: $title');
      log('Description: $description');
      log('File: ${file.filename}');

      final formData = FormData.fromMap({
        'Title': title,
        'Description': description,
        'File': file,
      });

      final response = await dio.post(
        ApiEndpoints.addWorkStatus,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      log('Add Work Status Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json;

        if (response.data is Map<String, dynamic>) {
          json = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          json = Map<String, dynamic>.from(
            response.data as Map,
          );
        } else {
          log(
            'Add Work Status failed: unexpected response type',
          );

          return AddWorkStatusResponseModel(
            status: false,
            message: 'Unexpected response received from server.',
            data: null,
            code: response.statusCode ?? 0,
          );
        }

        return AddWorkStatusResponseModel.fromJson(json);
      }

      log(
        'Add Work Status failed: '
        '${response.statusCode}',
      );

      return AddWorkStatusResponseModel(
        status: false,
        message:
            'Failed to add work status '
            '(${response.statusCode}). Please try again.',
        data: null,
        code: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      log(
        'Add Work Status Dio Error: ${e.message}',
      );

      log(
        'Add Work Status Response: ${e.response?.data}',
      );

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (responseData is Map) {
        final json = Map<String, dynamic>.from(
          responseData,
        );

        final model = AddWorkStatusResponseModel.fromJson(json);

        if (model.message.trim().isNotEmpty) {
          return model;
        }
      }

      final message = switch (statusCode) {
        400 =>
          'Invalid work status details. Please check your input.',
        401 || 403 =>
          'You are not authorized to add work status.',
        404 => 'Add work status endpoint was not found.',
        408 || 504 => 'Upload request timed out. Please try again.',
        413 => 'The selected file is too large to upload.',
        _ when e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout =>
          'Network error while uploading. Check your connection.',
        _ => 'Failed to add work status. Please try again.',
      };

      return AddWorkStatusResponseModel(
        status: false,
        message: message,
        data: null,
        code: statusCode ?? 0,
      );
    } catch (e) {
      log(
        'Add Work Status Error: $e',
      );

      return AddWorkStatusResponseModel(
        status: false,
        message:
            'Something went wrong while adding work status. '
            'Please try again.',
        data: null,
        code: 0,
      );
    }
  }

  Future<GetWorkStatusResponseModel?> getWorkStatus() async {
    try {
      log('Fetching work statuses...');

      final response = await dio.get(
        ApiEndpoints.getWorkStatus,
      );

      log('Get Work Status Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json;

        if (response.data is Map<String, dynamic>) {
          json = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          json = Map<String, dynamic>.from(response.data as Map);
        } else {
          return GetWorkStatusResponseModel(
            status: false,
            message: 'Unexpected response received from server.',
            data: [],
            code: response.statusCode ?? 0,
          );
        }

        return GetWorkStatusResponseModel.fromJson(json);
      }

      return GetWorkStatusResponseModel(
        status: false,
        message: 'Failed to fetch work statuses. Please try again.',
        data: [],
        code: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      log('Get Work Status Dio Error: ${e.message}');
      log('Get Work Status Response: ${e.response?.data}');

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (responseData is Map) {
        final model = GetWorkStatusResponseModel.fromJson(
          Map<String, dynamic>.from(responseData),
        );

        if (model.message.trim().isNotEmpty) {
          return model;
        }
      }

      final message = switch (statusCode) {
        401 || 403 => 'You are not authorized to view work statuses.',
        404 => 'Work status endpoint was not found.',
        408 || 504 => 'Request timed out. Please try again.',
        _ when e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout =>
          'Network error. Please check your connection.',
        _ => 'Failed to fetch work statuses. Please try again.',
      };

      return GetWorkStatusResponseModel(
        status: false,
        message: message,
        data: [],
        code: statusCode ?? 0,
      );
    } catch (e) {
      log('Get Work Status Error: $e');

      return GetWorkStatusResponseModel(
        status: false,
        message: 'Something went wrong while fetching work statuses.',
        data: [],
        code: 0,
      );
    }
  }

  Future<DeleteWorkStatusModel?> deleteWorkStatus({
    required int id,
  }) async {
    try {
      log('Deleting work status...');
      log('Work Status ID: $id');

      final response = await dio.delete(
        '${ApiEndpoints.deleteWorkStatus}$id',
      );

      log('Delete Work Status Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json;

        if (response.data is Map<String, dynamic>) {
          json = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          json = Map<String, dynamic>.from(
            response.data as Map,
          );
        } else {
          log(
            'Delete Work Status failed: unexpected response type',
          );
          return null;
        }

        return DeleteWorkStatusModel.fromJson(json);
      }

      log(
        'Delete Work Status failed: ${response.statusCode}',
      );

      return DeleteWorkStatusModel(
        status: false,
        message:
            'Failed to delete status media '
            '(${response.statusCode}). Please try again.',
        data: false,
        code: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      log('Delete Work Status Dio Error: ${e.message}');
      log('Delete Work Status Response: ${e.response?.data}');

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      if (responseData is Map) {
        final json = Map<String, dynamic>.from(responseData);
        final model = DeleteWorkStatusModel.fromJson(json);
        if (model.message.trim().isNotEmpty) {
          return model;
        }
      }

      final message = switch (statusCode) {
        404 =>
          'Delete endpoint was not found (404). '
              'Please verify the API is deployed.',
        401 || 403 => 'You are not authorized to delete this media.',
        400 => 'Invalid delete request. Please try again.',
        408 || 504 => 'Delete request timed out. Please try again.',
        _ when e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout =>
          'Network error while deleting. Check your connection.',
        _ => 'Failed to delete status media. Please try again.',
      };

      return DeleteWorkStatusModel(
        status: false,
        message: message,
        data: false,
        code: statusCode ?? 0,
      );
    } catch (e) {
      log('Delete Work Status Error: $e');
      return DeleteWorkStatusModel(
        status: false,
        message: 'Something went wrong while deleting. Please try again.',
        data: false,
        code: 0,
      );
    }
  }
}
