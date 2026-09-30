import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/add_work_update_response_model.dart';
import '../model/delete_work_update_model.dart';
import '../model/get_work_updates_model.dart';

class WorkUpdateRepository {
  final Dio dio;

  WorkUpdateRepository({required this.dio});

  Future<AddWorkUpdateModel?> addWorkUpdate({
    required String title,
    required String description,
    required MultipartFile file,
  }) async {
    try {
      final endpoint = ApiEndpoints.workUpdate;

      final formData = FormData.fromMap({
        'Title': title,
        'Description': description,
        'File': file,
      });

      log('========== ADD WORK UPDATE START ==========');
      log('Endpoint: $endpoint');
      log('Title: $title');
      log('Description: $description');
      log('File: ${file.filename}');
      log('File FormData fields: ${formData.fields}');

      final response = await dio.post(endpoint, data: formData);

      log('Add Work Update Status Code: ${response.statusCode}');
      log('Add Work Update Response: ${response.data}');

      if (response.data == null) {
        log('Add Work Update failed: response data is null');
        log('========== ADD WORK UPDATE END (NULL DATA) ==========');
        return null;
      }

      final Map<String, dynamic> json;

      if (response.data is Map<String, dynamic>) {
        json = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        json = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        log('Add Work Update: response is String, decoding JSON...');

        final decoded = jsonDecode(response.data as String);

        if (decoded is! Map) {
          log(
            'Add Work Update failed: '
            'decoded string is not a Map',
          );
          log(
            '========== ADD WORK UPDATE END '
            '(BAD STRING JSON) ==========',
          );
          return null;
        }

        json = Map<String, dynamic>.from(decoded);
      } else {
        log(
          'Add Work Update failed: unexpected response type '
          '${response.data.runtimeType}',
        );
        log(
          '========== ADD WORK UPDATE END '
          '(BAD TYPE) ==========',
        );
        return null;
      }

      final model = AddWorkUpdateModel.fromJson(json);

      final statusOk = response.statusCode == 200 || response.statusCode == 201;

      if (!statusOk) {
        log(
          'Add Work Update failed with status code: '
          '${response.statusCode}',
        );
        return null;
      }

      log(
        'Add Work Update Success: '
        '${model.message}',
      );

      if (model.data != null) {
        log(
          'Work Update ID: '
          '${model.data!.workUpdateId}',
        );
        log(
          'Google Drive File ID: '
          '${model.data!.googleDriveFileId}',
        );
        log(
          'File Type: '
          '${model.data!.fileType}',
        );
      }

      log('========== ADD WORK UPDATE END ==========');

      return model;
    } on DioException catch (e) {
      log(
        'Add Work Update Dio Error: '
        '${e.message}',
      );
      log(
        'Add Work Update Response: '
        '${e.response?.data}',
      );

      return null;
    } catch (e) {
      log('Add Work Update Error: $e');
      return null;
    }
  }

  Future<GetWorkUpdatesModel?> getWorkUpdates() async {
    try {
      log('Fetching work updates...');

      final response = await dio.get(
        ApiEndpoints.getWorkUpdates,
      );

      log('Get Work Updates Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return GetWorkUpdatesModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      log(
        'Get Work Updates failed: ${response.statusCode}',
      );

      return null;
    } on DioException catch (e) {
      log('Get Work Updates Dio Error: ${e.message}');
      log('Get Work Updates Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('Get Work Updates Error: $e');
      return null;
    }
  }

  Future<DeleteWorkUpdateModel?> deleteWorkUpdate({
    required int id,
  }) async {
    try {
      log('Deleting work update...');
      log('Work Update ID: $id');

      final response = await dio.delete(
        '${ApiEndpoints.deleteWorkUpdate}$id',
      );

      log('Delete Work Update Response: ${response.data}');

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
            'Delete Work Update failed: '
                'unexpected response type',
          );
          return null;
        }

        final model = DeleteWorkUpdateModel.fromJson(json);

        return model;
      }

      log(
        'Delete Work Update failed: '
            '${response.statusCode}',
      );

      return DeleteWorkUpdateModel(
        status: false,
        message:
            'Failed to delete construction media '
            '(${response.statusCode}). Please try again.',
        data: false,
        code: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      log(
        'Delete Work Update Dio Error: '
            '${e.message}',
      );

      log(
        'Delete Work Update Response: '
            '${e.response?.data}',
      );

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      if (responseData is Map) {
        final json = Map<String, dynamic>.from(responseData);
        final model = DeleteWorkUpdateModel.fromJson(json);
        if (model.message.trim().isNotEmpty) {
          return model;
        }
      }

      final message = switch (statusCode) {
        404 =>
          'Delete endpoint was not found (404). '
              'Please verify the API is deployed.',
        401 || 403 =>
          'You are not authorized to delete this media.',
        400 => 'Invalid delete request. Please try again.',
        408 || 504 => 'Delete request timed out. Please try again.',
        _ when e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout =>
          'Network error while deleting. Check your connection.',
        _ =>
          'Failed to delete construction media. Please try again.',
      };

      return DeleteWorkUpdateModel(
        status: false,
        message: message,
        data: false,
        code: statusCode ?? 0,
      );
    } catch (e) {
      log('Delete Work Update Error: $e');
      return DeleteWorkUpdateModel(
        status: false,
        message: 'Something went wrong while deleting. Please try again.',
        data: false,
        code: 0,
      );
    }
  }
}
