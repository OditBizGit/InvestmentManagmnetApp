import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class InvestorsTableSection extends StatefulWidget {
  const InvestorsTableSection({
    super.key,
    required this.investors,
    this.isLoading = false,
  });

  final List<InvestorModel> investors;
  final bool isLoading;

  @override
  State<InvestorsTableSection> createState() => _InvestorsTableSectionState();
}

class _InvestorsTableSectionState extends State<InvestorsTableSection> {
  static const double _minTableWidth = 980;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatAmount(double amount) {
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
            controller: _horizontalController,
            thumbVisibility: tableWidth > constraints.maxWidth,
            child: SingleChildScrollView(
              controller: _horizontalController,
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
                        child: widget.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accent,
                                ),
                              )
                            : widget.investors.isEmpty
                                ? Center(
                                    child: Text(
                                      'No investors found',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    controller: _verticalController,
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      controller: _verticalController,
                                      padding: EdgeInsets.zero,
                                      itemCount: widget.investors.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.cardBg,
                                      ),
                                      itemBuilder: (context, index) {
                                        final investor =
                                            widget.investors[index];
                                        return _InvestorRow(
                                          index: index,
                                          name: investor.fullName,
                                          type: investor.investorType ?? '-',
                                          mobile:
                                              investor.phoneNumber ?? '-',
                                          email: investor.email,
                                          investAmount: _formatAmount(
                                            investor.totalInvestmentAmount,
                                          ),
                                          paidAmount: _formatAmount(
                                            investor.totalPaidAmount,
                                          ),
                                          status: investor.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          joinedDate: _formatDate(
                                            investor.createdDate,
                                          ),
                                          profileImage:
                                              investor.profileImageUrl,
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
    required this.name,
    required this.type,
    required this.mobile,
    required this.email,
    required this.investAmount,
    required this.paidAmount,
    required this.status,
    required this.joinedDate,
    this.profileImage,
  });

  final int index;
  final String name;
  final String type;
  final String mobile;
  final String email;
  final String investAmount;
  final String paidAmount;
  final String status;
  final String joinedDate;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;
    final imageUrl = profileImage;

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
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              httpHeaders: const {
                                'Accept': 'image/*,*/*',
                              },
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
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
                            type,
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
              _Cell(mobile, flex: 3),
              _Cell(email, flex: 3),
              _Cell(investAmount, flex: 2),
              _Cell(paidAmount, flex: 2),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(status: status),
                ),
              ),
              _Cell(joinedDate, flex: 2),
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
    final bool active = status == 'Active';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.green.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          color: active ? AppColors.green : AppColors.error,
        ),
      ),
    );
  }
}
