import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/home/model/home_profile_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class InvestmentSummaryCard extends StatelessWidget {
  const InvestmentSummaryCard({
    super.key,
    this.isLoading = false,
    this.profile,
  });

  final bool isLoading;
  final HomeProfileModel? profile;

  static const Color _accent = Color(0xFFA28CC1);
  static const Color _cardBg = Color(0xFFF0EBF6);
  static const Color _green = Color(0xFF1BA752);
  static const Color _textSecondary = Color(0xFF8A8099);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: isLoading
          ? const _LoadingBody()
          : _InvestmentSummaryBody(profile: profile),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _InvestmentSummaryBody(
          isLoading: true,
          headerOpacity: 0,
        ),
        Shimmer.fromColors(
          baseColor: InvestmentSummaryCard._shimmerBase,
          highlightColor: InvestmentSummaryCard._shimmerHighlight,
          direction: ShimmerDirection.ltr,
          period: const Duration(milliseconds: 1400),
          child: const _InvestmentSummaryBody(
            isLoading: true,
            tileColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _InvestmentSummaryBody extends StatelessWidget {
  const _InvestmentSummaryBody({
    this.isLoading = false,
    this.tileColor = Colors.white,
    this.headerOpacity = 1,
    this.profile,
  });

  final bool isLoading;
  final Color tileColor;
  final double headerOpacity;
  final HomeProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: headerOpacity,
          child: _ProfileHeader(
            isLoading: isLoading,
            profile: profile,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                isLoading: isLoading,
                tileColor: tileColor,
                iconPath: ImageConstants.totalCollection,
                label: 'Total Collection',
                amount: _formatCurrency(profile?.totalCollection ?? 0),
                amountColor: Colors.black87,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _StatCard(
                isLoading: isLoading,
                tileColor: tileColor,
                iconPath: ImageConstants.totalCommitment,
                label: 'Total Commitment',
                amount: _formatCurrency(profile?.totalCommitment ?? 0),
                amountColor: InvestmentSummaryCard._green,
              ),
            ),
          ],
        ),
      ],
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isLoading,
    this.profile,
  });

  final bool isLoading;
  final HomeProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 15.5.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );
    final badgeStyle = TextStyle(
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    final imageUrl = isLoading ? null : profile?.profileImageUrl;
    final displayName = profile?.displayName ?? 'Investor';
    final investorCode = profile?.investorCode?.trim();
    final displayCode =
        (investorCode != null && investorCode.isNotEmpty) ? investorCode : '';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(0.4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isLoading ? Colors.white : InvestmentSummaryCard._accent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 9.w,
            backgroundColor: Colors.white,
            backgroundImage:
                imageUrl == null ? null : NetworkImage(imageUrl),
            child: isLoading || imageUrl != null
                ? null
                : Icon(
                    Icons.person_outline_rounded,
                    size: 9.w,
                    color: InvestmentSummaryCard._accent,
                  ),
          ),
        ),
        SizedBox(height: 0.8.h),
        if (isLoading)
          _PlaceholderLine(
            sample: 'John Mathew',
            style: nameStyle,
            alignment: Alignment.center,
            widthFactor: 0.72,
          )
        else
          Text(displayName, style: nameStyle),
        SizedBox(height: 0.5.h),
        if (isLoading)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INV - 10254',
              style: badgeStyle.copyWith(color: Colors.transparent),
            ),
          )
        else if (displayCode.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: InvestmentSummaryCard._accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displayCode.toUpperCase().startsWith('INV-')
                  ? displayCode
                  : 'INV - $displayCode',
              style: badgeStyle,
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconPath,
    required this.label,
    required this.amount,
    required this.amountColor,
    this.isLoading = false,
    this.tileColor = Colors.white,
  });

  final String iconPath;
  final String label;
  final String amount;
  final Color amountColor;
  final bool isLoading;
  final Color tileColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: InvestmentSummaryCard._textSecondary,
    );
    final amountStyle = TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w700,
      color: amountColor,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
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
                InvestmentSummaryCard._accent,
                BlendMode.srcIn,
              ),
            ),
          SizedBox(height: 0.8.h),
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
              sample: '₹2,50,000',
              style: amountStyle,
              widthFactor: 0.88,
              heightFactor: 0.82,
            )
          else
            Text(amount, style: amountStyle),
        ],
      ),
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  const _PlaceholderLine({
    required this.sample,
    required this.style,
    this.widthFactor = 0.8,
    this.heightFactor = 0.68,
    this.alignment = Alignment.centerLeft,
  });

  final String sample;
  final TextStyle style;
  final double widthFactor;
  final double heightFactor;
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
              heightFactor: heightFactor,
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
