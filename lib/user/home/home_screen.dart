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
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HomeHeader(),
            SizedBox(height: 2.h),
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
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: UserHomeScreen._textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: 'John',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: UserHomeScreen._textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 0.6.h),
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
            child: SvgPicture.asset(
              ImageConstants.notification,
              width: 5.5.w,
              height: 5.5.w,
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
          CircleAvatar(
            radius: 8.w,
            backgroundColor: Colors.white,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
            ),
          ),
          SizedBox(height: 1.2.h),
          Text(
            'John Mathew',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: UserHomeScreen._accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INV - 10254',
              style: TextStyle(
                fontSize: 12.sp,
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
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Total Collection',
                  amount: '₹2,50,000',
                  amountColor: Colors.black87,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _StatCard(
                  icon: Icons.credit_card_outlined,
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
    required this.icon,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final IconData icon;
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
          Icon(icon, color: UserHomeScreen._accent, size: 5.5.w),
          SizedBox(height: 0.8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: UserHomeScreen._textSecondary,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
