import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
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
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0.5.h),
              child: const _HomeHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _InvestmentSummaryCardHost(),
                    SizedBox(height: 2.5.h),
                    const _TopInvestorsCarouselHost(),
                    SizedBox(height: 2.h),
                    const _ServiceGalleryCarouselHost(),
                    SizedBox(height: 2.h),
                    const _PhaseProgressCardHost(),
                    SizedBox(height: 2.5.h),
                    const _LatestProjectUpdatesHost(),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSectionLoadingHost extends StatefulWidget {
  const _HomeSectionLoadingHost({required this.builder});

  final Widget Function(bool isLoading) builder;

  @override
  State<_HomeSectionLoadingHost> createState() =>
      _HomeSectionLoadingHostState();
}

class _HomeSectionLoadingHostState extends State<_HomeSectionLoadingHost> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 8400), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_isLoading);
  }
}

class _InvestmentSummaryCardHost extends StatelessWidget {
  const _InvestmentSummaryCardHost();

  @override
  Widget build(BuildContext context) {
    return _HomeSectionLoadingHost(
      builder: (isLoading) => InvestmentSummaryCard(isLoading: isLoading),
    );
  }
}

class _TopInvestorsCarouselHost extends StatelessWidget {
  const _TopInvestorsCarouselHost();

  @override
  Widget build(BuildContext context) {
    return _HomeSectionLoadingHost(
      builder: (isLoading) => TopInvestorsCarousel(isLoading: isLoading),
    );
  }
}

class _ServiceGalleryCarouselHost extends StatelessWidget {
  const _ServiceGalleryCarouselHost();

  @override
  Widget build(BuildContext context) {
    return _HomeSectionLoadingHost(
      builder: (isLoading) => ServiceGalleryCarousel(isLoading: isLoading),
    );
  }
}

class _PhaseProgressCardHost extends StatelessWidget {
  const _PhaseProgressCardHost();

  @override
  Widget build(BuildContext context) {
    return _HomeSectionLoadingHost(
      builder: (isLoading) => PhaseProgressCard(isLoading: isLoading),
    );
  }
}

class _LatestProjectUpdatesHost extends StatelessWidget {
  const _LatestProjectUpdatesHost();

  @override
  Widget build(BuildContext context) {
    return _HomeSectionLoadingHost(
      builder: (isLoading) => LatestProjectUpdates(isLoading: isLoading),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

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
                      text: 'John Mathew',
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
                'Here is the latest status of your hospital investment',
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
