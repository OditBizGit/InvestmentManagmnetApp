import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/user_logout_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/cubit/profile_cubit.dart';
import 'package:maribel_wellness_centre_application/user/profile/documents_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/investment_details_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/personal_info_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: const _UserProfileView(),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

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

  static String _formatCurrency(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw = isWhole
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final digits = parts.first;
    final withCommas = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }

  static String _investorCodeLabel(String? code) {
    if (code == null || code.isEmpty) return '—';
    final trimmed = code.trim();
    if (trimmed.toUpperCase().startsWith('INV')) return trimmed;
    return 'INV - $trimmed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              AppSnackBar.show(
                context,
                message: state.message,
                icon: Icons.error_outline_rounded,
              );
            }
          },
          builder: (context, state) {
            final isLoading =
                state is ProfileInitial || state is ProfileLoading;
            final details =
                state is ProfileSuccess ? state.details : null;

            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () =>
                  context.read<ProfileCubit>().loadProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                child: Column(
                  children: [
                    if (isLoading)
                      const _ProfileDetailsShimmer()
                    else
                      _ProfileDetailsContent(
                        details: details,
                        formatCurrency: _formatCurrency,
                        investorCodeLabel: _investorCodeLabel,
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
            );
          },
        ),
      ),
    );
  }
}

class _ProfileDetailsContent extends StatelessWidget {
  const _ProfileDetailsContent({
    required this.details,
    required this.formatCurrency,
    required this.investorCodeLabel,
  });

  final InvestorDetailsModel? details;
  final String Function(double) formatCurrency;
  final String Function(String?) investorCodeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileAvatar(imageUrl: details?.profileImageUrl),
        SizedBox(height: 1.h),
        Text(
          details?.fullName.isNotEmpty == true
              ? details!.fullName
              : 'Investor',
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
            investorCodeLabel(details?.investorCode),
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
                value: formatCurrency(details?.totalPaidAmount ?? 0),
                valueColor: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: _StatCard(
                iconPath: ImageConstants.totalCommitment,
                label: 'Total Commitment',
                value: formatCurrency(details?.investmentAmount ?? 0),
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
                value: details?.email.isNotEmpty == true
                    ? details!.email
                    : '—',
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
                value: details?.phoneNumber?.isNotEmpty == true
                    ? details!.phoneNumber!
                    : '—',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileDetailsShimmer extends StatelessWidget {
  const _ProfileDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
    final badgeStyle = TextStyle(
      color: AppColors.white,
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );

    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: UserProfileScreen._shimmerBase,
          highlightColor: UserProfileScreen._shimmerHighlight,
          direction: ShimmerDirection.ltr,
          period: const Duration(milliseconds: 1400),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(0.2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 12.w,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 1.h),
              _PlaceholderLine(
                sample: 'John Mathew',
                style: nameStyle,
                alignment: Alignment.center,
                widthFactor: 0.72,
              ),
              SizedBox(height: 0.5.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  'INV - 10254',
                  style: badgeStyle.copyWith(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.5.h),
        Row(
          children: [
            const Expanded(
              child: _StatCard(
                iconPath: ImageConstants.totalCollection,
                label: 'Total Collection',
                value: '₹2,50,000',
                valueColor: AppColors.textPrimary,
                isLoading: true,
              ),
            ),
            SizedBox(width: 3.5.w),
            const Expanded(
              child: _StatCard(
                iconPath: ImageConstants.totalCommitment,
                label: 'Total Commitment',
                value: '₹50,000',
                valueColor: AppColors.green,
                isLoading: true,
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
          child: const Column(
            children: [
              _InfoTile(
                iconPath: ImageConstants.email,
                label: 'Email Address',
                value: 'john.mathew@investor.com',
                isLoading: true,
              ),
              _InfoTileDivider(),
              _InfoTile(
                iconPath: ImageConstants.phone,
                label: 'Phone Number',
                value: '+91 9876543210',
                isLoading: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTileDivider extends StatelessWidget {
  const _InfoTileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 4.w,
      endIndent: 4.w,
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(0.2.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 12.w,
        backgroundColor: AppColors.cardBg,
        backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
        child: hasImage
            ? null
            : Icon(
                Icons.person_rounded,
                size: 10.w,
                color: AppColors.accent,
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
    this.isLoading = false,
  });

  final String iconPath;
  final String label;
  final String value;
  final Color valueColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
    );
    final valueStyle = TextStyle(
      fontSize: 15.5.sp,
      fontWeight: FontWeight.w700,
      color: valueColor,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          Container(
            width: 5.5.w,
            height: 5.5.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          )
        else
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
        if (isLoading)
          _PlaceholderLine(
            sample: label,
            style: labelStyle,
            widthFactor: 0.78,
          )
        else
          Text(label, style: labelStyle),
        SizedBox(height: 0.1.h),
        if (isLoading)
          _PlaceholderLine(
            sample: value,
            style: valueStyle,
            widthFactor: 0.7,
          )
        else
          Text(value, style: valueStyle),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.border),
      ),
      child: isLoading
          ? Shimmer.fromColors(
              baseColor: UserProfileScreen._shimmerBase,
              highlightColor: UserProfileScreen._shimmerHighlight,
              direction: ShimmerDirection.ltr,
              period: const Duration(milliseconds: 1400),
              child: content,
            )
          : content,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.iconPath,
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final String iconPath;
  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
    );
    final valueStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    final content = Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isLoading ? Colors.white : AppColors.cardBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? null
              : SvgPicture.asset(
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
              if (isLoading)
                _PlaceholderLine(
                  sample: label,
                  style: labelStyle,
                  widthFactor: 0.45,
                )
              else
                Text(label, style: labelStyle),
              SizedBox(height: 0.2.h),
              if (isLoading)
                _PlaceholderLine(
                  sample: value,
                  style: valueStyle,
                  widthFactor: 0.85,
                )
              else
                Text(value, style: valueStyle),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      child: isLoading
          ? Shimmer.fromColors(
              baseColor: UserProfileScreen._shimmerBase,
              highlightColor: UserProfileScreen._shimmerHighlight,
              direction: ShimmerDirection.ltr,
              period: const Duration(milliseconds: 1400),
              child: content,
            )
          : content,
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  const _PlaceholderLine({
    required this.sample,
    required this.style,
    this.widthFactor = 0.8,
    this.alignment = Alignment.centerLeft,
  });

  final String sample;
  final TextStyle style;
  final double widthFactor;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          sample,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: style.copyWith(color: Colors.transparent),
        ),
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: 0.68,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
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
