import 'package:flutter/material.dart';

/// Stub used on web / non-Windows so conditional imports compile.
bool get supportsWinVideoPlayer => false;

class WinVideoThumbnail extends StatelessWidget {
  const WinVideoThumbnail({
    super.key,
    required this.filePath,
    required this.placeholder,
  });

  final String filePath;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) => placeholder;
}

class WinLocalVideoPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    onFailed(
      UnsupportedError('WinLocalVideoPlayer is only available on Windows'),
      StackTrace.current,
    );
    return const SizedBox.shrink();
  }
}
