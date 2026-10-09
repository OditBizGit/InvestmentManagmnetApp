import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/go_to_top_button.dart';
import 'package:maribel_wellness_centre_application/user/updates/cubit/updates_cubit.dart';
import 'package:maribel_wellness_centre_application/user/updates/model/work_update_model.dart';
import 'package:maribel_wellness_centre_application/user/updates/utils/work_update_media_cache.dart';
import 'package:maribel_wellness_centre_application/user/updates/widgets/work_update_fullscreen_image.dart';
import 'package:maribel_wellness_centre_application/user/updates/widgets/work_update_inline_video.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UserUpdatesScreen extends StatelessWidget {
  const UserUpdatesScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the user [IndexedStack].
  final bool isActive;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const int _shimmerCardCount = 4;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<UpdatesCubit>();
        final hasCache = cubit.state is UpdatesSuccess;
        cubit.loadUpdates(
          silent: hasCache,
          forceRefresh: true,
        );
        return cubit;
      },
      child: _UserUpdatesView(isActive: isActive),
    );
  }
}

class _UserUpdatesView extends StatefulWidget {
  const _UserUpdatesView({required this.isActive});

  final bool isActive;

  @override
  State<_UserUpdatesView> createState() => _UserUpdatesViewState();
}

class _UserUpdatesViewState extends State<_UserUpdatesView> {
  static const _silentRefreshInterval = Duration(seconds: 5);
  static const _goToTopMinCardCount = 8;

