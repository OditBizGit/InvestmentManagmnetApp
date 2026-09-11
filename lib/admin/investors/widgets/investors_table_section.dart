import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class InvestorsTableSection extends StatelessWidget {
  const InvestorsTableSection({super.key});

  static const double _minTableWidth = 980;

  static const List<_Investor> _investors = [
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Complete',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
    _Investor(
      name: 'Corey Herwitz',
      type: 'Cooperate Investor',
      mobile: '+91 6545 7654 78',
      email: 'corey@gmail.com',
      investAmount: '₹20.000000',
      paidAmount: '₹1,0000',
      status: 'Pending',
      joinedDate: '03 Jun, 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = constraints.maxWidth < _minTableWidth
              ? _minTableWidth
              : constraints.maxWidth;

          return Scrollbar(
            thumbVisibility: tableWidth > constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    const _TableHeader(),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.screenBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBg),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: 540,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: _investors.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.cardBg,
                            ),
                            itemBuilder: (context, index) {
                              return _InvestorRow(
                                index: index,
                                investor: _investors[index],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          _HeaderCell('#', flex: 1),
          _HeaderCell('Investor Name', flex: 4),
          _HeaderCell('Mobile No', flex: 3),
          _HeaderCell('Email', flex: 3),
          _HeaderCell('Invest Amt', flex: 2),
          _HeaderCell('Paid Amt', flex: 2),
          _HeaderCell('Status', flex: 2),
          _HeaderCell('Joined Date', flex: 2),
          _HeaderCell('Action', flex: 1, align: TextAlign.center),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.title, {
    required this.flex,
    this.align = TextAlign.left,
  });

  final String title;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _InvestorRow extends StatelessWidget {
  const _InvestorRow({
    required this.index,
    required this.investor,
  });

  final int index;
  final _Investor investor;

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;

    return ColoredBox(
      color: isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _Cell('${index + 1}', flex: 1),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBg,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://i.pravatar.cc/100?img=${index + 11}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.textSecondary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            investor.type,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 7.5.sp,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _Cell(investor.mobile, flex: 3),
              _Cell(investor.email, flex: 3),
              _Cell(investor.investAmount, flex: 2),
              _Cell(investor.paidAmount, flex: 2),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(status: investor.status),
                ),
              ),
              _Cell(investor.joinedDate, flex: 2),
              Expanded(
                flex: 1,
                child: Center(
                  child: IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 16,
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bool complete = status == 'Complete';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: complete
            ? AppColors.green.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: complete ? AppColors.green : AppColors.error,
        ),
      ),
    );
  }
}

class _Investor {
  const _Investor({
    required this.name,
    required this.type,
    required this.mobile,
    required this.email,
    required this.investAmount,
    required this.paidAmount,
    required this.status,
    required this.joinedDate,
  });

  final String name;
  final String type;
  final String mobile;
  final String email;
  final String investAmount;
  final String paidAmount;
  final String status;
  final String joinedDate;
}
