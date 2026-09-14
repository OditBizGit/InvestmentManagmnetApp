import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/widgets/funding_transactions_table.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class InvestorProfileDetailsSection extends StatelessWidget {
  const InvestorProfileDetailsSection({
    super.key,
    required this.transaction,
  });

  final FundingTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PersonalContactCard(transaction: transaction),
              const SizedBox(height: 14),
              const _PendingScheduleCard(),
            ],
          );
        }

        return _EqualHeightRow(
          leftBuilder: (fillHeight) => _PersonalContactCard(
            transaction: transaction,
            fillHeight: fillHeight,
          ),
          rightBuilder: (fillHeight) => _PendingScheduleCard(
            fillHeight: fillHeight,
          ),
        );
      },
    );
  }
}

/// Matches side-by-side card heights without IntrinsicHeight/Spacer crashes.
class _EqualHeightRow extends StatefulWidget {
  const _EqualHeightRow({
    required this.leftBuilder,
    required this.rightBuilder,
  });

  final Widget Function(bool fillHeight) leftBuilder;
  final Widget Function(bool fillHeight) rightBuilder;

  @override
  State<_EqualHeightRow> createState() => _EqualHeightRowState();
}

class _EqualHeightRowState extends State<_EqualHeightRow> {
  final _leftKey = GlobalKey();
  final _rightKey = GlobalKey();
  double? _matchedHeight;
  bool _syncScheduled = false;

  void _scheduleHeightSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;

      final leftBox =
          _leftKey.currentContext?.findRenderObject() as RenderBox?;
      final rightBox =
          _rightKey.currentContext?.findRenderObject() as RenderBox?;

      if (leftBox == null ||
          rightBox == null ||
          !leftBox.hasSize ||
          !rightBox.hasSize) {
        return;
      }

      final nextHeight = leftBox.size.height > rightBox.size.height
          ? leftBox.size.height
          : rightBox.size.height;

      if (_matchedHeight == nextHeight) return;
      setState(() => _matchedHeight = nextHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleHeightSync();
    final fillHeight = _matchedHeight != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: KeyedSubtree(
            key: _leftKey,
            child: SizedBox(
              height: _matchedHeight,
              child: widget.leftBuilder(fillHeight),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KeyedSubtree(
            key: _rightKey,
            child: SizedBox(
              height: _matchedHeight,
              child: widget.rightBuilder(fillHeight),
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonalContactCard extends StatelessWidget {
  const _PersonalContactCard({
    required this.transaction,
    this.fillHeight = false,
  });

  final FundingTransaction transaction;
  final bool fillHeight;

  String get _initials {
    final parts = transaction.party
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

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      fillHeight: fillHeight,
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
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.textMuted,
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
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
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
                            transaction.party,
                            style: TextStyle(
                              fontSize: 13.sp,
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
                                  'KYC Verified',
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
                      const SizedBox(height: 4),
                      Text(
                        'Lead Angel Investor — Phase 2 Oncology Wing',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Investor ID: #INV-2026-094',
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
              final email = _InfoTile(
                label: 'EMAIL ADDRESS',
                value: transaction.description.contains('@')
                    ? transaction.description
                    : 'corey@gmail.com',
                icon: Icons.mail_outline_rounded,
                trailing: const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.green,
                ),
              );
              const phone = _InfoTile(
                label: 'PHONE NUMBER',
                value: '+91 98452 33102',
                icon: Icons.phone_outlined,
              );
              const address = _InfoTile(
                label: 'RESIDENTIAL / BUSINESS ADDRESS',
                value:
                    '#402, Lotus Heights, Park Road, Bangalore, Karnataka - 560001',
                icon: Icons.location_on_outlined,
              );
              const pan = _InfoTile(
                label: 'PAN / TAX ID',
                value: 'AABCH8921K',
                icon: Icons.credit_card_outlined,
              );
              const bank = _InfoTile(
                label: 'BANK ACCOUNT',
                value: 'HDFC Bank •••• 4910',
                subValue: 'IFSC: HDFC0001245',
                icon: Icons.account_balance_outlined,
              );
              const project = _InfoTile(
                label: 'ASSOCIATED PROJECT',
                value: 'Maribel Wellness - Oncology Wing',
                icon: Icons.apartment_outlined,
              );
              const agreement = _InfoTile(
                label: 'AGREEMENT EXECUTED',
                value: '12 Jan, 2026 (Tenure: 36 Mo)',
                icon: Icons.description_outlined,
              );

              if (!twoCol) {
                return Column(
                  children: [
                    email,
                    const SizedBox(height: 10),
                    phone,
                    const SizedBox(height: 10),
                    address,
                    const SizedBox(height: 10),
                    pan,
                    const SizedBox(height: 10),
                    bank,
                    const SizedBox(height: 10),
                    project,
                    const SizedBox(height: 10),
                    agreement,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: email),
                      const SizedBox(width: 10),
                      const Expanded(child: phone),
                    ],
                  ),
                  const SizedBox(height: 10),
                  address,
                  const SizedBox(height: 10),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: pan),
                      SizedBox(width: 10),
                      Expanded(child: bank),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: project),
                      SizedBox(width: 10),
                      Expanded(child: agreement),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (fillHeight) const Spacer(),
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
  const _PendingScheduleCard({this.fillHeight = false});

  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      fillHeight: fillHeight,
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
                  '1 Due Soon',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
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
                      '66.7% Complete',
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
                  child: const LinearProgressIndicator(
                    value: 0.667,
                    minHeight: 8,
                    backgroundColor: Color(0xFFE4DCEA),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Collected: ₹80,00,000',
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
                        'Target: ₹1,20,00,000',
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
          ),
          const SizedBox(height: 12),
          const _MilestoneItem(
            title: 'Milestone 3 (Tranche C)',
            description: 'Medical Equipment Procurement Tranche',
            amount: '₹20,00,000',
            amountColor: AppColors.error,
            badgeLabel: 'Due in 12 Days',
            badgeColor: AppColors.error,
            badgeBg: Color(0xFFFDECEE),
            dueLabel: 'Due: 15 Jul, 2026',
            metaLabel: 'Invoice #INV-M3-441',
          ),
          const SizedBox(height: 10),
          const _MilestoneItem(
            title: 'Milestone 4 (Tranche D)',
            description: 'Final Facility Commissioning & Handover',
            amount: '₹20,00,000',
            amountColor: AppColors.textPrimary,
            badgeLabel: 'Scheduled',
            badgeColor: Color(0xFF5B8DEF),
            badgeBg: Color(0xFFEAF1FC),
            dueLabel: 'Due: 15 Sep, 2026',
            metaLabel: 'Auto-trigger on Phase 2 Handover',
          ),
          if (fillHeight) const Spacer(),
          const SizedBox(height: 14),
          LayoutBuilder(
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
          ),
        ],
      ),
    );
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
    this.fillHeight = false,
  });

  final Widget child;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: fillHeight ? double.infinity : null,
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
