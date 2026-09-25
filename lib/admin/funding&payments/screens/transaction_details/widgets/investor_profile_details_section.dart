import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_details_models.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/media_url.dart';
import 'package:sizer/sizer.dart';

class InvestorProfileDetailsSection extends StatelessWidget {
  const InvestorProfileDetailsSection({
    super.key,
    required this.details,
    required this.formatCurrency,
    required this.formatDate,
  });

  final InvestorDetailsModel details;
  final String Function(double amount) formatCurrency;
  final String Function(DateTime? date) formatDate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PersonalContactCard(details: details, formatDate: formatDate),
              const SizedBox(height: 14),
              _PendingScheduleCard(
                details: details,
                formatCurrency: formatCurrency,
                formatDate: formatDate,
                listMaxHeight: 260,
              ),
            ],
          );
        }

        return _EqualHeightDetailsPair(
          details: details,
          formatCurrency: formatCurrency,
          formatDate: formatDate,
        );
      },
    );
  }
}

/// Keeps both cards the same height; dues list scrolls inside its card.
class _EqualHeightDetailsPair extends StatefulWidget {
  const _EqualHeightDetailsPair({
    required this.details,
    required this.formatCurrency,
    required this.formatDate,
  });

  final InvestorDetailsModel details;
  final String Function(double amount) formatCurrency;
  final String Function(DateTime? date) formatDate;

  @override
  State<_EqualHeightDetailsPair> createState() =>
      _EqualHeightDetailsPairState();
}

class _EqualHeightDetailsPairState extends State<_EqualHeightDetailsPair> {
  final GlobalKey _leftKey = GlobalKey();
  double? _cardHeight;
  bool _measureScheduled = false;

  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted) return;
      final box =
          _leftKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final next = box.size.height;
      if (_cardHeight != null && (next - _cardHeight!).abs() < 1) return;
      setState(() => _cardHeight = next);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasure();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: KeyedSubtree(
            key: _leftKey,
            child: _PersonalContactCard(
              details: widget.details,
              formatDate: widget.formatDate,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _PendingScheduleCard(
            details: widget.details,
            formatCurrency: widget.formatCurrency,
            formatDate: widget.formatDate,
            height: _cardHeight,
            listMaxHeight: _cardHeight == null ? 260 : null,
          ),
        ),
      ],
    );
  }
}

class _PersonalContactCard extends StatelessWidget {
  const _PersonalContactCard({
    required this.details,
    required this.formatDate,
  });

  final InvestorDetailsModel details;
  final String Function(DateTime? date) formatDate;

