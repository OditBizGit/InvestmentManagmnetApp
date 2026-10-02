import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:path_provider/path_provider.dart';

enum StatusMediaSaveTarget {
  gallery,
  downloads,
  documents,
}

class StatusMediaSaveResult {
  const StatusMediaSaveResult({
    required this.target,
    required this.path,
  });

  final StatusMediaSaveTarget target;
  final String path;
}

/// Downloads status media (with auth) and saves it to the device gallery
/// when possible, otherwise to Downloads/Documents.
class StatusMediaDownload {
  StatusMediaDownload._();

  static Future<StatusMediaSaveResult> save({
    required String url,
    required bool isVideo,
    String? fileName,
    String? mimeType,
    void Function(double? progress)? onProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Saving media is not supported on web');
    }

    final extension = _resolveExtension(
      url: url,
      fileName: fileName,
      mimeType: mimeType,
      isVideo: isVideo,
    );
    final stampedName = _buildFileName(
      preferredName: fileName,
      url: url,
      extension: extension,
    );

    onProgress?.call(0);
    final localFile = await _downloadToTemp(
      url: url,
      stampedName: stampedName,
      onProgress: onProgress,
    );
    onProgress?.call(1);

    try {
      if (_supportsGallery) {
        try {
          await _saveToGallery(
            file: localFile,
            isVideo: isVideo,
            stampedName: stampedName,
          );
          return StatusMediaSaveResult(
            target: StatusMediaSaveTarget.gallery,
            path: stampedName,
          );
        } on GalleryPermissionDeniedException {
          rethrow;
        } catch (error, stack) {
          log(
            'Gallery save failed, falling back to files: $error',
            name: 'StatusMediaDownload',
            stackTrace: stack,
          );
        }
      }

      return await _saveToFiles(
        source: localFile,
        stampedName: stampedName,
      );
    } finally {
      try {
        if (await localFile.exists()) {
          await localFile.delete();
        }
      } catch (_) {}
    }
  }

  static bool get _supportsGallery {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows;
  }

  static Future<File> _downloadToTemp({
    required String url,
    required String stampedName,
    void Function(double? progress)? onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}${Platform.pathSeparator}status_dl_$stampedName';
    final partPath = '$path.part';

    var lastReportedPercent = -1;

    final response = await getIt<Dio>().download(
      url,
      partPath,
      options: Options(
        headers: const {
          'Accept': '*/*',
        },
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 2),
      ),
      onReceiveProgress: (received, total) {
        if (onProgress == null) return;
        if (total <= 0) {
          onProgress(null);
          return;
        }
        final percent = ((received / total) * 100).floor();
        if (percent == lastReportedPercent) return;
        lastReportedPercent = percent;
        onProgress((received / total).clamp(0.0, 1.0));
      },
    );

    final partFile = File(partPath);
    if (response.statusCode != 200 && response.statusCode != 206) {
      if (await partFile.exists()) await partFile.delete();
      throw StateError('Download failed with status ${response.statusCode}');
    }

    if (!await partFile.exists() || await partFile.length() <= 0) {
      throw StateError('Downloaded file is empty');
    }

    // Reject JSON/HTML error bodies that sometimes come back as 200.
    final size = await partFile.length();
    if (size < 2048) {
      final bytes = await partFile.readAsBytes();
      final preview = String.fromCharCodes(bytes.take(256)).trimLeft();
      if (preview.startsWith('{') ||
          preview.startsWith('<') ||
          preview.startsWith('[')) {
        await partFile.delete();
        throw StateError('Server returned an error payload instead of media');
      }
    }

