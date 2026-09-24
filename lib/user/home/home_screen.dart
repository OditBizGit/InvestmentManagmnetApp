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
import 'package:maribel_wellness_centre_application/user/home/widgets/phase_progress_card.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/service_gallery_carousel.dart';
import 'package:maribel_wellness_centre_application/user/home/widgets/top_investors_carousel.dart';
import 'package:sizer/sizer.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  static const Color _textPrimary = Color(0xFF4A3F5C);
  static const Color _textSecondary = Color(0xFF8A8099);
  static const Color _accent = Color(0xFFA28CC1);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadHome(),
      child: const _UserHomeView(),
    );
  }
}

class _UserHomeView extends StatefulWidget {
  const _UserHomeView();

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
    _silentRefreshTimer = Timer.periodic(
      _silentRefreshInterval,
      (_) => _silentRefresh(),
    );
  }

  @override
  void dispose() {
    _silentRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _silentRefresh() async {
    if (!mounted || _isSilentRefreshing) return;

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
                    displayName: profile?.displayName ?? 'Investor',
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
                          PhaseProgressCard(
                            isLoading: isLoading,
                            items: workProgress,
                          ),
                          SizedBox(height: 2.5.h),
                          LatestProjectUpdates(isLoading: isLoading),
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
  const _HomeHeader({required this.displayName});

  final String displayName;

  static final int _notificationCount = NotificationScreen.unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        SizedBox(width: 2.w),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationScreen(),
              ),
            );
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
                if (_notificationCount > 0)
                  Positioned(
                    right: -1.2.w,
                    top: -1.2.w,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 4.w,
                        minHeight: 4.w,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: _notificationCount > 9 ? 1.w : 0.6.w,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _notificationCount > 99
                            ? '99+'
                            : '$_notificationCount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
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
