import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class DashboardDetailsSection extends StatelessWidget {
  const DashboardDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        if (isNarrow) {
          return const Column(
            children: [
              _FundingOverviewCard(),
              SizedBox(height: 14),
              _HospitalWorkProgressCard(),
              SizedBox(height: 14),
              _TopRatedInvestorsCard(),
            ],
          );
        }

        return const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _FundingOverviewCard()),
              SizedBox(width: 14),
              Expanded(child: _HospitalWorkProgressCard()),
              SizedBox(width: 14),
              Expanded(child: _TopRatedInvestorsCard()),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FundingOverviewCard extends StatelessWidget {
  const _FundingOverviewCard();

  static const double progress = 0.65;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Funding Overview',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: const Color(0xFFEDEDED),
                      color: AppColors.green,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '65%',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                      Text(
                        'Of Goal',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _FundingLegendItem(
            color: AppColors.green,
            label: 'Funding Overview',
            value: '₹65,50,00,000 (65%)',
          ),
          const SizedBox(height: 14),
          const _FundingLegendItem(
            color: Color(0xFFD9D9D9),
            label: 'Amount Remaining',
            value: '₹63,50,00,000 (35%)',
          ),
        ],
      ),
    );
  }
}

class _FundingLegendItem extends StatelessWidget {
  const _FundingLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HospitalWorkProgressCard extends StatelessWidget {
  const _HospitalWorkProgressCard();

  static const List<_WorkProgressItem> _items = [
    _WorkProgressItem(label: 'Foundation', percent: 100, color: AppColors.green),
    _WorkProgressItem(label: 'Structure', percent: 85, color: AppColors.green),
    _WorkProgressItem(
      label: 'Electrical',
      percent: 60,
      color: Color(0xFFF2C94C),
    ),
    _WorkProgressItem(
      label: 'Pluming',
      percent: 45,
      color: Color(0xFFE57373),
    ),
    _WorkProgressItem(
      label: 'Interior',
      percent: 20,
      color: Color(0xFFE57373),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Work Progress',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _WorkProgressRow(item: _items[i]),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '68%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
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

class _WorkProgressItem {
  const _WorkProgressItem({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;
}

class _WorkProgressRow extends StatelessWidget {
  const _WorkProgressRow({required this.item});

  final _WorkProgressItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Text(
              '${item.percent}%',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: item.percent / 100,
            minHeight: 7,
            backgroundColor: const Color(0xFFEDEDED),
            color: item.color,
          ),
        ),
      ],
    );
  }
}

class _TopRatedInvestorsCard extends StatelessWidget {
  const _TopRatedInvestorsCard();

  static const List<_InvestorItem> _investors = [
    _InvestorItem(name: 'Corey Herwitz', amount: '2,00,00,00'),
    _InvestorItem(name: 'Alfredo Curtis', amount: '2,00,00,00'),
    _InvestorItem(name: 'Talan Baptista', amount: '2,00,00,00'),
    _InvestorItem(name: 'Alfonso Herwitz', amount: '2,00,00,00'),
    _InvestorItem(name: 'Terry Rosser', amount: '2,00,00,00'),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Top Rated Investors',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.accent,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _investors.length; i++) ...[
            _InvestorRow(item: _investors[i]),
            if (i < _investors.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _InvestorItem {
  const _InvestorItem({required this.name, required this.amount});

  final String name;
  final String amount;
}

class _InvestorRow extends StatelessWidget {
  const _InvestorRow({required this.item});

  final _InvestorItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.cardBg,
            child: Text(
              item.name.isNotEmpty ? item.name[0] : '?',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Invested',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Paid 100%',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.amount,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
