import 'dart:developer';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';

/// Disk cache for work-update media (images / videos) with auth headers.
class WorkUpdateMediaCache {
  WorkUpdateMediaCache._();

  static final CacheManager _manager = CacheManager(
    Config(
      'workUpdateMediaCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 80,
    ),
  );

  static CacheManager get manager => _manager;

  static Map<String, String> authHeaders() {
    final token = getIt<LocalStorage>().getAuthToken();
    return {
      'Accept': '*/*',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Returns a local file for [url], downloading once and reusing afterward.
  static Future<File> getFile(String url) {
    return _manager.getSingleFile(url, headers: authHeaders());
  }

  static Future<void> precache(String url) async {
    try {
      await getFile(url);
    } catch (e) {
      log('WorkUpdateMediaCache precache failed: $e');
    }
  }
}
