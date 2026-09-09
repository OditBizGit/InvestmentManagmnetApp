import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(0.6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 11.w,
                  backgroundImage: const NetworkImage(
                    'https://randomuser.me/api/portraits/men/32.jpg',
                  ),
                ),
              ),
              SizedBox(height: 1.8.h),
              Text(
                'John Mathew',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 0.7.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(5.w),
                ),
                child: Text(
                  'INV - 10254',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(height: 2.8.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Total Collection',
                      value: '₹2,50,000',
                      valueColor: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.handshake_outlined,
                      label: 'Total Commitment',
                      value: '₹50,000',
                      valueColor: AppColors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.2.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(3.5.w),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email Address',
                      value: 'john.mathew@investor.com',
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                      indent: 4.w,
                      endIndent: 4.w,
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: '+1 (555) 019-2834',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.5.h),
              _MenuTile(
                icon: Icons.badge_outlined,
                label: 'Personal Info',
                onTap: () {},
              ),
              _MenuTile(
                icon: Icons.show_chart_rounded,
                label: 'Investment Details',
                onTap: () {},
              ),
              _MenuTile(
                icon: Icons.description_outlined,
                label: 'Documents',
                onTap: () {},
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: AppColors.error,
                onTap: () {},
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 5.5.w),
          SizedBox(height: 1.4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: AppColors.cardBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 5.w),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.8.h),
        child: Row(
          children: [
            Icon(icon, size: 5.5.w, color: color),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 5.5.w,
              color: color == AppColors.error ? color : AppColors.hint,
            ),
          ],
        ),
      ),
    );
  }
}
