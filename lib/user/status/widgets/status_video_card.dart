import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_card_actions.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Accepts watch / youtu.be / shorts / embed URLs or a raw 11-char video id.
String? extractYoutubeVideoId(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;

  final packageId = YoutubePlayerController.convertUrlToId(value);
  if (packageId != null && packageId.length == 11) {
    return packageId;
  }

  if (RegExp(r'^[\w-]{11}$').hasMatch(value)) {
    return value;
  }

  final uri = Uri.tryParse(value);
  if (uri != null && uri.host.isNotEmpty) {
    final host = uri.host.toLowerCase();

    if (host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first.split('?').first;
      if (id.length == 11) return id;
    }

    final watchId = uri.queryParameters['v'];
    if (watchId != null && watchId.length == 11) {
      return watchId;
    }

    final segments = uri.pathSegments;
    if (segments.length >= 2 &&
        (segments[0] == 'embed' ||
            segments[0] == 'shorts' ||
            segments[0] == 'live')) {
      final id = segments[1].split('?').first;
      if (id.length == 11) return id;
    }
  }

  final fallback = RegExp(
    r'(?:youtu\.be/|youtube(?:-nocookie)?\.com/(?:watch\?v=|embed/|shorts/|live/)|v=)([\w-]{11})',
  ).firstMatch(value);
  return fallback?.group(1);
}

class StatusVideoCard extends StatefulWidget {
  const StatusVideoCard({
    super.key,
    required this.youtubeUrl,
    required this.activeVideoUrl,
    this.scrollListenable,
    this.onCopy,
    this.onShare,
    this.onDownload,
    this.onView,
  });

  final String youtubeUrl;
  final ValueNotifier<String?> activeVideoUrl;
  final ValueListenable<int>? scrollListenable;

  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onView;

  @override
  State<StatusVideoCard> createState() => _StatusVideoCardState();
}

class _StatusVideoCardState extends State<StatusVideoCard> {
  static const Color _videoAccent = Color(0xFF7EC8D4);
  static const Color _label = Color(0xFF7EC8D4);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const String _logTag = 'StatusVideoCard';

  final GlobalKey _videoAreaKey = GlobalKey();

  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  StreamSubscription<YoutubeVideoState>? _videoStateSubscription;
  String? _videoId;
  String? _errorMessage;
  bool _playerMounted = false;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _isLoading = false;
  bool _isMounting = false;
  bool _videoLoaded = false;
  bool _isScrubbing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool get _preferHoverPlayback {
    if (kIsWeb) return true;
    return defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _videoId = extractYoutubeVideoId(widget.youtubeUrl);

    _log('init url=${widget.youtubeUrl} parsedVideoId=$_videoId');

    if (_videoId == null || _videoId!.length != 11) {
      _errorMessage = 'Invalid YouTube link';
      _log('invalid url — could not extract 11-char id from ${widget.youtubeUrl}');
    }

    widget.activeVideoUrl.addListener(_onActiveVideoChanged);
    widget.scrollListenable?.addListener(_checkVisibilityOnScroll);
  }

