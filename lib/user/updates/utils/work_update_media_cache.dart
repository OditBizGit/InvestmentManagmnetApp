import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:path_provider/path_provider.dart';

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

  /// In-memory futures so concurrent callers share one Dio download per URL.
  static final Map<String, Future<File>> _videoDownloads = {};

  static CacheManager get manager => _manager;

  static Map<String, String> authHeaders() {
    final token = getIt<LocalStorage>().getAuthToken();
    return {
      'Accept': 'image/*,video/*,*/*',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Returns a local file for [url], downloading once and reusing afterward.
  /// Prefer [downloadVideoFile] for videos so the file keeps a playable extension.
  static Future<File> getFile(String url) {
    return _manager.getSingleFile(url, headers: authHeaders());
  }

  /// Downloads a video via Dio (same auth path as admin) and stores it with a
  /// real file extension so [VideoPlayer] / Windows Media Foundation can open it.
  static Future<File> downloadVideoFile({
    required String url,
    String? fileName,
    bool forceRedownload = false,
  }) {
    if (kIsWeb) {
      throw UnsupportedError('Local video download is not supported on web');
    }

    if (forceRedownload) {
      _videoDownloads.remove(url);
    } else {
      final cached = _videoDownloads[url];
      if (cached != null) return cached;
    }

    final future = _fetchVideoFile(
      url: url,
      fileName: fileName,
      forceRedownload: forceRedownload,
    );
    _videoDownloads[url] = future;
    future.then<void>(
      (_) {},
      onError: (Object _) => _videoDownloads.remove(url),
    );
    return future;
  }

  /// Deletes a previously downloaded video so the next call re-fetches it.
  static Future<void> invalidateVideoFile({
    required String url,
    String? fileName,
  }) async {
    _videoDownloads.remove(url);
    if (kIsWeb) return;

    try {
      final path = await _videoCachePath(url: url, fileName: fileName);
      final file = File(path);
      final part = File('$path.part');
      if (await file.exists()) await file.delete();
      if (await part.exists()) await part.delete();
    } catch (e) {
      log('WorkUpdateMediaCache invalidate failed: $e');
    }
  }

  static Future<String> _videoCachePath({
    required String url,
    String? fileName,
  }) async {
    final extension = _resolveVideoExtension(fileName, url);
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}${Platform.pathSeparator}work_update_'
        '${_stableUrlKey(url)}$extension';
  }

  static Future<File> _fetchVideoFile({
    required String url,
    String? fileName,
    bool forceRedownload = false,
  }) async {
    final path = await _videoCachePath(url: url, fileName: fileName);
    final file = File(path);

    if (!forceRedownload &&
        await file.exists() &&
        await _isLikelyValidVideoFile(file)) {
      return file;
    }

    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    final partPath = '$path.part';
    final partFile = File(partPath);
    if (await partFile.exists()) {
      try {
        await partFile.delete();
      } catch (_) {}
    }

    final response = await getIt<Dio>().download(
      url,
      partPath,
      options: Options(
        // Override Dio's default JSON content-type for binary media.
        contentType: 'application/octet-stream',
        headers: {
          ...authHeaders(),
          'Accept': '*/*',
        },
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 2),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 206) {
      if (await partFile.exists()) await partFile.delete();
      throw StateError(
        'Video download failed with status ${response.statusCode}',
      );
    }

    final exists = await partFile.exists();
    final size = exists ? await partFile.length() : 0;
    if (!exists || size <= 0) {
      throw StateError('Downloaded video file is missing or empty');
    }

    if (!await _isLikelyValidVideoFile(partFile)) {
      final head = await _readFileHead(partFile, 120);
      await partFile.delete();
      throw StateError(
        'Server did not return a video file. Head: $head',
      );
    }

    if (await file.exists()) {
      await file.delete();
    }
    await partFile.rename(path);
    return File(path);
  }

  static Future<bool> _isLikelyValidVideoFile(File file) async {
    try {
      final length = await file.length();
      if (length < 64) return false;

      final raf = await file.open();
      try {
        final header = await raf.read(32);
        return _headerLooksLikeVideo(header);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  static bool _headerLooksLikeVideo(List<int> header) {
    if (header.length < 8) return false;

    final asText = String.fromCharCodes(
      header.take(32).where((b) => b >= 9 && b < 127),
    ).trimLeft();
    if (asText.startsWith('{') ||
        asText.startsWith('<') ||
        asText.toLowerCase().startsWith('<!doctype') ||
        asText.toLowerCase().startsWith('http/')) {
      return false;
    }

    // ISO BMFF (mp4 / mov / m4v): ....ftyp
    if (header.length >= 8) {
      final brand = String.fromCharCodes(header.sublist(4, 8));
      if (brand == 'ftyp') return true;
    }

    // WebM / Matroska
    if (header.length >= 4 &&
        header[0] == 0x1A &&
        header[1] == 0x45 &&
        header[2] == 0xDF &&
        header[3] == 0xA3) {
      return true;
    }

    // RIFF (AVI / WAV container used by some cameras)
    if (header.length >= 4 &&
        String.fromCharCodes(header.sublist(0, 4)) == 'RIFF') {
      return true;
    }

    // MPEG-TS
    if (header[0] == 0x47) return true;

    // Unknown binary that is not an obvious error payload — allow playback attempt.
    var nonPrintable = 0;
    for (final b in header.take(16)) {
      if (b < 9 || (b > 13 && b < 32)) nonPrintable++;
    }
    return nonPrintable >= 2;
  }

  static Future<String> _readFileHead(File file, int maxChars) async {
    try {
      final raf = await file.open();
      try {
        final bytes = await raf.read(maxChars);
        return String.fromCharCodes(bytes);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return '';
    }
  }

  static String _stableUrlKey(String url) {
    // Avoid Dart hashCode collisions across sessions by mixing length + hash.
    return '${url.length}_${url.hashCode.toUnsigned(32)}';
  }

  static String _resolveVideoExtension(String? fileName, String url) {
    final fromName = _extensionOf(fileName);
    if (fromName != null) return fromName;

    try {
      final path = Uri.parse(url).path;
      final fromUrl = _extensionOf(path.split('/').last);
      if (fromUrl != null) return fromUrl;
    } catch (_) {}

    return '.mp4';
  }

  static String? _extensionOf(String? name) {
    if (name == null) return null;
    final trimmed = name.trim().toLowerCase();
    if (!trimmed.contains('.')) return null;
    final ext = trimmed.split('.').last;
    if (ext.isEmpty || ext.length > 5) return null;
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(ext)) return null;
    return '.$ext';
  }

  static Future<void> precache(String url, {String? fileName}) async {
    try {
      final looksLikeVideo = _looksLikeVideo(url, fileName);
      if (!kIsWeb && looksLikeVideo) {
        await downloadVideoFile(url: url, fileName: fileName);
      } else {
        await getFile(url);
      }
    } catch (e) {
      log('WorkUpdateMediaCache precache failed: $e');
    }
  }

  static bool _looksLikeVideo(String url, String? fileName) {
    final name = (fileName ?? url).toLowerCase();
    return name.contains('.mp4') ||
        name.contains('.mov') ||
        name.contains('.webm') ||
        name.contains('.mkv') ||
        name.contains('.avi') ||
        name.contains('video');
  }
}

/// Serializes native video player initialization so a list of cards does not
/// overwhelm MediaCodec / Media Foundation (a common cause of partial failures).
class WorkUpdateVideoInitGate {
  WorkUpdateVideoInitGate._();

  static Future<void> _tail = Future<void>.value();

  static Future<T> run<T>(Future<T> Function() action) {
    final previous = _tail;
    final gate = Completer<void>();
    _tail = gate.future;

    return previous.catchError((_) {}).then((_) async {
      try {
        return await action();
      } finally {
        if (!gate.isCompleted) gate.complete();
      }
    });
  }
}
