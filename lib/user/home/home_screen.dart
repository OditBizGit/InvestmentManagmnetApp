import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/home/notification_screen.dart';
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
  static const Color _cardBg = Color(0xFFF0EBF6);
  static const Color _green = Color(0xFF1BA752);

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
                    const _InvestmentSummaryCard(),
                    SizedBox(height: 2.5.h),
                    const TopInvestorsCarousel(),
                    SizedBox(height: 2.h),
                    const ServiceGalleryCarousel(),
                    SizedBox(height: 2.h),
                    const PhaseProgressCard(),
                    SizedBox(height: 2.5.h),
                    const LatestProjectUpdates(),
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
                  text: 'Good Morning, ',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: UserHomeScreen._accent,
                  ),
                  children: [
                    TextSpan(
                      text: 'John',
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

class _InvestmentSummaryCard extends StatelessWidget {
  const _InvestmentSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
      decoration: BoxDecoration(
        color: UserHomeScreen._cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(0.4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: UserHomeScreen._accent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 9.w,
              backgroundColor: Colors.white,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
              ),
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'John Mathew',
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: UserHomeScreen._accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INV - 10254',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  iconPath: ImageConstants.totalCollection,
                  label: 'Total Collection',
                  amount: '₹2,50,000',
                  amountColor: Colors.black87,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _StatCard(
                  iconPath: ImageConstants.totalCommitment,
                  label: 'Total Commitment',
                  amount: '₹50,000',
                  amountColor: UserHomeScreen._green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconPath,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String iconPath;
  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 5.5.w,
            height: 5.5.w,
            colorFilter: const ColorFilter.mode(
              UserHomeScreen._accent,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: UserHomeScreen._textSecondary,
            ),
          ),
          SizedBox(height: 0.1.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