  String get _initials {
    final parts = details.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get _maskedAccount {
    final account = details.accountNumber.trim();
    if (account.isEmpty) return '-';
    if (account.length <= 4) return account;
    return '•••• ${account.substring(account.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(details.profileImage);
    final email = details.email.trim().isNotEmpty ? details.email.trim() : '-';
    final phone =
        details.phoneNumber.trim().isNotEmpty ? details.phoneNumber.trim() : '-';
    final address =
        details.address.trim().isNotEmpty ? details.address.trim() : '-';
    final pan = details.panCardNumber.trim().isNotEmpty
        ? details.panCardNumber.trim()
        : '-';
    final bankName =
        details.bankName.trim().isNotEmpty ? details.bankName.trim() : '-';
    final ifsc =
        details.ifscCode.trim().isNotEmpty ? details.ifscCode.trim() : '-';
    final org = details.organization.trim().isNotEmpty
        ? details.organization.trim()
        : (details.investorType.trim().isNotEmpty
            ? details.investorType.trim()
            : '-');
    final investorCode = details.investorCode.trim().isNotEmpty
        ? details.investorCode.trim()
        : '-';
    final roleLine = [
      if (details.investorType.trim().isNotEmpty) details.investorType.trim(),
      if (details.organization.trim().isNotEmpty) details.organization.trim(),
    ].join(' — ');

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.badge_outlined,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Personal & Contact Information',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: imageUrl == null
                      ? Text(
                          _initials,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            details.fullName.trim().isNotEmpty
                                ? details.fullName.trim()
                                : 'Unknown',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (details.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: AppColors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (roleLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          roleLine,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Investor ID: $investorCode',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 420;
              final emailTile = _InfoTile(
                label: 'EMAIL ADDRESS',
                value: email,
                icon: Icons.mail_outline_rounded,
                trailing: email.contains('@')
                    ? const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.green,
                      )
                    : null,
              );
              final phoneTile = _InfoTile(
                label: 'PHONE NUMBER',
                value: phone,
                icon: Icons.phone_outlined,
              );
              final addressTile = _InfoTile(
                label: 'RESIDENTIAL / BUSINESS ADDRESS',
                value: address,
                icon: Icons.location_on_outlined,
              );
              final panTile = _InfoTile(
                label: 'PAN / TAX ID',
                value: pan,
                icon: Icons.credit_card_outlined,
              );
              final bankTile = _InfoTile(
                label: 'BANK ACCOUNT',
                value: '$bankName $_maskedAccount',
                subValue: 'IFSC: $ifsc',
                icon: Icons.account_balance_outlined,
              );
              final projectTile = _InfoTile(
                label: 'ORGANIZATION / TYPE',
                value: org,
                icon: Icons.apartment_outlined,
              );
              final agreementTile = _InfoTile(
                label: 'INVESTMENT DATE',
                value: formatDate(details.investmentDate ?? details.createdDate),
                icon: Icons.description_outlined,
              );

              if (!twoCol) {
                return Column(
                  children: [
                    emailTile,
                    const SizedBox(height: 10),
                    phoneTile,
                    const SizedBox(height: 10),
                    addressTile,
                    const SizedBox(height: 10),
                    panTile,
                    const SizedBox(height: 10),
                    bankTile,
                    const SizedBox(height: 10),
                    projectTile,
                    const SizedBox(height: 10),
                    agreementTile,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: emailTile),
                      const SizedBox(width: 10),
                      Expanded(child: phoneTile),
                    ],
                  ),
                  const SizedBox(height: 10),
                  addressTile,
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: panTile),
                      const SizedBox(width: 10),
                      Expanded(child: bankTile),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: projectTile),
                      const SizedBox(width: 10),
                      Expanded(child: agreementTile),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Encrypted Institutional Master Ledger Record',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingScheduleCard extends StatelessWidget {
  const _PendingScheduleCard({
    required this.details,
    required this.formatCurrency,
    required this.formatDate,
    this.height,
    this.listMaxHeight,
  });

  final InvestorDetailsModel details;
  final String Function(double amount) formatCurrency;
  final String Function(DateTime? date) formatDate;

  /// When set (side-by-side), card matches the personal-info card height.
  final double? height;

  /// Fallback scroll viewport when [height] is not yet measured / stacked.
  final double? listMaxHeight;

  @override
  Widget build(BuildContext context) {
    final committed = details.investmentAmount;
    final paid = details.totalPaidAmount;
    final progress = committed > 0 ? (paid / committed).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(1);

    final pendingDues = details.dueDates.where((d) {
      final status = d.status.toLowerCase();
      return status.contains('pending') ||
          status.contains('due') ||
          status.contains('schedul') ||
          d.pendingAmount > 0;
    }).toList();

    final dueSoonCount = pendingDues.length;

    final header = Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.calendar_month_outlined,
            size: 16,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Pending Schedule & Dues',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (dueSoonCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$dueSoonCount Due',
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );

    final progressBlock = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fulfillment Progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$progressPercent% Complete',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE4DCEA),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Collected: ${formatCurrency(paid)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Target: ${formatCurrency(committed)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget duesList({required bool expand}) {
      if (pendingDues.isEmpty) {
        return Text(
          'No pending dues',
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textMuted,
          ),
        );
      }

      final list = ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: pendingDues.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final due = pendingDues[i];
          return _MilestoneItem(
            title: 'Installment ${due.installmentNumber}',
            description: due.status.trim().isNotEmpty
                ? due.status
                : 'Scheduled installment',
            amount: formatCurrency(
              due.pendingAmount > 0
                  ? due.pendingAmount
                  : due.installmentAmount,
            ),
            amountColor: AppColors.error,
            badgeLabel:
                due.status.trim().isNotEmpty ? due.status : 'Pending',
            badgeColor: AppColors.error,
            badgeBg: const Color(0xFFFDECEE),
            dueLabel: 'Due: ${formatDate(due.dueDate)}',
            metaLabel: 'Paid: ${formatCurrency(due.paidAmount)}',
          );
        },
      );

      if (expand) {
        return Expanded(child: list);
      }
      return SizedBox(
        height: listMaxHeight ?? 260,
        child: list,
      );
    }

    final actions = LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 360;
        final reminder = _SoftActionButton(
          label: 'Send Due Reminder',
          icon: Icons.mail_outline_rounded,
          background: const Color(0xFFF0EBF6),
          foreground: AppColors.accent,
          onTap: () {},
        );
        final invoice = _SoftActionButton(
          label: 'Generate Invoice',
          icon: Icons.description_outlined,
          background: const Color(0xFFEAF1FC),
          foreground: const Color(0xFF3D4F6F),
          onTap: () {},
        );

        if (stacked) {
          return Column(
            children: [
              reminder,
              const SizedBox(height: 10),
              invoice,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: reminder),
            const SizedBox(width: 10),
            Expanded(child: invoice),
          ],
        );
      },
    );

    final useFixedHeight = height != null && height! > 0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 14),
        progressBlock,
        const SizedBox(height: 12),
        duesList(expand: useFixedHeight),
        const SizedBox(height: 14),
        actions,
      ],
    );

    final card = _SectionCard(
      expand: useFixedHeight,
      child: content,
    );

    if (useFixedHeight) {
      return SizedBox(height: height, child: card);
    }
    return card;
  }
}

class _MilestoneItem extends StatelessWidget {
  const _MilestoneItem({
    required this.title,
    required this.description,
    required this.amount,
    required this.amountColor,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    required this.dueLabel,
    required this.metaLabel,
  });

  final String title;
  final String description;
  final String amount;
  final Color amountColor;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final String dueLabel;
  final String metaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dueLabel,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                metaLabel,
                style: TextStyle(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftActionButton extends StatelessWidget {
  const _SoftActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: foreground,
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.subValue,
    this.trailing,
  });

  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subValue != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subValue!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ] else ...[
                      // Keep single-line tiles aligned with multi-line bank tile.
                      const SizedBox(height: 2),
                      Text(
                        ' ',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.expand = false,
  });

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: expand ? double.infinity : null,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
