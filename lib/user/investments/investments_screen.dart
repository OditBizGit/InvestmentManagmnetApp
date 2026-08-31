import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/investments/widgets/recent_transactions_section.dart';
import 'package:maribel_wellness_centre_application/user/investments/widgets/work_progress_card.dart';
import 'package:sizer/sizer.dart';

class UserInvestmentsScreen extends StatelessWidget {
  const UserInvestmentsScreen({super.key});

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _accent = Color(0xFFA28CC1);
  static const Color _accentSoft = Color(0xFFF0EBF6);
  static const Color _green = Color(0xFF1BA752);
  static const Color _greenSoft = Color(0xFFE6F6EC);
  static const Color _red = Color(0xFFE05A4F);
  static const Color _border = Color(0xFFE8E4EE);
  static const Color _screenBg = Color(0xFFF7F6F9);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _screenBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InvestmentsHeader(),
              SizedBox(height: 2.h),
              const _ProjectHeroCard(),
              SizedBox(height: 1.8.h),
              const _InvestmentAmountCard(),
              SizedBox(height: 1.5.h),
              const _NextPaymentCard(),
              SizedBox(height: 1.5.h),
              const _CapitalAllocationCard(),
              SizedBox(height: 1.5.h),
              const WorkProgressCard(),
              SizedBox(height: 2.5.h),
              const RecentTransactionsSection(),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestmentsHeader extends StatelessWidget {
  const _InvestmentsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Investment',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: UserInvestmentsScreen._textPrimary,
          ),
        ),
        SizedBox(height: 1.2.h),
        Row(
          children: [
            _StatusChip(
              background: UserInvestmentsScreen._accentSoft,
              icon: Icons.work_outline_rounded,
              iconColor: UserInvestmentsScreen._accent,
              label: 'Investor ID: INV-10254',
              labelColor: UserInvestmentsScreen._accent,
            ),
            const Spacer(),
            _StatusChip(
              background: UserInvestmentsScreen._greenSoft,
              icon: Icons.check_circle_outline_rounded,
              iconColor: UserInvestmentsScreen._green,
              label: 'Active',
              labelColor: UserInvestmentsScreen._green,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 4.2.w, color: iconColor),
          SizedBox(width: 1.5.w),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeroCard extends StatelessWidget {
  const _ProjectHeroCard();

  static const String _imageUrl =
      'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=900&h=600&fit=crop';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: UserInvestmentsScreen._accentSoft,
                child: Icon(
                  Icons.apartment_outlined,
                  color: UserInvestmentsScreen._accent,
                  size: 12.w,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: UserInvestmentsScreen._accentSoft,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x99000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.45, 0.75, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metro Medical Center',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    'Phase 2 Expansion Project',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
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

class _InfoCardShell extends StatelessWidget {
  const _InfoCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UserInvestmentsScreen._border),
      ),
      child: child,
    );
  }
}

class _InvestmentAmountCard extends StatelessWidget {
  const _InvestmentAmountCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: UserInvestmentsScreen._textSecondary,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            '₹2,50,000',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: UserInvestmentsScreen._green,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPaymentCard extends StatelessWidget {
  const _NextPaymentCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Payment',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: UserInvestmentsScreen._textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 4.2.w,
                color: UserInvestmentsScreen._accent,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  '12 Aug, Mon-26',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: UserInvestmentsScreen._textPrimary,
                  ),
                ),
              ),
              Text(
                '₹50,000',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: UserInvestmentsScreen._accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapitalAllocationCard extends StatelessWidget {
  const _CapitalAllocationCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capital Allocation',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: UserInvestmentsScreen._textPrimary,
            ),
          ),
          SizedBox(height: 1.4.h),
          const _AllocationRow(
            label: 'Total Paid',
            amount: '₹1,50,000',
            amountColor: UserInvestmentsScreen._green,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Divider(
              height: 1,
              thickness: 1,
              color: UserInvestmentsScreen._border,
            ),
          ),
          const _AllocationRow(
            label: 'Total Balance',
            amount: '₹45,000',
            amountColor: UserInvestmentsScreen._red,
          ),
        ],
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  const _AllocationRow({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: UserInvestmentsScreen._textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
