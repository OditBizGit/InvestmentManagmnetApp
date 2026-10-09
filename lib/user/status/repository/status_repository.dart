import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/status/model/work_status_model.dart';
import 'package:maribel_wellness_centre_application/user/status/model/work_status_response_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';

class StatusRepository {
  StatusRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  List<WorkStatusModel>? _cachedStatuses;

  List<WorkStatusModel>? get cachedStatuses =>
      _cachedStatuses == null ? null : List.unmodifiable(_cachedStatuses!);

  Future<List<WorkStatusModel>> getWorkStatus({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedStatuses != null) {
      return List.unmodifiable(_cachedStatuses!);
    }

    try {
      final response = await _dio.get(ApiEndpoints.getWorkStatus);
      final parsed = WorkStatusResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load work statuses',
        );
      }

      _cachedStatuses = parsed.data;
      _precacheMedia(parsed.data);
      return List.unmodifiable(parsed.data);
    } on DioException catch (e) {
      log('Get Work Status Error: ${e.message}');
      if (_cachedStatuses != null) {
        return List.unmodifiable(_cachedStatuses!);
      }
      rethrow;
    } catch (e) {
      log('Get Work Status Error: $e');
      if (_cachedStatuses != null) {
        return List.unmodifiable(_cachedStatuses!);
      }
      rethrow;
    }
  }

  void _precacheMedia(List<WorkStatusModel> statuses) {
    for (final item in statuses) {
      final url = item.resolvedFileUrl;
      if (url == null || url.isEmpty) continue;
      WorkUpdateMediaCache.precache(url, fileName: item.fileName);
    }
  }
}
