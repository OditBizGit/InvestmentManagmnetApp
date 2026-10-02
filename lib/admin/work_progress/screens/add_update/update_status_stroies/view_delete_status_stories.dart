import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_status_stroies/cubit/update_status_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_status_stroies/model/add_work_status_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/windows_video_play_support/win_video_support.dart';

/// Downloaded video files keyed by URL, shared by the grid thumbnails and
/// the preview dialog so each video is only fetched once per session.
final Map<String, Future<String>> _videoFileCache = {};

String _resolveVideoExtension(String fileName) {
  final name = fileName.trim().toLowerCase();
  if (name.contains('.')) {
    final ext = name.split('.').last;
    if (ext.isNotEmpty && ext.length <= 5) return '.$ext';
  }
  return '.mp4';
}

Future<String> _downloadVideoFile({
  required String url,
  required String fileName,
  Map<String, String>? headers,
  void Function(String message)? onLog,
}) {
  final cached = _videoFileCache[url];
  if (cached != null) return cached;

  final future = _fetchVideoFile(
    url: url,
    fileName: fileName,
    headers: headers,
    onLog: onLog ?? (_) {},
  );
  _videoFileCache[url] = future;
  future.then<void>(
    (_) {},
    onError: (Object _) => _videoFileCache.remove(url),
  );
  return future;
}

Future<String> _fetchVideoFile({
  required String url,
  required String fileName,
  required Map<String, String>? headers,
  required void Function(String message) onLog,
}) async {
  final extension = _resolveVideoExtension(fileName);
  onLog('Downloading video for local playback');
  onLog('URL: $url');
  onLog('File name: $fileName');
  onLog('Extension: $extension');
  onLog('Auth headers present: ${headers != null}');

  final tempDir = await getTemporaryDirectory();
  final path = '${tempDir.path}${Platform.pathSeparator}work_status_'
      '${url.hashCode.toUnsigned(32)}$extension';
  final file = File(path);

  if (await file.exists() && await file.length() > 2048) {
    onLog('Reusing downloaded video: $path');
    return path;
  }

  final partPath = '$path.part';
  onLog('Download target path: $path');

  final response = await getIt<Dio>().download(
    url,
    partPath,
    options: Options(
      headers: {
        ...?headers,
        'Accept': '*/*',
      },
      responseType: ResponseType.bytes,
      followRedirects: true,
      validateStatus: (status) => status != null && status < 500,
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 2),
    ),
    onReceiveProgress: (received, total) {
      if (total > 0 && received % (512 * 1024) < 8192) {
        final pct = ((received / total) * 100).toStringAsFixed(1);
        onLog('Download progress: $pct% ($received / $total bytes)');
      }
    },
  );

  onLog('Download status code: ${response.statusCode}');
  onLog('Download content-type: ${response.headers.value('content-type')}');
  onLog('Download content-length: ${response.headers.value('content-length')}');

  final partFile = File(partPath);
  if (response.statusCode != 200 && response.statusCode != 206) {
    if (await partFile.exists()) await partFile.delete();
    throw StateError(
      'Video download failed with status ${response.statusCode}',
    );
  }

  final exists = await partFile.exists();
  final size = exists ? await partFile.length() : 0;
  onLog('Temp file exists: $exists, size: $size bytes');

  if (!exists || size <= 0) {
    throw StateError('Downloaded video file is missing or empty at $path');
  }

  if (size < 2048) {
    final bytes = await partFile.readAsBytes();
    final preview = String.fromCharCodes(bytes.take(256));
    onLog('Small file head preview: $preview');
    if (preview.trimLeft().startsWith('{') ||
        preview.trimLeft().startsWith('<')) {
      await partFile.delete();
      throw StateError(
        'Server did not return a video file. Response preview: '
        '${preview.length > 120 ? preview.substring(0, 120) : preview}',
      );
    }
  }

  await partFile.rename(path);
  return path;
}

class ViewDeleteStatusStories extends StatefulWidget {
  const ViewDeleteStatusStories({super.key});

