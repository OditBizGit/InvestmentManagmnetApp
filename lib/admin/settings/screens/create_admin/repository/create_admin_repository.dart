import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';

import '../model/create_admin_model.dart';

class CreateAdminResult {
  const CreateAdminResult({
    required this.message,
    this.data,
  });

  final String message;
  final CreateAdminModel? data;
}

class CreateAdminRepository {
  CreateAdminRepository({
    required this.dio,
  });

  final Dio dio;

  Future<CreateAdminResult> createAdmin(CreateAdminModel request) async {
    try {
      log('Creating admin...');
      log('Request: ${request.toJson()}');

      final response = await dio.post(
        ApiEndpoints.createAdmin,
        data: request.toJson(),
      );

      log('Create Admin Response: ${response.data}');

      final body = response.data;
      if (body is! Map) {
        throw Exception('Invalid response from server');
      }

      final message = _readMessage(body);
      final status = _readStatus(body, response.statusCode);
      final rawData = body['data'] ?? body['Data'];

      if (!status) {
        throw Exception(
          message.isNotEmpty ? message : 'Failed to create admin',
        );
      }

      CreateAdminModel? data;
      if (rawData is Map<String, dynamic>) {
        data = CreateAdminModel.fromJson(rawData);
      } else if (rawData is Map) {
        data = CreateAdminModel.fromJson(
          Map<String, dynamic>.from(rawData),
        );
      }

      return CreateAdminResult(
        message: message.isNotEmpty
            ? message
            : 'Admin created successfully',
        data: data,
      );
    } on DioException catch (e) {
      log('Create Admin Dio Error: ${e.message}');
      log('Create Admin Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Create Admin Error: $e');
      rethrow;
    }
  }

  bool _readStatus(Map body, int? statusCode) {
    final raw = body['status'] ?? body['Status'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1 || raw == 200;
    if (raw is String) {
      final value = raw.trim().toLowerCase();
      if (value == 'true' || value == '1' || value == 'success') {
        return true;
      }
      if (value == 'false' || value == '0' || value == 'failed') {
        return false;
      }
    }

    final code = body['code'] ?? body['Code'] ?? statusCode;
    if (code is num) return code == 200;
    return statusCode == 200;
  }

  String _readMessage(Map body) {
    final message = body['message'] ?? body['Message'];
    if (message is String) return message.trim();
    return '';
  }
}
