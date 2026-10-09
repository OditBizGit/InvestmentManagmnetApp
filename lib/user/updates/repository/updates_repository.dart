import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:maribel_wellness_centre_application/core/constants/api_endpoints.dart';
import 'package:maribel_wellness_centre_application/user/updates/model/work_update_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/model/work_updates_response_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';

class UpdatesRepository {
  UpdatesRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  List<WorkUpdateModel>? _cachedUpdates;

  List<WorkUpdateModel>? get cachedUpdates =>
      _cachedUpdates == null ? null : List.unmodifiable(_cachedUpdates!);

  Future<List<WorkUpdateModel>> getWorkUpdates({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedUpdates != null) {
      return List.unmodifiable(_cachedUpdates!);
    }

    try {
      final response = await _dio.get(ApiEndpoints.getWorkUpdates);
      final parsed = WorkUpdatesResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      final looksSuccessful = parsed.status ||
          parsed.code == 200 ||
          parsed.message.toLowerCase().contains('success');

      if (!looksSuccessful && parsed.data.isEmpty) {
        throw Exception(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to load work updates',
        );
      }

      _cachedUpdates = parsed.data;
      _precacheMedia(parsed.data);
      return List.unmodifiable(parsed.data);
    } on DioException catch (e) {
      log('Get Work Updates Error: ${e.message}');
      if (_cachedUpdates != null) {
        return List.unmodifiable(_cachedUpdates!);
      }
      rethrow;
    } catch (e) {
      log('Get Work Updates Error: $e');
      if (_cachedUpdates != null) {
        return List.unmodifiable(_cachedUpdates!);
      }
      rethrow;
    }
  }

  void _precacheMedia(List<WorkUpdateModel> updates) {
    for (final update in updates) {
      final url = update.resolvedFileUrl;
      if (url == null || url.isEmpty) continue;
      WorkUpdateMediaCache.precache(url, fileName: update.fileName);
    }
  }
}
