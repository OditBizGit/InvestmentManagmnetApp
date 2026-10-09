import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_construction_photos_videos/windows_video_play_support/win_video_support.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

/// Inline network video with preview, play/pause, scrubber, replay, and fullscreen.
class WorkUpdateInlineVideo extends StatefulWidget {
  const WorkUpdateInlineVideo({
    super.key,
    required this.videoUrl,
    this.title = '',
    this.fileName = '',
  });

  final String videoUrl;
  final String title;
  final String fileName;

  @override
  State<WorkUpdateInlineVideo> createState() => WorkUpdateInlineVideoState();
}

class WorkUpdateInlineVideoState extends State<WorkUpdateInlineVideo> {
  static const String _logTag = 'WorkUpdateInlineVideo';

  VideoPlayerController? _controller;
  String? _winFilePath;
  String? _error;
  bool _initializing = true;
  bool _showControls = true;
  bool _inFullscreen = false;
  bool _isSeeking = false;
  bool _useWinPlayer = false;
  bool _didAutoRetry = false;
  double? _seekValue;
  double _volumeBeforeMute = 1.0;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant WorkUpdateInlineVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initPlayer();
    }
  }

  Future<void> _initPlayer({bool forceRedownload = false}) async {
    setState(() {
      _initializing = true;
      _error = null;
      _showControls = true;
      _useWinPlayer = false;
      _winFilePath = null;
    });

    try {
      await WorkUpdateVideoInitGate.run(() => _initPlayerBody(
            forceRedownload: forceRedownload,
          ));
    } catch (e, stackTrace) {
      log(
        'Video init failed: $e',
        name: _logTag,
        stackTrace: stackTrace,
      );

      // One automatic recovery: drop bad cache and try again.
      if (!_didAutoRetry && !forceRedownload && !kIsWeb && mounted) {
        _didAutoRetry = true;
        try {
          await WorkUpdateMediaCache.invalidateVideoFile(
            url: widget.videoUrl,
            fileName: widget.fileName,
          );
          await WorkUpdateVideoInitGate.run(
            () => _initPlayerBody(forceRedownload: true),
          );
          return;
        } catch (retryError, retryStack) {
          log(
            'Video retry failed: $retryError',
            name: _logTag,
            stackTrace: retryStack,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _controller = null;
        _winFilePath = null;
        _useWinPlayer = false;
        _initializing = false;
        _error = 'Unable to load preview';
      });
    }
  }

  Future<void> _initPlayerBody({required bool forceRedownload}) async {
    // Web: stream with auth headers (same as admin).
    if (kIsWeb) {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: WorkUpdateMediaCache.authHeaders(),
      );
      await _attachStandardController(controller);
      return;
    }

    // Desktop/mobile: download via Dio with a real file extension (admin path).
    final file = await WorkUpdateMediaCache.downloadVideoFile(
      url: widget.videoUrl,
      fileName: widget.fileName,
      forceRedownload: forceRedownload,
    );
    if (!mounted) return;

    // Windows: Media Foundation player (same as admin construction media).
    if (supportsWinVideoPlayer) {
      if (!mounted) return;
      setState(() {
        _winFilePath = file.path;
        _useWinPlayer = true;
        _controller = null;
        _initializing = false;
        _error = null;
      });
      return;
    }

    try {
      final controller = VideoPlayerController.file(file);
      await _attachStandardController(controller);
    } catch (fileError, fileStack) {
      log(
        'File player failed, trying network stream: $fileError',
        name: _logTag,
        stackTrace: fileStack,
      );
      // Fallback used by admin on web — helps when local decode fails.
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: WorkUpdateMediaCache.authHeaders(),
      );
      await _attachStandardController(controller);
    }
  }

  Future<void> _attachStandardController(
    VideoPlayerController controller,
  ) async {
    try {
      await controller.initialize();
      if (controller.value.hasError) {
        throw StateError(
          controller.value.errorDescription ??
              'VideoPlayer reported hasError=true after initialize',
        );
      }
      final duration = controller.value.duration;
      if (duration > Duration.zero) {
        final previewAt = duration > const Duration(milliseconds: 300)
            ? const Duration(milliseconds: 300)
            : Duration.zero;
        await controller.seekTo(previewAt);
      }
      await controller.setLooping(false);
      await controller.pause();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onTick);
      setState(() {
        _controller = controller;
        _winFilePath = null;
        _useWinPlayer = false;
        _initializing = false;
        _error = null;
      });
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  }

  Future<void> _retryLoad() async {
    _didAutoRetry = false;
    _disposeController();
    await _initPlayer(forceRedownload: true);
  }

  void _onTick() {
    if (!mounted || _isSeeking || _useWinPlayer) return;
    final controller = _controller;
    if (controller == null) return;

    if (_isCompleted(controller) && !_showControls) {
      setState(() => _showControls = true);
      return;
    }
    setState(() {});
  }

  bool _isCompleted(VideoPlayerController controller) {
    if (!controller.value.isInitialized) return false;
    final duration = controller.value.duration;
    if (duration <= Duration.zero) return false;
    final position = controller.value.position;
    return !controller.value.isPlaying &&
        position >= duration - const Duration(milliseconds: 400);
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    final controller = _controller;
    if (controller == null ||
        !controller.value.isPlaying ||
        _isCompleted(controller)) {
      return;
    }
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final c = _controller;
      if (c != null && c.value.isPlaying && !_isCompleted(c)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _revealControls() {
    setState(() => _showControls = true);
    _scheduleHideControls();
  }

  void _onSurfaceTap() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (_isCompleted(controller)) {
      _replay();
      return;
    }

    if (_showControls) {
      setState(() => _showControls = false);
      _hideControlsTimer?.cancel();
    } else {
      _revealControls();
    }
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (_isCompleted(controller)) {
      await _replay();
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
      _hideControlsTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      await controller.play();
      _revealControls();
    }
  }

  Future<void> _replay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.seekTo(Duration.zero);
    await controller.play();
    _revealControls();
  }

  Future<void> _seekTo(double valueMs) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.seekTo(Duration(milliseconds: valueMs.round()));
  }

  bool get _isMuted {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return false;
    return controller.value.volume <= 0.001;
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (_isMuted) {
      final restore = _volumeBeforeMute <= 0.001 ? 1.0 : _volumeBeforeMute;
      await controller.setVolume(restore);
    } else {
      _volumeBeforeMute = controller.value.volume;
      await controller.setVolume(0);
    }
    if (mounted) setState(() {});
    _revealControls();
  }

  /// Opens the fullscreen player once the inline controller is ready.
  /// On load failure, opens a fullscreen error page so View still works.
  Future<void> openFullscreen() async {
    if (_useWinPlayer) {
      final path = _winFilePath;
      if (path == null) {
        await _openFullscreenError(
          message: _error ?? 'Unable to load preview',
        );
        return;
      }
      await _openWinFullscreen(path);
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      if (_initializing) {
        // Wait briefly for an in-flight init to finish.
        for (var i = 0; i < 40 && _initializing && mounted; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }
    }
    if (!mounted) return;

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      await _openFullscreenError(
        message: _error ?? 'Unable to load preview',
      );
      return;
    }
    await _openFullscreen();
  }

  Future<void> _openFullscreenError({required String message}) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, animation, secondaryAnimation) =>
            _FullscreenVideoErrorPage(
          title: widget.title,
          message: message,
        ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _openWinFullscreen(String filePath) async {
    _hideControlsTimer?.cancel();
    setState(() {
      _inFullscreen = true;
      _showControls = true;
    });

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, animation, secondaryAnimation) =>
            _FullscreenWinVideoPage(
          filePath: filePath,
          title: widget.title,
        ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (!mounted) return;
    setState(() {
      _inFullscreen = false;
      _showControls = true;
    });
  }

  Future<void> _openFullscreen() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    _hideControlsTimer?.cancel();
    setState(() {
      _inFullscreen = true;
      _showControls = true;
    });

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, animation, secondaryAnimation) => _FullscreenVideoPage(
          controller: controller,
          title: widget.title,
        ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (!mounted) return;
    setState(() {
      _inFullscreen = false;
      _showControls = true;
    });
    if (controller.value.isPlaying) {
      _scheduleHideControls();
    }
  }

  void _disposeController() {
    _hideControlsTimer?.cancel();
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onTick);
      // Best-effort pause before tearing down the native player.
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
      controller.dispose();
    }
    _controller = null;
    _winFilePath = null;
    _useWinPlayer = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  static String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    if (totalSeconds < 0) return '0:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final sec = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$sec';
    }
    return '$minutes:$sec';
  }

  @override
  Widget build(BuildContext context) {
    if (_useWinPlayer) {
      final path = _winFilePath;
      if (_error != null) {
        return _ErrorPane(message: _error!, onRetry: _retryLoad);
      }
      if (_initializing || path == null) {
        return const _VideoLoadingShimmer();
      }
      if (_inFullscreen) {
        return Container(color: Colors.black);
      }
      return ColoredBox(
        color: Colors.black,
        child: WinLocalVideoPlayer(
          filePath: path,
          onLog: (message) => log(message, name: _logTag),
          onFailed: (error, stackTrace) {
            log(
              'Win player failed: $error',
              name: _logTag,
              stackTrace: stackTrace,
            );
            if (!mounted) return;
            if (!_didAutoRetry) {
              _didAutoRetry = true;
              _disposeController();
              _initPlayer(forceRedownload: true);
              return;
            }
            setState(() {
              _error = 'Unable to load preview';
              _useWinPlayer = false;
              _winFilePath = null;
              _initializing = false;
            });
          },
        ),
      );
    }

    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;
    final isPlaying = isReady && controller.value.isPlaying;
    final completed = isReady && _isCompleted(controller);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_error != null)
          _ErrorPane(message: _error!, onRetry: _retryLoad)
        else if (!isReady || _initializing)
          const _VideoLoadingShimmer()
        else if (_inFullscreen)
          Container(color: Colors.black)
        else
          GestureDetector(
            onTap: _onSurfaceTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: _VideoControlsOverlay(
                      isPlaying: isPlaying,
                      isCompleted: completed,
                      isMuted: _isMuted,
                      position: _isSeeking && _seekValue != null
                          ? Duration(milliseconds: _seekValue!.round())
                          : controller.value.position,
                      duration: controller.value.duration,
                      seekValue: _seekValue,
                      onPlayPause: _togglePlay,
                      onReplay: _replay,
                      onMuteToggle: _toggleMute,
                      onFullscreen: _openFullscreen,
                      onSeekStart: (value) {
                        _hideControlsTimer?.cancel();
                        setState(() {
                          _isSeeking = true;
                          _seekValue = value;
                          _showControls = true;
                        });
                      },
                      onSeekChange: (value) {
                        setState(() => _seekValue = value);
                      },
                      onSeekEnd: (value) async {
                        await _seekTo(value);
                        if (!mounted) return;
                        setState(() {
                          _isSeeking = false;
                          _seekValue = null;
                        });
                        if (controller.value.isPlaying) {
                          _scheduleHideControls();
                        }
                      },
                      formatDuration: _formatDuration,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({
    required this.message,
    this.onRetry,
  });

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            ImageConstants.videoError,
            width: 10.w,
            height: 10.w,
            colorFilter: ColorFilter.mode(
              Colors.grey[600]!,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: Colors.grey[600],
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 1.h),
            TextButton.icon(
              onPressed: () => onRetry?.call(),
              icon: Icon(Icons.refresh_rounded, size: 4.5.w),
              label: Text(
                'Retry',
                style: TextStyle(fontSize: 11.5.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoLoadingShimmer extends StatelessWidget {
  const _VideoLoadingShimmer();

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      direction: ShimmerDirection.ltr,
      child: const ColoredBox(color: _shimmerBase),
    );
  }
}

class _VideoControlsOverlay extends StatelessWidget {
  const _VideoControlsOverlay({
    required this.isPlaying,
    required this.isCompleted,
    required this.isMuted,
    required this.position,
    required this.duration,
    required this.seekValue,
    required this.onPlayPause,
    required this.onReplay,
    required this.onMuteToggle,
    required this.onFullscreen,
    required this.onSeekStart,
    required this.onSeekChange,
    required this.onSeekEnd,
    required this.formatDuration,
    this.isFullscreen = false,
  });

  final bool isPlaying;
  final bool isCompleted;
  final bool isMuted;
  final Duration position;
  final Duration duration;
  final double? seekValue;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onMuteToggle;
  final VoidCallback onFullscreen;
  final ValueChanged<double> onSeekStart;
  final ValueChanged<double> onSeekChange;
  final ValueChanged<double> onSeekEnd;
  final String Function(Duration) formatDuration;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
    final currentMs = (seekValue ?? position.inMilliseconds.toDouble())
        .clamp(0.0, maxMs)
        .toDouble();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.55),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
        Center(
          child: _RoundControlButton(
            icon: isCompleted
                ? Icons.replay_rounded
                : (isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded),
            onTap: isCompleted ? onReplay : onPlayPause,
            size: 13.w,
            iconSize: 7.5.w,
          ),
        ),
        Positioned(
          left: 2.w,
          right: 2.w,
          bottom: 1.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 1.6.w),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 3.w),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white38,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white24,
                ),
                child: Slider(
                  min: 0,
                  max: maxMs,
                  value: currentMs,
                  onChanged: onSeekChange,
                  onChangeStart: onSeekStart,
                  onChangeEnd: onSeekEnd,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                child: Row(
                  children: [
                    Text(
                      formatDuration(Duration(milliseconds: currentMs.round())),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' / ${formatDuration(duration)}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _IconControlButton(
                      icon: isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      onTap: onMuteToggle,
                    ),
                    _IconControlButton(
                      icon: isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      onTap: onFullscreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.black87, size: iconSize),
        ),
      ),
    );
  }
}