  final ScrollController _scrollController = ScrollController();
  Timer? _silentRefreshTimer;
  bool _isSilentRefreshing = false;
  bool _showGoToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    if (widget.isActive) {
      _startSilentRefresh();
    }
  }

  @override
  void didUpdateWidget(covariant _UserUpdatesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;

    if (widget.isActive) {
      _startSilentRefresh();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isActive) return;
        context.read<UpdatesCubit>().loadUpdates(
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
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final state = context.read<UpdatesCubit>().state;
    final cardCount =
        state is UpdatesSuccess ? state.updates.length : 0;

    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    final scrolledPast40Percent =
        maxExtent > 0 && position.pixels / maxExtent >= 0.4;
    final shouldShow =
        cardCount > _goToTopMinCardCount && scrolledPast40Percent;
    if (shouldShow == _showGoToTop) return;
    setState(() => _showGoToTop = shouldShow);
  }

  Future<void> _scrollToTop() => GoToTopButton.animateToTop(_scrollController);

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
      await context.read<UpdatesCubit>().loadUpdates(
            silent: true,
            forceRefresh: true,
          );
    } finally {
      _isSilentRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0.8.h),
              child: Text(
                'Work Updates',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<UpdatesCubit, UpdatesState>(
                builder: (context, state) {
                  if (state is UpdatesLoading || state is UpdatesInitial) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: 1.h,
                        left: 4.w,
                        right: 4.w,
                        bottom: 2.h,
                      ),
                      itemCount: UserUpdatesScreen._shimmerCardCount,
                      itemBuilder: (_, _) => const _UpdateCardShimmer(),
                    );
                  }

                  if (state is UpdatesFailure) {
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
                                  .read<UpdatesCubit>()
                                  .loadUpdates(forceRefresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final updates = state is UpdatesSuccess
                      ? state.updates
                      : <WorkUpdateModel>[];

                  if (updates.isEmpty) {
                    return Center(
                      child: Text(
                        'No work updates yet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () => context
                            .read<UpdatesCubit>()
                            .loadUpdates(forceRefresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            top: 1.h,
                            left: 4.w,
                            right: 4.w,
                            bottom: 2.h,
                          ),
                          itemCount: updates.length,
                          itemBuilder: (context, index) {
                            final item = updates[index];
                            return _UpdateCard(
                              update: item,
                              isActive: widget.isActive,
                            );
                          },
                        ),
                      ),
                      GoToTopOverlay(
                        visible: _showGoToTop &&
                            updates.length > _goToTopMinCardCount,
                        onTap: _scrollToTop,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateCardShimmer extends StatelessWidget {
  const _UpdateCardShimmer();

  static TextStyle get _titleStyle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.transparent,
      );

  static TextStyle get _descriptionStyle => TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: Colors.transparent,
      );

  static TextStyle get _timeStyle => TextStyle(
        fontSize: 12.5.sp,
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
                    color: UserUpdatesScreen._shimmerBase,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: UserUpdatesScreen._shimmerBase,
        highlightColor: UserUpdatesScreen._shimmerHighlight,
        direction: ShimmerDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.w),
                topRight: Radius.circular(5.w),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(color: UserUpdatesScreen._shimmerBase),
              ),
            ),
            // Mirrors _UpdateCard text block: title → description → timeline.
            Padding(
              padding: EdgeInsets.all(3.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _barLine(
                    placeholder: 'Title',
                    style: _titleStyle,
                    widthFactor: 0.45,
                  ),
                  SizedBox(height: 0.5.h),
                  _barLine(
                    placeholder: 'Description',
                    style: _descriptionStyle,
                    widthFactor: 0.6,
                  ),
                  SizedBox(height: 0.4.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        ImageConstants.timeLine,
                        width: 3.5.w,
                        height: 3.5.w,
                        colorFilter: const ColorFilter.mode(
                          UserUpdatesScreen._shimmerBase,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Text(
                              'Uploaded just now',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _timeStyle,
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: 0.55,
                                  heightFactor: 0.72,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: UserUpdatesScreen._shimmerBase,
                                      borderRadius: BorderRadius.circular(1.w),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final WorkUpdateModel update;
  final bool isActive;

  const _UpdateCard({
    required this.update,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final mediaUrl = update.resolvedFileUrl;
    final description = update.description.trim();

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.w),
              topRight: Radius.circular(5.w),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildMedia(context, mediaUrl),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                  ),
                ],
                SizedBox(height: 0.4.h),
                Row(
                  children: [
                    SvgPicture.asset(
                      ImageConstants.timeLine,
                      width: 3.5.w,
                      height: 3.5.w,
                      colorFilter: ColorFilter.mode(
                        Colors.grey[500]!,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      update.uploadedLabel,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context, String? mediaUrl) {
    if (update.isVideo && mediaUrl != null) {
      if (!isActive) {
        return Container(
          color: Colors.grey[300],
          child: Icon(
            Icons.videocam_rounded,
            color: Colors.grey[600],
            size: 10.w,
          ),
        );
      }

      return WorkUpdateInlineVideo(
        key: ValueKey('work-update-video-${update.workUpdateId}'),
        videoUrl: mediaUrl,
        title: update.title,
        fileName: update.fileName,
      );
    }

    if (update.isImage && mediaUrl != null) {
      return GestureDetector(
        onTap: () => openWorkUpdateFullscreenImage(
          context,
          imageUrl: mediaUrl,
          title: update.title,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: mediaUrl,
              cacheManager: WorkUpdateMediaCache.manager,
              httpHeaders: WorkUpdateMediaCache.authHeaders(),
              fit: BoxFit.cover,
              placeholder: (context, url) => const _MediaShimmer(),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      ImageConstants.imageError,
                      width: 10.w,
                      height: 10.w,
                      colorFilter: ColorFilter.mode(
                        Colors.grey[600]!,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      'Unable to load image',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 2.w,
              bottom: 1.2.h,
              child: Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  ImageConstants.view,
                  width: 4.5.w,
                  height: 4.5.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.insert_drive_file_rounded,
        color: Colors.grey[600],
        size: 10.w,
      ),
    );
  }
}

class _MediaShimmer extends StatelessWidget {
  const _MediaShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: UserUpdatesScreen._shimmerBase,
      highlightColor: UserUpdatesScreen._shimmerHighlight,
      direction: ShimmerDirection.ltr,
      child: const ColoredBox(color: UserUpdatesScreen._shimmerBase),
    );
  }
}
