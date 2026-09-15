import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/user_logout_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/documents_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/investment_details_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/personal_info_screen.dart';
import 'package:sizer/sizer.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await showUserLogoutConfirmDialog(context);
    if (!confirmed || !context.mounted) return;

    await context.read<LoginCubit>().logout();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(
          home: UserMainScreen(),
          snackBarMessage: 'Logged out successfully',
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(0.2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 12.w,
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'John Mathew',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  'INV - 10254',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      iconPath: ImageConstants.totalCollection,
                      label: 'Total Collection',
                      value: '₹2,50,000',
                      valueColor: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: _StatCard(
                      iconPath: ImageConstants.totalCommitment,
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
                      iconPath: ImageConstants.email,
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
                      iconPath: ImageConstants.phone,
                      label: 'Phone Number',
                      value: '+91 9876543210',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.5.h),
              _MenuTile(
                iconPath: ImageConstants.personalInfo,
                label: 'Personal Info',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PersonalInfoScreen(),
                    ),
                  );
                },
              ),
              _MenuTile(
                iconPath: ImageConstants.investmentDetails,
                label: 'Investment Details',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const InvestmentDetailsScreen(),
                    ),
                  );
                },
              ),
              _MenuTile(
                iconPath: ImageConstants.documents,
                label: 'Documents',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DocumentsScreen(),
                    ),
                  );
                },
              ),
              _MenuTile(
                iconPath: ImageConstants.logout,
                label: 'Logout',
                color: AppColors.error,
                onTap: () => _onLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconPath,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String iconPath;
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
          SvgPicture.asset(
            iconPath,
            width: 5.5.w,
            height: 5.5.w,
            colorFilter: const ColorFilter.mode(
              AppColors.accent,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 0.1.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5.sp,
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
    required this.iconPath,
    required this.label,
    required this.value,
  });

  final String iconPath;
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
            alignment: Alignment.center,
            child: SvgPicture.asset(
              iconPath,
              width: 5.w,
              height: 5.w,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
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
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final String iconPath;
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
            SvgPicture.asset(
              iconPath,
              width: 5.5.w,
              height: 5.5.w,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5.sp,
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