class _IconControlButton extends StatelessWidget {
  const _IconControlButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(1.2.w),
          child: Icon(icon, color: Colors.white, size: 6.w),
        ),
      ),
    );
  }
}

class _FullscreenVideoErrorPage extends StatelessWidget {
  const _FullscreenVideoErrorPage({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageConstants.videoError,
                    width: 12.w,
                    height: 12.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.white54,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 1.h,
              left: 2.w,
              right: 2.w,
              child: Row(
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 5.5.w,
                        ),
                      ),
                    ),
                  ),
                  if (title.trim().isNotEmpty) ...[
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({
    required this.controller,
    required this.title,
  });

  final VideoPlayerController controller;
  final String title;

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _showControls = true;
  bool _isSeeking = false;
  bool _exiting = false;
  double? _seekValue;
  double _volumeBeforeMute = 1.0;
  Timer? _hideControlsTimer;

  VideoPlayerController get _controller => widget.controller;

  static const _fullscreenOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Keep system bars visible so exit does not jump when the nav bar returns.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(_fullscreenOverlayStyle);
    _controller.addListener(_onTick);
    if (_controller.value.isPlaying) {
      _scheduleHideControls();
    }
  }

  Future<void> _exitFullscreen() async {
    if (_exiting) return;
    _exiting = true;
    _hideControlsTimer?.cancel();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onTick() {
    if (!mounted || _isSeeking) return;
    if (_isCompleted && !_showControls) {
      setState(() => _showControls = true);
      return;
    }
    setState(() {});
  }

  bool get _isCompleted {
    if (!_controller.value.isInitialized) return false;
    final duration = _controller.value.duration;
    if (duration <= Duration.zero) return false;
    final position = _controller.value.position;
    return !_controller.value.isPlaying &&
        position >= duration - const Duration(milliseconds: 400);
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    if (!_controller.value.isPlaying || _isCompleted) return;
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_controller.value.isPlaying && !_isCompleted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _revealControls() {
    setState(() => _showControls = true);
    _scheduleHideControls();
  }

  void _onSurfaceTap() {
    if (_isCompleted) {
      _replay();
      return;
    }
    if (_showControls) {
      setState(() => _showControls = false);
      _hideControlsTimer?.cancel();
    } else {
      _revealControls();
    }
  }

  Future<void> _togglePlay() async {
    if (_isCompleted) {
      await _replay();
      return;
    }
    if (_controller.value.isPlaying) {
      await _controller.pause();
      _hideControlsTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      await _controller.play();
      _revealControls();
    }
  }

  Future<void> _replay() async {
    await _controller.seekTo(Duration.zero);
    await _controller.play();
    _revealControls();
  }

  Future<void> _seekTo(double valueMs) async {
    await _controller.seekTo(Duration(milliseconds: valueMs.round()));
  }

  bool get _isMuted => _controller.value.volume <= 0.001;

  Future<void> _toggleMute() async {
    if (!_controller.value.isInitialized) return;

    if (_isMuted) {
      final restore = _volumeBeforeMute <= 0.001 ? 1.0 : _volumeBeforeMute;
      await _controller.setVolume(restore);
    } else {
      _volumeBeforeMute = _controller.value.volume;
      await _controller.setVolume(0);
    }
    if (mounted) setState(() {});
    _revealControls();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_onTick);
    if (!_exiting) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller.value.isInitialized;
    final isPlaying = isReady && _controller.value.isPlaying;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _fullscreenOverlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _exitFullscreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: isReady
                ? GestureDetector(
                    onTap: _onSurfaceTap,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio == 0
                                ? 16 / 9
                                : _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _showControls ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: IgnorePointer(
                            ignoring: !_showControls,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _VideoControlsOverlay(
                                  isPlaying: isPlaying,
                                  isCompleted: _isCompleted,
                                  isMuted: _isMuted,
                                  isFullscreen: true,
                                  position: _isSeeking && _seekValue != null
                                      ? Duration(
                                          milliseconds: _seekValue!.round(),
                                        )
                                      : _controller.value.position,
                                  duration: _controller.value.duration,
                                  seekValue: _seekValue,
                                  onPlayPause: _togglePlay,
                                  onReplay: _replay,
                                  onMuteToggle: _toggleMute,
                                  onFullscreen: _exitFullscreen,
                                  onSeekStart: (value) {
                                    _hideControlsTimer?.cancel();
                                    setState(() {
                                      _isSeeking = true;
                                      _seekValue = value;
                                      _showControls = true;
                                    });
                                  },
                                  onSeekChange: (value) {
                                    setState(() => _seekValue = value);
                                  },
                                  onSeekEnd: (value) async {
                                    await _seekTo(value);
                                    if (!mounted) return;
                                    setState(() {
                                      _isSeeking = false;
                                      _seekValue = null;
                                    });
                                    if (_controller.value.isPlaying) {
                                      _scheduleHideControls();
                                    }
                                  },
                                  formatDuration: WorkUpdateInlineVideoState
                                      ._formatDuration,
                                ),
                                Positioned(
                                  top: 0.5.h,
                                  left: 1.w,
                                  right: 1.w,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: _exitFullscreen,
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (widget.title.isNotEmpty)
                                        Expanded(
                                          child: Text(
                                            widget.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenWinVideoPage extends StatefulWidget {
  const _FullscreenWinVideoPage({
    required this.filePath,
    required this.title,
  });

  final String filePath;
  final String title;

  @override
  State<_FullscreenWinVideoPage> createState() =>
      _FullscreenWinVideoPageState();
}

class _FullscreenWinVideoPageState extends State<_FullscreenWinVideoPage> {
  bool _exiting = false;

  static const _fullscreenOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(_fullscreenOverlayStyle);
  }

  Future<void> _exitFullscreen() async {
    if (_exiting) return;
    _exiting = true;
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    if (!_exiting) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _fullscreenOverlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _exitFullscreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                WinLocalVideoPlayer(
                  filePath: widget.filePath,
                  onLog: (_) {},
                  onFailed: (error, stackTrace) {},
                ),
                Positioned(
                  top: 0.5.h,
                  left: 1.w,
                  right: 1.w,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _exitFullscreen,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.title.isNotEmpty)
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