  @override
  State<ViewDeleteStatusStories> createState() =>
      _ViewDeleteStatusStoriesState();
}

class _ViewDeleteStatusStoriesState
    extends State<ViewDeleteStatusStories> {
  Map<String, String>? _mediaHeaders;

  @override
  void initState() {
    super.initState();
    _mediaHeaders = _buildMediaHeaders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UpdateStatusCubit>().fetchWorkStatusIfNeeded();
    });
  }

  Map<String, String>? _buildMediaHeaders() {
    final token = getIt<LocalStorage>().getAuthToken();
    if (token == null || token.trim().isEmpty) return null;
    return {
      'Authorization': 'Bearer ${token.trim()}',

      'Accept': 'image/*,video/*,*/*',
    };
  }

  Future<void> _confirmDelete(WorkStatusModel item) async {
    final isVideo = item.isVideo;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVideo ? 'Delete Video' : 'Delete Photo',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Delete "${item.title}"? This cannot be undone.',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context.read<UpdateStatusCubit>().deleteWorkStatus(
          workStatusId: item.workStatusId,
        );
  }

  void _previewItem(WorkStatusModel item) {
    final url = item.mediaPreviewUrl;

    if (url == null || url.isEmpty) {
      AppToast.error(
        'Preview is not available for this file.',
        context: context,
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return _MediaPreviewDialog(
          title: item.title.isNotEmpty ? item.title : item.fileName,
          fileName: item.fileName,
          isVideo: item.isVideo,
          url: url,
          headers: _mediaHeaders,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateStatusCubit, UpdateStatusState>(
      listenWhen: (previous, current) =>
          current is GetWorkStatusError ||
          current is DeleteWorkStatusSuccess ||
          current is DeleteWorkStatusError,
      listener: (context, state) {
        if (state is GetWorkStatusError) {
          AppToast.error(state.message, context: context);
        } else if (state is DeleteWorkStatusSuccess) {
          AppToast.success(state.message, context: context);
        } else if (state is DeleteWorkStatusError) {
          AppToast.error(state.message, context: context);
        }
      },
      buildWhen: (previous, current) =>
          current is GetWorkStatusLoading ||
          current is GetWorkStatusSuccess ||
          current is GetWorkStatusError ||
          current is DeleteWorkStatusLoading ||
          current is DeleteWorkStatusSuccess ||
          current is DeleteWorkStatusError ||
          current is UpdateStatusInitial,
      builder: (context, state) {
        final cubit = context.read<UpdateStatusCubit>();
        final updates = state is GetWorkStatusSuccess
            ? state.workStatuses
            : cubit.workStatuses;
        final isFetching = state is GetWorkStatusLoading;
        final deletingWorkStatusId =
            state is DeleteWorkStatusLoading ? state.workStatusId : null;

        if (isFetching && updates.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
          );
        }

        if (state is GetWorkStatusError && updates.isEmpty) {
          return _ErrorStatusStoriesState(
            message: state.message,
            onRetry: () =>
                context.read<UpdateStatusCubit>().fetchWorkStatus(),
          );
        }

        if (updates.isEmpty) {
          return _EmptyStatusStoriesState(
            onRefresh: () =>
                context.read<UpdateStatusCubit>().fetchWorkStatus(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'All Uploads',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (isFetching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                else
                  InkWell(
                    onTap: deletingWorkStatusId != null
                        ? null
                        : () => context
                            .read<UpdateStatusCubit>()
                            .fetchWorkStatus(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: deletingWorkStatusId != null
                                ? AppColors.textMuted
                                : AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: deletingWorkStatusId != null
                                  ? AppColors.textMuted
                                  : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720
                    ? 3
                    : constraints.maxWidth >= 420
                        ? 2
                        : 1;
                const spacing = 12.0;
                final itemWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final item in updates)
                      SizedBox(
                        key: ValueKey(item.workStatusId),
                        width: itemWidth,
                        child: _StatusStoriesMediaCard(
                          item: item,
                          isVideo: item.isVideo,
                          previewUrl: item.mediaPreviewUrl,
                          mediaHeaders: _mediaHeaders,
                          isDeleting:
                              deletingWorkStatusId == item.workStatusId,
                          enabled: deletingWorkStatusId == null,
                          onView: () => _previewItem(item),
                          onDelete: () => _confirmDelete(item),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _EmptyStatusStoriesState extends StatelessWidget {
  const _EmptyStatusStoriesState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 36,
            color: AppColors.textMuted.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'No status media uploaded yet',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Switch to Add to upload your first status photo or video',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRefresh,
            child: Text(
              'Refresh',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorStatusStoriesState extends StatelessWidget {
  const _ErrorStatusStoriesState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load status media',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Try again',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStoriesMediaCard extends StatelessWidget {
  const _StatusStoriesMediaCard({
    required this.item,
    required this.isVideo,
    required this.previewUrl,
    required this.mediaHeaders,
    required this.isDeleting,
    required this.enabled,
    required this.onView,
    required this.onDelete,
  });

  final WorkStatusModel item;
  final bool isVideo;
  final String? previewUrl;
  final Map<String, String>? mediaHeaders;
  final bool isDeleting;
  final bool enabled;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo) ...[
                  if (previewUrl != null)
                    _VideoThumbnail(
                      url: previewUrl!,
                      fileName: item.fileName,
                      headers: mediaHeaders,
                    )
                  else
                    const ColoredBox(color: Color(0xFFFFF3E8)),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 42,
                      color: Color(0xFFE89A3C),
                    ),
                  ),
                ] else if (previewUrl != null)
                  Image.network(
                    previewUrl!,
                    fit: BoxFit.cover,
                    headers: mediaHeaders,
                    errorBuilder: (_, error, stackTrace) => const ColoredBox(
                      color: Color(0xFFF0EEF3),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const ColoredBox(
                        color: Color(0xFFF0EEF3),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  const ColoredBox(
                    color: Color(0xFFF0EEF3),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onView),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: AppColors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: onView,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: InkWell(
                      onTap: enabled && !isDeleting ? onDelete : null,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: enabled
                                    ? AppColors.error
                                    : AppColors.textMuted,
                              ),
                      ),
                    ),
                  ),
                ),
                if (isVideo)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Video',
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.isNotEmpty ? item.title : item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : item.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the first frame of a video as a card thumbnail.
class _VideoThumbnail extends StatefulWidget {
  const _VideoThumbnail({
    required this.url,
    required this.fileName,
    required this.headers,
  });

  final String url;
  final String fileName;
  final Map<String, String>? headers;

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  static const _placeholder = ColoredBox(color: Color(0xFFFFF3E8));

  VideoPlayerController? _controller;
  String? _winFilePath;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (kIsWeb) {
        await _initController(
          VideoPlayerController.networkUrl(
            Uri.parse(widget.url),
            httpHeaders: widget.headers ?? const <String, String>{},
          ),
        );
        return;
      }

      final path = await _downloadVideoFile(
        url: widget.url,
        fileName: widget.fileName,
        headers: widget.headers,
      );
      if (!mounted) return;

      if (supportsWinVideoPlayer) {
        setState(() => _winFilePath = path);
        return;
      }

      await _initController(VideoPlayerController.file(File(path)));
    } catch (e) {
      log('Thumbnail failed for ${widget.url}: $e', name: 'WorkStatusThumb');
    }
  }

  Future<void> _initController(VideoPlayerController controller) async {
    if (!mounted) {
      controller.dispose();
      return;
    }
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || !identical(_controller, controller)) return;
      await controller.setVolume(0);
      if (!mounted || !identical(_controller, controller)) return;
      await controller.seekTo(Duration.zero);
      if (!mounted ||
          !identical(_controller, controller) ||
          controller.value.hasError) {
        return;
      }
      setState(() => _ready = true);
    } catch (_) {
      // Widget may have been disposed mid-init during list updates.
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winPath = _winFilePath;
    if (winPath != null) {
      return WinVideoThumbnail(filePath: winPath, placeholder: _placeholder);
    }

    final controller = _controller;
    if (!_ready || controller == null) return _placeholder;

    final size = controller.value.size;
    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width == 0 ? 16 : size.width,
          height: size.height == 0 ? 9 : size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _MediaPreviewDialog extends StatelessWidget {
  const _MediaPreviewDialog({
    required this.title,
    required this.fileName,
    required this.isVideo,
    required this.url,
    required this.headers,
  });

  final String title;
  final String fileName;
  final bool isVideo;
  final String url;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: AppColors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: const Color(0xFF1C1C1C),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: isVideo
                      ? _NetworkVideoPlayer(
                          url: url,
                          headers: headers,
                          fileName: fileName,
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.contain,
                          headers: headers,
                          errorBuilder: (_, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkVideoPlayer extends StatefulWidget {
  const _NetworkVideoPlayer({
    required this.url,
    required this.headers,
    required this.fileName,
  });

  final String url;
  final Map<String, String>? headers;
  final String fileName;

  @override
  State<_NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<_NetworkVideoPlayer> {
  static const String _logTag = 'WorkStatusVideoPlayer';

  VideoPlayerController? _controller;
  String? _tempFilePath;
  bool _started = false;
  bool _initializing = true;
  bool _hasError = false;
  bool _openedExternally = false;
  bool _useWinPlayer = false;
  String? _errorMessage;
  String? _debugDetail;

  void _log(String message) {
    log(message, name: _logTag);
    if (kDebugMode) {
      debugPrint('[$_logTag] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    if (_started) {
      _log('initState skipped — already started');
      return;
    }
    _started = true;
    _log('initState → starting video initialize');
    _initialize();
  }

  Future<bool> _openWithSystemPlayer(String path) async {
    _log('Fallback: opening with system player → $path');
    final result = await OpenFilex.open(path);
    _log(
      'OpenFilex result type=${result.type}, message=${result.message}',
    );
    return result.type == ResultType.done;
  }

  Future<void> _initialize() async {
    _log('========== VIDEO INIT START ==========');
    _log('Platform web: $kIsWeb');
    _log('supportsWinVideoPlayer: $supportsWinVideoPlayer');
    _log('DefaultTargetPlatform: $defaultTargetPlatform');

    try {
      // Chrome/web: stream with auth headers (already works).
      if (kIsWeb) {
        _log('Web path: VideoPlayerController.networkUrl');
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
          httpHeaders: widget.headers ?? const <String, String>{},
        );
        _controller = controller;
        await controller.initialize();
        await controller.setLooping(true);
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _hasError = false;
        });
        await controller.play();
        _log('========== VIDEO INIT END (WEB SUCCESS) ==========');
        return;
      }

      // Desktop/mobile: download first (auth via Dio).
      final path = await _downloadVideoFile(
        url: widget.url,
        fileName: widget.fileName,
        headers: widget.headers,
        onLog: _log,
      );
      _tempFilePath = path;

      // Windows: use dedicated WinVideoPlayerController (Media Foundation).
      if (supportsWinVideoPlayer) {
        _log('Windows path: switching UI to WinLocalVideoPlayer');
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _hasError = false;
          _useWinPlayer = true;
        });
        return;
      }

      // Android / iOS / macOS / Linux with video_player support.
      _log('Non-Windows IO path: VideoPlayerController.file');
      final controller = VideoPlayerController.file(File(path));
      _controller = controller;
      await controller.initialize();
      if (controller.value.hasError) {
        throw StateError(
          controller.value.errorDescription ??
              'VideoPlayer reported hasError=true after initialize',
        );
      }
      await controller.setLooping(true);
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hasError = false;
      });
      await controller.play();
      _log('========== VIDEO INIT END (SUCCESS) ==========');
    } catch (e, stackTrace) {
      _log('========== VIDEO INIT FAILED ==========');
      _log('Error type: ${e.runtimeType}');
      _log('Error: $e');
      _log('Stack: $stackTrace');

      if (e is DioException) {
        _log('DioException.type: ${e.type}');
        _log('DioException.message: ${e.message}');
        _log('DioException.status: ${e.response?.statusCode}');
        _log('DioException.response data: ${e.response?.data}');
        _log('DioException.request uri: ${e.requestOptions.uri}');
      }

      final tempPath = _tempFilePath;
      if (!kIsWeb && tempPath != null) {
        _log('Trying OpenFilex fallback after init failure');
        try {
          final opened = await _openWithSystemPlayer(tempPath);
          if (opened && mounted) {
            setState(() {
              _initializing = false;
              _hasError = false;
              _openedExternally = true;
              _useWinPlayer = false;
              _errorMessage = null;
              _debugDetail = null;
            });
            _log('========== VIDEO OPENED EXTERNALLY (SUCCESS) ==========');
            return;
          }
        } catch (openError, openStack) {
          _log('OpenFilex fallback failed: $openError');
          _log('OpenFilex stack: $openStack');
        }
      }

      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hasError = true;
        _useWinPlayer = false;
        _errorMessage = 'Unable to play this video. Please try again.';
        _debugDetail = e.toString();
      });
    }
  }

  Future<void> _onWinPlayerFailed(Object error, StackTrace stackTrace) async {
    _log('WinLocalVideoPlayer reported failure: $error');
    _log('Win stack: $stackTrace');

    final tempPath = _tempFilePath;
    if (tempPath != null) {
      try {
        final opened = await _openWithSystemPlayer(tempPath);
        if (opened && mounted) {
          setState(() {
            _useWinPlayer = false;
            _openedExternally = true;
            _hasError = false;
            _errorMessage = null;
            _debugDetail = null;
          });
          return;
        }
      } catch (e, st) {
        _log('OpenFilex after Win failure failed: $e');
        _log('$st');
      }
    }

    if (!mounted) return;
    setState(() {
      _useWinPlayer = false;
      _hasError = true;
      _errorMessage =
          'Unable to play this video on Windows. '
          'Install a codec pack (e.g. K-Lite) or open it in VLC.';
      _debugDetail = error.toString();
    });
  }

  @override
  void dispose() {
    _log('dispose → releasing controller');
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = value.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_initializing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.white,
            ),
            SizedBox(height: 12),
            Text(
              'Loading video...',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_useWinPlayer && _tempFilePath != null) {
      return WinLocalVideoPlayer(
        filePath: _tempFilePath!,
        onLog: _log,
        onFailed: _onWinPlayerFailed,
      );
    }

    if (_openedExternally) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.open_in_new_rounded,
                size: 42,
                color: AppColors.white,
              ),
              const SizedBox(height: 12),
              Text(
                'Video opened in your system player.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              if (_tempFilePath != null) ...[
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => _openWithSystemPlayer(_tempFilePath!),
                  child: Text(
                    'Open again',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError || controller == null || !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                size: 42,
                color: AppColors.white,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Video preview is not available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              if (_tempFilePath != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final opened = await _openWithSystemPlayer(_tempFilePath!);
                    if (opened && mounted) {
                      setState(() {
                        _openedExternally = true;
                        _hasError = false;
                      });
                    }
                  },
                  child: Text(
                    'Open in system player',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
              if (kDebugMode &&
                  _debugDetail != null &&
                  _debugDetail!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _debugDetail!,
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final position = controller.value.position;
        final duration = controller.value.duration;
        final isPlaying = controller.value.isPlaying;
        final progress = duration.inMilliseconds == 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio == 0
                    ? 16 / 9
                    : controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                child: Center(
                  child: AnimatedOpacity(
                    opacity: isPlaying ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 42,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white24,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        '${_formatDuration(position)} / ${_formatDuration(duration)}',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
