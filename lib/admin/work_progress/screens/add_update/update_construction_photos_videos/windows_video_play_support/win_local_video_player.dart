import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player_win/video_player_win.dart';

/// Whether this build can use the Windows Media Foundation player.
bool get supportsWinVideoPlayer => !kIsWeb && Platform.isWindows;

/// Muted, paused first frame of a local video for grid thumbnails.
class WinVideoThumbnail extends StatefulWidget {
  const WinVideoThumbnail({
    super.key,
    required this.filePath,
    required this.placeholder,
  });

  final String filePath;
  final Widget placeholder;

  @override
  State<WinVideoThumbnail> createState() => _WinVideoThumbnailState();
}

class _WinVideoThumbnailState extends State<WinVideoThumbnail> {
  WinVideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = WinVideoPlayerController.file(File(widget.filePath));
      _controller = controller;
      await controller.initialize();
      if (!mounted ||
          !controller.value.isInitialized ||
          controller.value.hasError) {
        return;
      }
      // Media Foundation renders no frame until playback has started.
      await controller.setVolume(0);
      await controller.play();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await controller.pause();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!_ready || controller == null) return widget.placeholder;

    final size = controller.value.size;
    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width == 0 ? 16 : size.width,
          height: size.height == 0 ? 9 : size.height,
          child: WinVideoPlayer(controller),
        ),
      ),
    );
  }
}

/// Windows in-app player using [video_player_win] (standalone API).
class WinLocalVideoPlayer extends StatefulWidget {
  const WinLocalVideoPlayer({
    super.key,
    required this.filePath,
    required this.onLog,
    required this.onFailed,
  });

  final String filePath;
  final void Function(String message) onLog;
  final void Function(Object error, StackTrace stackTrace) onFailed;

  @override
  State<WinLocalVideoPlayer> createState() => _WinLocalVideoPlayerState();
}

class _WinLocalVideoPlayerState extends State<WinLocalVideoPlayer> {
  WinVideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    widget.onLog('Windows path: WinVideoPlayerController.file(${widget.filePath})');
    try {
      final controller = WinVideoPlayerController.file(File(widget.filePath));
      _controller = controller;
      await controller.initialize();
      widget.onLog(
        'Win initialize OK. isInitialized=${controller.value.isInitialized}, '
        'duration=${controller.value.duration}, size=${controller.value.size}, '
        'hasError=${controller.value.hasError}, '
        'error=${controller.value.errorDescription}',
      );

      if (!controller.value.isInitialized || controller.value.hasError) {
        throw StateError(
          controller.value.errorDescription ??
              'WinVideoPlayer failed to initialize',
        );
      }

      await controller.setLooping(true);
      await controller.play();
      if (!mounted) return;
      setState(() => _loading = false);
      widget.onLog('Win play requested. isPlaying=${controller.value.isPlaying}');
    } catch (e, st) {
      widget.onLog('WinVideoPlayer failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      widget.onFailed(e, st);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = value.inHours;
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Loading video…',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final controller = _controller;
    if (_error != null || controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink(); // Parent handles fallback UI.
    }

    return ValueListenableBuilder<WinVideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final progress = value.duration.inMilliseconds == 0
            ? 0.0
            : (value.position.inMilliseconds / value.duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio:
                    value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
                child: WinVideoPlayer(controller),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                child: Center(
                  child: AnimatedOpacity(
                    opacity: value.isPlaying ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 42,
                        color: Colors.white,
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
                      color: const Color(0xFFE89A3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (value.isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }
                        },
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