  @override
  void dispose() {
    widget.activeVideoUrl.removeListener(_onActiveVideoChanged);
    widget.scrollListenable?.removeListener(_checkVisibilityOnScroll);
    _playerSubscription?.cancel();
    _videoStateSubscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _logTag,
      error: error,
      stackTrace: stackTrace,
    );
    if (kDebugMode) {
      debugPrint('[$_logTag] $message${error != null ? ' | $error' : ''}');
    }
  }

  String _youtubeErrorMessage(YoutubeError error) {
    return switch (error) {
      YoutubeError.invalidParam => 'Invalid video id',
      YoutubeError.videoNotFound => 'Video not found',
      YoutubeError.notEmbeddable ||
      YoutubeError.sameAsNotEmbeddable ||
      YoutubeError.sameAsNotEmbeddable2 =>
        'Video cannot be played here (embed blocked)',
      YoutubeError.html5Error => 'Player error (HTML5)',
      YoutubeError.cannotFindVideo => 'Video unavailable',
      YoutubeError.unknown => 'Unknown player error',
      YoutubeError.none => '',
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _onActiveVideoChanged() {
    final active = widget.activeVideoUrl.value;
    if (active != widget.youtubeUrl && _isPlaying) {
      unawaited(_pausePlayback());
    }
  }

  void _checkVisibilityOnScroll() {
    if (!_isPlaying || !mounted) return;

    final box = _videoAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final mediaQuery = MediaQuery.of(context);
    final viewportTop = mediaQuery.padding.top;
    final viewportBottom = mediaQuery.size.height - mediaQuery.padding.bottom;

    final cardTop = position.dy;
    final cardBottom = position.dy + size.height;

    // Pause when less than ~25% of the video area remains visible.
    final visibleTop = cardTop.clamp(viewportTop, viewportBottom);
    final visibleBottom = cardBottom.clamp(viewportTop, viewportBottom);
    final visibleHeight = (visibleBottom - visibleTop).clamp(0.0, size.height);
    final visibilityRatio = visibleHeight / size.height;

    if (visibilityRatio < 0.25) {
      _log('auto-pause on scroll (visibility=${visibilityRatio.toStringAsFixed(2)})');
      unawaited(_pausePlayback());
    }
  }

  Widget _playbackControlButton() {
    return Container(
      width: 14.w,
      height: 14.w,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 8.w,
      ),
    );
  }

  void _listenToVideoProgress() {
    _videoStateSubscription?.cancel();
    final controller = _controller;
    if (controller == null) return;

    _videoStateSubscription = controller.videoStateStream.listen((state) {
      if (!mounted || _isScrubbing) return;
      setState(() {
        _position = state.position;
        if (_duration.inSeconds > 0) {
          final totalMs = _duration.inMilliseconds;
          final posMs = state.position.inMilliseconds;
          if (posMs > totalMs) {
            _duration = state.position;
          }
        }
      });
    });
  }

  void _listenToPlayer() {
    _playerSubscription?.cancel();
    final controller = _controller;
    if (controller == null) return;

    _playerSubscription = controller.stream.listen((value) {
      _log(
        'player update | videoId=$_videoId '
        'state=${value.playerState.name} '
        'error=${value.error.name} '
        'title=${value.metaData.title}',
      );

      if (!mounted) return;

      if (value.hasError) {
        final message = _youtubeErrorMessage(value.error);
        _log('YouTube API error: ${value.error.name} ($message)');
        setState(() {
          _errorMessage = message;
          _isLoading = false;
          _isPlaying = false;
        });
        return;
      }

      final playing = value.playerState == PlayerState.playing ||
          value.playerState == PlayerState.buffering;

      setState(() {
        _isPlaying = playing;
        if (value.metaData.duration.inSeconds > 0) {
          _duration = value.metaData.duration;
        }
        if (playing) {
          _isLoading = false;
          _errorMessage = null;
        } else if (value.playerState == PlayerState.cued ||
            value.playerState == PlayerState.paused ||
            value.playerState == PlayerState.ended) {
          _isLoading = false;
        }
      });

      if (value.playerState == PlayerState.playing ||
          value.playerState == PlayerState.paused) {
        unawaited(_syncMuteState());
      }
    });
  }

  Future<void> _syncMuteState() async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    try {
      final muted = await controller.isMuted;
      if (!mounted) return;
      setState(() => _isMuted = muted);
    } catch (_) {}
  }

  /// Creates controller + mounts [YoutubePlayer] widget (WebView). No API calls yet.
  Future<void> _mountPlayerWidget() async {
    if (_videoId == null || _playerMounted || _isMounting) return;

    _isMounting = true;
    _log('mounting player widget for videoId=$_videoId');

    try {
      _controller = YoutubePlayerController(
        key: _videoId,
        params: const YoutubePlayerParams(
          showControls: false,
          mute: true,
          loop: true,
          showFullscreenButton: false,
          pointerEvents: PointerEvents.none,
          playsInline: true,
          privacyEnhancedMode: true,
        ),
      );

      _listenToPlayer();
      _listenToVideoProgress();

      if (!mounted) return;
      setState(() {
        _playerMounted = true;
        _errorMessage = null;
      });

      // WebView / iframe is created only after [YoutubePlayer] is in the tree.
      await WidgetsBinding.instance.endOfFrame;
      if (kDebugMode) {
        await WidgetsBinding.instance.endOfFrame;
      }

      _log('player widget mounted');
    } catch (e, st) {
      _log('mount failed', error: e, stackTrace: st);
      if (mounted) {
        setState(() => _errorMessage = 'Unable to initialize player');
      }
    } finally {
      _isMounting = false;
    }
  }

  /// Loads the configured video id into the ready player, then starts playback.
  Future<void> _loadAndPlay() async {
    final controller = _controller;
    final videoId = _videoId;
    if (controller == null || videoId == null) return;

    if (_videoLoaded) {
      _log('video already loaded, calling playVideo()');
      await controller.playVideo();
      return;
    }

    _log('loadVideoById(videoId=$videoId)');
    await controller.loadVideoById(videoId: videoId);
    if (!mounted) return;
    setState(() => _videoLoaded = true);
    _log('loadVideoById completed for $videoId');
    _listenToVideoProgress();

    final duration = await controller.duration;
    if (duration > 0 && mounted) {
      setState(() => _duration = Duration(milliseconds: (duration * 1000).round()));
    }
  }

  Future<void> _resumePlayback() async {
    final controller = _controller;
    if (controller == null) return;

    widget.activeVideoUrl.value = widget.youtubeUrl;
    await controller.playVideo();
    if (!mounted) return;
    setState(() {
      _isPlaying = true;
      _isLoading = false;
    });
  }

  Future<void> _playPlayback() async {
    if (_videoId == null || _isMounting) return;

    _log('play requested for videoId=$_videoId');

    // Resume an already-loaded video (e.g. after scroll pause).
    if (_playerMounted && _videoLoaded && _controller != null) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        await _resumePlayback();
      } catch (e, st) {
        _log('resume failed', error: e, stackTrace: st);
        if (mounted) setState(() => _errorMessage = 'Unable to resume playback');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    if (_isLoading) return;

    widget.activeVideoUrl.value = widget.youtubeUrl;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_playerMounted) {
        await _mountPlayerWidget();
      }

      if (!mounted || _controller == null) return;

      await _loadAndPlay();
    } catch (e, st) {
      _log('playback failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to start playback');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pausePlayback() async {
    try {
      await _controller?.pauseVideo();
      _log('pauseVideo() invoked');
    } catch (e, st) {
      _log('pauseVideo() failed', error: e, stackTrace: st);
    }
    if (!mounted) return;
    setState(() => _isPlaying = false);
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _pausePlayback();
    } else {
      await _playPlayback();
    }
  }

  Future<void> _toggleMute() async {
    if (!_playerMounted) {
      await _playPlayback();
      if (_controller == null) return;
    }
    final controller = _controller;
    if (controller == null) return;

    try {
      if (_isMuted) {
        await controller.unMute();
      } else {
        await controller.mute();
      }
      await _syncMuteState();
      _log(_isMuted ? 'muted' : 'unmuted');
    } catch (e, st) {
      _log('mute toggle failed', error: e, stackTrace: st);
    }
  }

  Future<void> _seekTo(double fraction) async {
    final controller = _controller;
    if (controller == null || _duration.inSeconds <= 0) return;

    final clamped = fraction.clamp(0.0, 1.0);
    final targetSeconds = _duration.inSeconds * clamped;
    try {
      await controller.seekTo(seconds: targetSeconds, allowSeekAhead: true);
      if (!mounted) return;
      setState(() {
        _position = Duration(seconds: targetSeconds.round());
      });
    } catch (e, st) {
      _log('seek failed', error: e, stackTrace: st);
    }
  }

  Widget _buildControlsBar() {
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.88),
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(2.w, 1.2.h, 2.w, 0.8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressSlider(),
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _togglePlayback,
                    child: Padding(
                      padding: EdgeInsets.all(1.5.w),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 5.5.w,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggleMute,
                    child: Padding(
                      padding: EdgeInsets.all(1.5.w),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      return PointerInterceptor(child: bar);
    }
    return bar;
  }

  Widget _buildProgressSlider() {
    final totalMs = _duration.inMilliseconds;
    final maxMs = totalMs > 0 ? totalMs.toDouble() : 1.0;
    final valueMs =
        _position.inMilliseconds.clamp(0, totalMs > 0 ? totalMs : 0);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: _videoAccent,
        inactiveTrackColor: Colors.white24,
        thumbColor: _videoAccent,
        overlayColor: _videoAccent.withValues(alpha: 0.2),
      ),
      child: Slider(
        value: valueMs.toDouble(),
        max: maxMs,
        onChangeStart: (_) => _isScrubbing = true,
        onChanged: totalMs > 0
            ? (v) {
                setState(() {
                  _position = Duration(milliseconds: v.round());
                });
              }
            : null,
        onChangeEnd: totalMs > 0
            ? (v) async {
                _isScrubbing = false;
                await _seekTo(v / maxMs);
              }
            : null,
      ),
    );
  }

  /// Renders ON TOP of the WebView via [YoutubePlayer.controlsBuilder].
  Widget _buildPlayerControlsOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isLoading)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.25),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _videoAccent,
              ),
            ),
          ),
        if (!_isPlaying && !_isLoading)
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _playPlayback,
                child: _playbackControlButton(),
              ),
            ),
          ),
        if (_playerMounted && (_videoLoaded || _isLoading || _isPlaying))
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildControlsBar(),
          ),
      ],
    );
  }

  void _onHoverEnter(PointerEvent _) {
    if (!_preferHoverPlayback || _isPlaying || _isLoading) return;
    unawaited(_playPlayback());
  }

  void _onHoverExit(PointerEvent _) {
    if (!_preferHoverPlayback || !_isPlaying) return;
    unawaited(_pausePlayback());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _videoAccent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoArea(),
            ),
          ),
          SizedBox(height: 1.4.h),
          Row(
            children: [
              Text(
                'VIDEO LINK',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: _label,
                ),
              ),
              const Spacer(),
              StatusCardActions(
                onCopy: widget.onCopy,
                onShare: widget.onShare,
                onDownload: widget.onDownload,
                onView: widget.onView,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_videoId == null) {
      return ColoredBox(
        color: _accentSoft,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined, color: _videoAccent, size: 8.w),
              SizedBox(height: 0.8.h),
              Text(
                _errorMessage ?? 'Invalid YouTube link',
                style: TextStyle(fontSize: 12.sp, color: _videoAccent),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      key: _videoAreaKey,
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_playerMounted && _controller != null)
            YoutubePlayer(
              key: ValueKey('yt-player-$_videoId'),
              controller: _controller!,
              aspectRatio: 16 / 9,
              enableFullScreenOnVerticalDrag: false,
              autoFullScreen: false,
              controlsBuilder: (_, _) => _buildPlayerControlsOverlay(),
            )
          else
            _Thumbnail(videoId: _videoId!),
          if (_errorMessage != null)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
          if (!_playerMounted && !_isLoading)
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _playPlayback,
                  child: _playbackControlButton(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    final url = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return ColoredBox(
      color: Colors.black,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFFF0EBF6),
          child: Center(
            child: Icon(
              Icons.ondemand_video_outlined,
              color: Color(0xFF7EC8D4),
            ),
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(
            color: Colors.black12,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF7EC8D4),
              ),
            ),
          );
        },
      ),
    );
  }
}
