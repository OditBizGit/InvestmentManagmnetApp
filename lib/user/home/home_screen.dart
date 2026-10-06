import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/commitment_completed_overlay.dart';
import 'package:maribel_wellness_centre_application/user/home/cubit/home_cubit.dart';
import 'package:maribel_wellness_centre_application/user/home/model/banner_item_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/top_investor_model.dart';
import 'package:maribel_wellness_centre_application/user/home/model/work_progress_item_model.dart';
import 'package:maribel_wellness_centre_application/user/home/notification_screen.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/investment_summary_card.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/latest_project_updates.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/work_progress_card.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/service_gallery_carousel.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/top_investors_carousel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the user [IndexedStack].
  final bool isActive;

  static const Color _textPrimary = Color(0xFF4A3F5C);
  static const Color _textSecondary = Color(0xFF8A8099);
  static const Color _accent = Color(0xFFA28CC1);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadHome(),
      child: _UserHomeView(isActive: isActive),
    );
  }
}

class _UserHomeView extends StatefulWidget {
  const _UserHomeView({required this.isActive});

  final bool isActive;

  @override
  State<_UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<_UserHomeView> {
  static const _silentRefreshInterval = Duration(seconds: 5);

  Timer? _silentRefreshTimer;
  bool _isSilentRefreshing = false;
  bool _commitmentOverlayShown = false;
  bool _isShowingCommitmentOverlay = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _startSilentRefresh();
    }
  }

  @override
  void didUpdateWidget(covariant _UserHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;

    if (widget.isActive) {
      _startSilentRefresh();
      // Pull fresh home data (including latest work update) when tab opens.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isActive) return;
        context.read<HomeCubit>().loadHome(silent: true);
      });
    } else {
      _stopSilentRefresh();
    }
  }

  @override
  void dispose() {
    _stopSilentRefresh();
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
      await context.read<HomeCubit>().loadHome(silent: true);
    } finally {
      _isSilentRefreshing = false;
    }
  }

  Future<void> _maybeShowCommitmentOverlay({
    required double totalCollection,
    required double totalCommitment,
  }) async {
    if (_commitmentOverlayShown ||
        _isShowingCommitmentOverlay ||
        !isCommitmentFullyCollected(
          totalCollection: totalCollection,
          totalCommitment: totalCommitment,
        )) {
      return;
    }

    _isShowingCommitmentOverlay = true;
    _commitmentOverlayShown = true;
    try {
      await showCommitmentCompletedOverlay(context);
    } finally {
      _isShowingCommitmentOverlay = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is HomeFailure) {
              AppSnackBar.show(
                context,
                message: state.message,
                icon: Icons.error_outline_rounded,
              );
              return;
            }

            if (state is HomeSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _maybeShowCommitmentOverlay(
                  totalCollection: state.profile.totalCollection,
                  totalCommitment: state.profile.totalCommitment,
                );
              });
            }
          },
          builder: (context, state) {
            final isLoading =
                state is HomeInitial || state is HomeLoading;
            final profile =
                state is HomeSuccess ? state.profile : null;
            final topInvestors = state is HomeSuccess
                ? state.topInvestors
                : const <TopInvestorModel>[];
            final workProgress = state is HomeSuccess
                ? state.workProgress
                : const <WorkProgressItemModel>[];
            final banners = state is HomeSuccess
                ? state.banners
                : const <BannerItemModel>[];
            final latestUpdate =
                state is HomeSuccess ? state.latestUpdate : null;
            final unreadCount = state is HomeSuccess
                ? state.unreadNotificationCount
                : 0;
            final summaryKey = profile == null
                ? 'loading'
                : '${profile.totalCollection}_${profile.totalCommitment}_'
                    '${profile.displayName}_${profile.investorCode}_'
                    '${profile.profileImageUrl}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0.5.h),
                  child: _HomeHeader(
                    isLoading: isLoading,
                    displayName: profile?.displayName ?? 'Investor',
                    unreadCount: unreadCount,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: UserHomeScreen._accent,
                    onRefresh: () =>
                        context.read<HomeCubit>().loadHome(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.5.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InvestmentSummaryCard(
                            key: ValueKey(summaryKey),
                            isLoading: isLoading,
                            profile: profile,
                          ),
                          SizedBox(height: 2.5.h),
                          TopInvestorsCarousel(
                            isLoading: isLoading,
                            investors: topInvestors,
                          ),
                          SizedBox(height: 2.h),
                          if (isLoading || banners.isNotEmpty) ...[
                            ServiceGalleryCarousel(
                              isLoading: isLoading,
                              banners: banners,
                            ),
                            SizedBox(height: 2.h),
                          ],
                          WorkProgressCard(
                            isLoading: isLoading,
                            items: workProgress,
                          ),
                          if (isLoading || latestUpdate != null) ...[
                            SizedBox(height: 2.5.h),
                            LatestProjectUpdates(
                              isLoading: isLoading,
                              isActive: widget.isActive,
                              latestUpdate: latestUpdate,
                            ),
                          ],
                          SizedBox(height: 1.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.isLoading,
    required this.displayName,
    required this.unreadCount,
  });

  final bool isLoading;
  final String displayName;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const _HomeHeaderShimmer()
              else
                _HomeHeaderText(displayName: displayName),
            ],
          ),
        ),
        SizedBox(width: 2.w),
        InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationScreen(),
              ),
            );
            if (!context.mounted) return;
            context.read<HomeCubit>().refreshUnreadCount();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(1.w),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  ImageConstants.notification,
                  width: 5.5.w,
                  height: 5.5.w,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -0.7.w,
                    top: -1.2.w,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 3.3.w,
                        minHeight: 3.3.w,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeaderText extends StatelessWidget {
  const _HomeHeaderText({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Hi, ',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: UserHomeScreen._accent,
            ),
            children: [
              TextSpan(
                text: displayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: UserHomeScreen._textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.1.h),
        Text(
          'Here is the latest status of your investment',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: UserHomeScreen._textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _HomeHeaderShimmer extends StatelessWidget {
  const _HomeHeaderShimmer();

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      direction: ShimmerDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Hi, ',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.transparent,
                ),
                children: const [
                  TextSpan(
                    text: 'INVESTOR',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 0.1.h),
          Container(
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Here is the latest status of your investment',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.transparent,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
