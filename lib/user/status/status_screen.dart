import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/user/status/cubit/status_cubit.dart';
import 'package:maribel_wellness_centre_application/user/status/model/work_status_model.dart';
import 'package:maribel_wellness_centre_application/user/status/utils/status_media_download.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_image_card.dart';
import 'package:maribel_wellness_centre_application/user/status/widgets/status_video_card.dart';
import 'package:maribel_wellness_centre_application/user/updates/widgets/work_update_fullscreen_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UserStatusScreen extends StatelessWidget {
  const UserStatusScreen({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const int _shimmerCardCount = 4;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<StatusCubit>();
        final hasCache = cubit.state is StatusSuccess;
        cubit.loadStatuses(
          silent: hasCache,
          forceRefresh: true,
        );
        return cubit;
      },
      child: _UserStatusView(isActive: isActive),
    );
  }
}

class _UserStatusView extends StatefulWidget {
  const _UserStatusView({required this.isActive});

  final bool isActive;

  @override
  State<_UserStatusView> createState() => _UserStatusViewState();
}

class _UserStatusViewState extends State<_UserStatusView> {
  static const _silentRefreshInterval = Duration(seconds: 5);

  final ScrollController _scrollController = ScrollController();
  final Set<String> _downloadingUrls = <String>{};
  Timer? _silentRefreshTimer;
  bool _isSilentRefreshing = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _startSilentRefresh();
    }
  }

  @override
  void didUpdateWidget(covariant _UserStatusView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;

    if (widget.isActive) {
      _startSilentRefresh();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isActive) return;
        context.read<StatusCubit>().loadStatuses(
              silent: true,
              forceRefresh: true,
            );
      });
    } else {
      _stopSilentRefresh();
    }
  }

  @override
  void dispose() {
    _stopSilentRefresh();
    _scrollController.dispose();
    super.dispose();
  }

  void _startSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = Timer.periodic(
      _silentRefreshInterval,
      (_) => _silentRefresh(),
    );
  }

  void _stopSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = null;
  }

  Future<void> _silentRefresh() async {
    if (!mounted || !widget.isActive || _isSilentRefreshing) return;

    _isSilentRefreshing = true;
    try {
      await context.read<StatusCubit>().loadStatuses(
            silent: true,
            forceRefresh: true,
          );
    } finally {
      _isSilentRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0.8.h),
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<StatusCubit, StatusState>(
                builder: (context, state) {
                  if (state is StatusLoading || state is StatusInitial) {
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
                      itemCount: UserStatusScreen._shimmerCardCount,
                      separatorBuilder: (_, _) => SizedBox(height: 1.8.h),
                      itemBuilder: (_, _) => const _StatusCardShimmer(),
                    );
                  }

                  if (state is StatusFailure) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            TextButton(
                              onPressed: () => context
                                  .read<StatusCubit>()
                                  .loadStatuses(forceRefresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final statuses = state is StatusSuccess
                      ? state.statuses
                      : <WorkStatusModel>[];

                  if (statuses.isEmpty) {
                    return Center(
                      child: Text(
                        'No status updates yet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<StatusCubit>()
                        .loadStatuses(forceRefresh: true),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
                      itemCount: statuses.length,
                      separatorBuilder: (_, _) => SizedBox(height: 1.8.h),
                      itemBuilder: (context, index) {
                        final item = statuses[index];
                        final mediaUrl = item.resolvedFileUrl;

                        if (mediaUrl == null || mediaUrl.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        if (item.isVideo) {
                          return StatusVideoCard(
                            key: ValueKey(
                              'status-video-${item.workStatusId}',
                            ),
                            videoUrl: mediaUrl,
                            title: item.title,
                            description: item.description,
                            fileName: item.fileName,
                            isActive: widget.isActive,
                            onCopy: () => _copyLink(context, mediaUrl),
                            onShare: () => AppSnackBar.show(
                              context,
                              message: 'Share tapped',
                            ),
                            onDownload: () => _downloadMedia(
                              context,
                              url: mediaUrl,
                              isVideo: true,
                              fileName: item.fileName,
                              mimeType: item.mimeType,
                            ),
                          );
                        }

                        return StatusImageCard(
                          key: ValueKey(
                            'status-image-${item.workStatusId}',
                          ),
                          imageUrl: mediaUrl,
                          title: item.title,
                          description: item.description,
                          onCopy: () => _copyLink(context, mediaUrl),
                          onShare: () => AppSnackBar.show(
                            context,
                            message: 'Share tapped',
                          ),
                          onDownload: () => _downloadMedia(
                            context,
                            url: mediaUrl,
                            isVideo: false,
                            fileName: item.fileName,
                            mimeType: item.mimeType,
                          ),
                          onView: () => openWorkUpdateFullscreenImage(
                            context,
                            imageUrl: mediaUrl,
                            title: item.title,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      message: 'Link copied',
      duration: const Duration(seconds: 1),
      icon: Icons.copy_rounded,
    );
  }

  Future<void> _downloadMedia(
    BuildContext context, {
    required String url,
    required bool isVideo,
    String? fileName,
    String? mimeType,
  }) async {
    if (_downloadingUrls.contains(url)) return;

    _downloadingUrls.add(url);
    final cancelToken = CancelToken();
    final progress = AppSnackBar.showProgress(
      context,
      message: 'Downloading...',
      icon: Icons.download_rounded,
      onCancel: () {
        if (!cancelToken.isCancelled) {
          cancelToken.cancel('Cancelled by user');
        }
      },
    );

    try {
      final result = await StatusMediaDownload.save(
        url: url,
        isVideo: isVideo,
        fileName: fileName,
        mimeType: mimeType,
        cancelToken: cancelToken,
        onProgress: (value) {
          if (!context.mounted || progress.isCancelled) return;
          if (value == null) {
            progress.update(null, message: 'Downloading...');
            return;
          }
          if (value >= 1) {
            // Download finished — cancel is no longer useful while saving.
            progress.setCancelEnabled(false);
            progress.update(1, message: 'Saving...');
            return;
          }
          progress.update(value, message: 'Downloading...');
        },
      );
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: switch (result.target) {
          StatusMediaSaveTarget.gallery => 'Saved to gallery',
          StatusMediaSaveTarget.downloads => 'Saved to Downloads',
          StatusMediaSaveTarget.documents => 'Saved to Files',
        },
        icon: Icons.download_done_rounded,
      );
    } on DioException catch (error) {
      if (!context.mounted) return;
      if (error.type == DioExceptionType.cancel || CancelToken.isCancel(error)) {
        AppSnackBar.show(
          context,
          message: 'Download cancelled',
          icon: Icons.cancel_outlined,
        );
        return;
      }
      debugPrint('Status download failed: $error');
      AppSnackBar.show(
        context,
        message: 'Could not download media. Please try again.',
        icon: Icons.error_outline_rounded,
      );
    } on GalleryPermissionDeniedException {
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: 'Gallery permission is required to save media',
        icon: Icons.error_outline_rounded,
      );
    } catch (error, stack) {
      debugPrint('Status download failed: $error\n$stack');
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: 'Could not download media. Please try again.',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      _downloadingUrls.remove(url);
      // Dispose after the progress snackbar has been replaced/hidden.
      Future.microtask(progress.close);
    }
  }
}

class _StatusCardShimmer extends StatelessWidget {
  const _StatusCardShimmer();

  static const Color _border = Color(0xFFD8CCE8);

  static TextStyle get _titleStyle => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.transparent,
      );

  static TextStyle get _descriptionStyle => TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: Colors.transparent,
      );

  static TextStyle get _labelStyle => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Colors.transparent,
      );

  Widget _barLine({
    required String placeholder,
    required TextStyle style,
    required double widthFactor,
    int maxLines = 1,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(
            placeholder,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                heightFactor: 0.72,
                child: Container(
                  decoration: BoxDecoration(
                    color: UserStatusScreen._shimmerBase,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCircle() {
    return Container(
      width: 9.w,
      height: 9.w,
      decoration: const BoxDecoration(
        color: UserStatusScreen._shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: UserStatusScreen._shimmerBase,
        highlightColor: UserStatusScreen._shimmerHighlight,
        direction: ShimmerDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(color: UserStatusScreen._shimmerBase),
              ),
            ),
            SizedBox(height: 1.h),
            _barLine(
              placeholder: 'Title',
              style: _titleStyle,
              widthFactor: 0.4,
            ),
            SizedBox(height: 0.5.h),
            _barLine(
              placeholder: 'Description line',
              style: _descriptionStyle,
              widthFactor: 0.7,
            ),
            SizedBox(height: 1.4.h),
            Row(
              children: [
                SizedBox(
                  width: 16.w,
                  child: _barLine(
                    placeholder: 'IMAGE',
                    style: _labelStyle,
                    widthFactor: 1,
                  ),
                ),
                const Spacer(),
                _actionCircle(),
                SizedBox(width: 2.w),
                _actionCircle(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
