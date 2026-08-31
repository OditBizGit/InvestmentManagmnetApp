import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_image_card.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_video_card.dart';
import 'package:sizer/sizer.dart';

class UserStatusScreen extends StatefulWidget {
  const UserStatusScreen({super.key});

  @override
  State<UserStatusScreen> createState() => _UserStatusScreenState();
}

class _UserStatusScreenState extends State<UserStatusScreen> {
  static const Color _screenBg = Color(0xFFF7F6F9);

  /// Paste any YouTube watch / youtu.be / shorts URL (or video id) here.
  static const List<_StatusItem> _items = [
    _StatusItem.image(
      'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=900&h=600&fit=crop',
    ),
    _StatusItem.video(
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    _StatusItem.image(
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=900&h=600&fit=crop',
    ),
    _StatusItem.video(
      'https://youtu.be/jNQXAC9IVRw',
    ),
    _StatusItem.image(
      'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=900&h=600&fit=crop',
    ),
  ];

  /// Ensures only one YouTube card mounts/plays at a time.
  final ValueNotifier<String?> _activeVideoUrl = ValueNotifier<String?>(null);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _scrollTick = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _scrollTick.value++;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTick.dispose();
    _activeVideoUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _screenBg,
      child: SafeArea(
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          itemCount: _items.length,
          separatorBuilder: (_, _) => SizedBox(height: 1.8.h),
          itemBuilder: (context, index) {
            final item = _items[index];
            if (item.isVideo) {
              return StatusVideoCard(
                key: ValueKey('status-video-${item.url}'),
                youtubeUrl: item.url,
                activeVideoUrl: _activeVideoUrl,
                scrollListenable: _scrollTick,
                onCopy: () => _copyLink(context, item.url),
                onShare: () => _showSnack(context, 'Share tapped'),
                onDownload: () => _showSnack(context, 'Download started'),
                onView: () => _showSnack(context, 'View video'),
              );
            }
            return StatusImageCard(
              imageUrl: item.url,
              onCopy: () => _copyLink(context, item.url),
              onShare: () => _showSnack(context, 'Share tapped'),
              onDownload: () => _showSnack(context, 'Download started'),
              onView: () => _showSnack(context, 'View image'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    _showSnack(context, 'Link copied');
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
  }
}

class _StatusItem {
  const _StatusItem._({required this.url, required this.isVideo});

  const _StatusItem.image(String url) : this._(url: url, isVideo: false);

  const _StatusItem.video(String url) : this._(url: url, isVideo: true);

  final String url;
  final bool isVideo;
}
