import 'package:maribel_wellness_centre_application/core/utils/app_log.dart';
import 'dart:convert';

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

      appLog('========== ADD WORK UPDATE START ==========');
      appLog('Endpoint: $endpoint');
      appLog('Title: $title');
      appLog('Description: $description');
      appLog('File: ${file.filename}');
      appLog('File FormData field names: ${formData.fields.map((f) => f.key)}');

      final response = await dio.post(endpoint, data: formData);

      appLog('Add Work Update Status Code: ${response.statusCode}');

      if (response.data == null) {
        appLog('Add Work Update failed: response data is null');
        appLog('========== ADD WORK UPDATE END (NULL DATA) ==========');
        return null;
      }

      final Map<String, dynamic> json;

      if (response.data is Map<String, dynamic>) {
        json = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        json = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        appLog('Add Work Update: response is String, decoding JSON...');

        final decoded = jsonDecode(response.data as String);

        if (decoded is! Map) {
          appLog(
            'Add Work Update failed: '
            'decoded string is not a Map',
          );
          appLog(
            '========== ADD WORK UPDATE END '
            '(BAD STRING JSON) ==========',
          );
          return null;
        }

        json = Map<String, dynamic>.from(decoded);
      } else {
        appLog(
          'Add Work Update failed: unexpected response type '
          '${response.data.runtimeType}',
        );
        appLog(
          '========== ADD WORK UPDATE END '
          '(BAD TYPE) ==========',
        );
        return null;
      }

      final model = AddWorkUpdateModel.fromJson(json);

      final statusOk = response.statusCode == 200 || response.statusCode == 201;

      if (!statusOk) {
        appLog(
          'Add Work Update failed with status code: '
          '${response.statusCode}',
        );
        return null;
      }

      appLog(
        'Add Work Update Success: '
        '${model.message}',
      );

      if (model.data != null) {
        appLog(
          'Work Update ID: '
          '${model.data!.workUpdateId}',
        );
        appLog(
          'Google Drive File ID: '
          '${model.data!.googleDriveFileId}',
        );
        appLog(
          'File Type: '
          '${model.data!.fileType}',
        );
      }

      appLog('========== ADD WORK UPDATE END ==========');

      return model;
    } on DioException catch (e) {
      appLog(
        'Add Work Update Dio Error: '
        '${e.message}',
      );

      return null;
    } catch (e) {
      appLog('Add Work Update Error: $e');
      return null;
    }
  }

  Future<GetWorkUpdatesModel?> getWorkUpdates() async {
    try {
      appLog('Fetching work updates...');

      final response = await dio.get(
        ApiEndpoints.getWorkUpdates,
      );


      if (response.statusCode == 200 && response.data != null) {
        return GetWorkUpdatesModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      appLog(
        'Get Work Updates failed: ${response.statusCode}',
      );

      return null;
    } on DioException catch (e) {
      appLog('Get Work Updates Dio Error: ${e.message}');
      return null;
    } catch (e) {
      appLog('Get Work Updates Error: $e');
      return null;
    }
  }

  Future<DeleteWorkUpdateModel?> deleteWorkUpdate({
    required int id,
  }) async {
    try {
      appLog('Deleting work update...');
      appLog('Work Update ID: $id');

      final response = await dio.delete(
        '${ApiEndpoints.deleteWorkUpdate}$id',
      );


      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json;

        if (response.data is Map<String, dynamic>) {
          json = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          json = Map<String, dynamic>.from(
            response.data as Map,
          );
        } else {
          appLog(
            'Delete Work Update failed: '
                'unexpected response type',
          );
          return null;
        }

        final model = DeleteWorkUpdateModel.fromJson(json);

        return model;
      }

      appLog(
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
      appLog(
        'Delete Work Update Dio Error: '
            '${e.message}',
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
      appLog('Delete Work Update Error: $e');
      return DeleteWorkUpdateModel(
        status: false,
        message: 'Something went wrong while deleting. Please try again.',
        data: false,
        code: 0,
      );
    }
  }
}