    final out = File(path);
    if (await out.exists()) await out.delete();
    await partFile.rename(path);
    return out;
  }

  static Future<void> _saveToGallery({
    required File file,
    required bool isVideo,
    required String stampedName,
  }) async {
    Future<void> put() async {
      if (isVideo) {
        await Gal.putVideo(file.path);
      } else {
        // Bytes path avoids extension/MIME issues from temp filenames.
        final bytes = await file.readAsBytes();
        await Gal.putImageBytes(
          Uint8List.fromList(bytes),
          name: _nameWithoutExtension(stampedName),
        );
      }
    }

    try {
      await put();
      return;
    } on GalException catch (error) {
      if (error.type != GalExceptionType.accessDenied) {
        rethrow;
      }
    }

    final granted = await Gal.requestAccess();
    if (!granted) {
      throw const GalleryPermissionDeniedException();
    }
    await put();
  }

  static Future<StatusMediaSaveResult> _saveToFiles({
    required File source,
    required String stampedName,
  }) async {
    final directory = await _resolveDownloadsDirectory();
    final destination = File(
      '${directory.path}${Platform.pathSeparator}$stampedName',
    );
    await source.copy(destination.path);

    final isDownloads = directory.path.toLowerCase().contains('download');
    return StatusMediaSaveResult(
      target: isDownloads
          ? StatusMediaSaveTarget.downloads
          : StatusMediaSaveTarget.documents,
      path: destination.path,
    );
  }

  static Future<Directory> _resolveDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      try {
        if (await downloads.exists()) {
          final probe = File(
            '${downloads.path}/.maribel_status_write_probe',
          );
          await probe.writeAsString('ok');
          await probe.delete();
          return downloads;
        }
      } catch (_) {
        // Fall through when public Downloads is not writable.
      }
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        final downloads = Directory(
          '$home${Platform.pathSeparator}Downloads',
        );
        if (await downloads.exists()) {
          return downloads;
        }
      }
    }

    return getApplicationDocumentsDirectory();
  }

  static String _buildFileName({
    required String? preferredName,
    required String url,
    required String extension,
  }) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final base = _sanitizeBaseName(preferredName) ??
        _sanitizeBaseName(_basenameWithoutExtension(Uri.parse(url).path)) ??
        (_isVideoLikeExtension(extension) ? 'status_video' : 'status_image');
    return '${base}_$stamp.$extension';
  }

  static String _nameWithoutExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return fileName;
    return fileName.substring(0, dot);
  }

  static bool _isVideoLikeExtension(String extension) {
    return extension == 'mp4' ||
        extension == 'mov' ||
        extension == 'webm' ||
        extension == 'avi' ||
        extension == '3gp';
  }

  static String? _sanitizeBaseName(String? value) {
    if (value == null) return null;
    var name = value.trim();
    if (name.isEmpty) return null;

    name = _basenameWithoutExtension(name);
    name = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    name = name.replaceAll(RegExp(r'\s+'), '_');
    if (name.isEmpty) return null;
    if (name.length > 48) {
      name = name.substring(0, 48);
    }
    return name;
  }

  static String _basenameWithoutExtension(String pathOrName) {
    final normalized = pathOrName.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    final base = slash >= 0 ? normalized.substring(slash + 1) : normalized;
    final dot = base.lastIndexOf('.');
    if (dot <= 0) return base;
    return base.substring(0, dot);
  }

  static String _resolveExtension({
    required String url,
    required String? fileName,
    required String? mimeType,
    required bool isVideo,
  }) {
    final fromName = _extensionOf(fileName);
    if (fromName != null) return fromName;

    final fromUrl = _extensionOf(Uri.tryParse(url)?.path);
    if (fromUrl != null) return fromUrl;

    final mime = (mimeType ?? '').toLowerCase().trim();
    switch (mime) {
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      case 'image/heic':
      case 'image/heif':
        return 'heic';
      case 'video/mp4':
        return 'mp4';
      case 'video/quicktime':
        return 'mov';
      case 'video/webm':
        return 'webm';
      case 'video/x-msvideo':
        return 'avi';
      case 'video/3gpp':
        return '3gp';
    }

    return isVideo ? 'mp4' : 'jpg';
  }

  static String? _extensionOf(String? pathOrName) {
    if (pathOrName == null || pathOrName.isEmpty) return null;
    final normalized = pathOrName.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    final base = slash >= 0 ? normalized.substring(slash + 1) : normalized;
    final dot = base.lastIndexOf('.');
    if (dot < 0 || dot == base.length - 1) return null;
    final ext = base.substring(dot + 1).toLowerCase();
    if (ext.isEmpty) return null;
    if (ext.length > 5 || !RegExp(r'^[a-z0-9]+$').hasMatch(ext)) {
      return null;
    }
    return ext;
  }
}

class GalleryPermissionDeniedException implements Exception {
  const GalleryPermissionDeniedException();

  @override
  String toString() => 'Gallery permission denied';
}
