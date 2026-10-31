import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/cubit/funding_payments_cubit.dart';
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

  String _displayOrNA(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'N/A' : text;
  }

  String get _maskedAccount {
    final account = details.accountNumber.trim();
    if (account.isEmpty) return 'N/A';
    if (account.length <= 4) return account;
    return '•••• ${account.substring(account.length - 4)}';
  }

  String get _bankDisplay {
    final bankName = details.bankName.trim();
    final account = details.accountNumber.trim();
    if (bankName.isEmpty && account.isEmpty) return 'N/A';
    if (bankName.isEmpty) return _maskedAccount;
    if (account.isEmpty) return bankName;
    return '$bankName $_maskedAccount';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(details.profileImage);
    final email = _displayOrNA(details.email);
    final phone = _displayOrNA(details.phoneNumber);
    final address = _displayOrNA(details.address);
    final pan = _displayOrNA(details.panCardNumber);
    final ifsc = _displayOrNA(details.ifscCode);
    final org = details.organization.trim().isNotEmpty
        ? details.organization.trim()
        : _displayOrNA(details.investorType);
    final investorCode = _displayOrNA(details.investorCode);
    final investmentDateRaw =
        formatDate(details.investmentDate ?? details.createdDate).trim();
    final investmentDate = investmentDateRaw.isEmpty || investmentDateRaw == '-'
        ? 'N/A'
        : investmentDateRaw;
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
                            _displayOrNA(details.fullName),
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
                value: _bankDisplay,
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
                value: investmentDate,
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

class _PendingDueEntry {
  _PendingDueEntry({
    required this.installmentNumber,
    required this.dueDate,
    required this.amount,
    required this.paidAmount,
    required this.status,
  });

  final int installmentNumber;
  DateTime? dueDate;
  final double amount;
  final double paidAmount;
  final String status;

  String get description =>
      status.trim().isNotEmpty ? status : 'Scheduled installment';

  String get badgeLabel => status.trim().isNotEmpty ? status : 'Pending';

  _PendingDueEntry copy() {
    return _PendingDueEntry(
      installmentNumber: installmentNumber,
      dueDate: dueDate,
      amount: amount,
      paidAmount: paidAmount,
      status: status,
    );
  }
}

List<_PendingDueEntry> _pendingDueEntriesFrom(InvestorDetailsModel details) {
  return details.dueDates
      .where((d) {
        final status = d.status.toLowerCase();
        return status.contains('pending') ||
            status.contains('due') ||
            status.contains('schedul') ||
            d.pendingAmount > 0;
      })
      .map(
        (d) => _PendingDueEntry(
          installmentNumber: d.installmentNumber,
          dueDate: d.dueDate,
          amount: d.pendingAmount > 0 ? d.pendingAmount : d.installmentAmount,
          paidAmount: d.paidAmount,
          status: d.status,
        ),
      )
      .toList();
}

class _PendingScheduleCard extends StatefulWidget {
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
  State<_PendingScheduleCard> createState() => _PendingScheduleCardState();
}

class _PendingScheduleCardState extends State<_PendingScheduleCard> {
  late List<_PendingDueEntry> _entries;
  int? _editingInstallmentNumber;
  _PendingDueEntry? _editDraft;

  @override
  void initState() {
    super.initState();
    _entries = _pendingDueEntriesFrom(widget.details);
  }

  @override
  void didUpdateWidget(covariant _PendingScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.details != widget.details) {
      _entries = _pendingDueEntriesFrom(widget.details);
      _editingInstallmentNumber = null;
      _editDraft = null;
    }
  }

  void _startEditingEntry(int installmentNumber) {
    final index = _entries.indexWhere(
      (e) => e.installmentNumber == installmentNumber,
    );
    if (index < 0) return;
    setState(() {
      _editingInstallmentNumber = installmentNumber;
      _editDraft = _entries[index].copy();
    });
  }

  void _cancelEditingEntry() {
    setState(() {
      _editingInstallmentNumber = null;
      _editDraft = null;
    });
  }

  Future<void> _saveEditingEntry() async {
    final draft = _editDraft;
    final installmentNumber = _editingInstallmentNumber;
    if (draft == null || installmentNumber == null) return;

    final dueDate = draft.dueDate;
    if (dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Select a due date before saving.',
            style: TextStyle(fontSize: 10.sp),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await context.read<FundingPaymentsCubit>().updateInvestorDueDate(
          userId: widget.details.userId,
          installmentNumber: installmentNumber,
          dueDate: dueDate,
        );
  }

  Future<void> _pickDueDateForDraft() async {
    final draft = _editDraft;
    if (draft == null) return;
    final now = DateTime.now();
    final initial = draft.dueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => draft.dueDate = picked);
  }

  Widget _dueEditIconButton({
    required int installmentNumber,
    required bool enabled,
  }) {
    return Material(
      color: enabled ? AppColors.cardBg : AppColors.cardBg.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled
            ? () => _startEditingEntry(installmentNumber)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.edit_outlined,
            size: 16,
            color: enabled ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final committed = widget.details.investmentAmount;
    final paid = widget.details.totalPaidAmount;
    final progress = committed > 0 ? (paid / committed).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(1);

    final dueSoonCount = _entries.length;
    final anotherRowIsEditing = _editingInstallmentNumber != null;
    final cubitState = context.watch<FundingPaymentsCubit>().state;
    final savingInstallment = cubitState is UpdateDueDateLoading
        ? cubitState.installmentNumber
        : null;
    final isSavingDueDate = savingInstallment != null;

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
                  'Collected: ${widget.formatCurrency(paid)}',
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
                  'Target: ${widget.formatCurrency(committed)}',
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
      if (_entries.isEmpty) {
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
        itemCount: _entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final due = _entries[i];
          final isThisRowEditing =
              _editingInstallmentNumber == due.installmentNumber;
          if (isThisRowEditing && _editDraft != null) {
            return _EditablePendingDueTile(
              key: ValueKey('edit-${due.installmentNumber}'),
              entry: _editDraft!,
              formatCurrency: widget.formatCurrency,
              formatDate: widget.formatDate,
              isSaving: savingInstallment == due.installmentNumber,
              onPickDate: isSavingDueDate ? null : _pickDueDateForDraft,
              onCancel: isSavingDueDate ? null : _cancelEditingEntry,
              onSave: isSavingDueDate ? null : _saveEditingEntry,
            );
          }
          return _MilestoneItem(
            title: 'Installment ${due.installmentNumber}',
            description: due.description,
            amount: widget.formatCurrency(due.amount),
            amountColor: AppColors.error,
            badgeLabel: due.badgeLabel,
            badgeColor: AppColors.error,
            badgeBg: const Color(0xFFFDECEE),
            dueLabel: 'Due: ${widget.formatDate(due.dueDate)}',
            metaLabel: 'Paid: ${widget.formatCurrency(due.paidAmount)}',
            trailing: _dueEditIconButton(
              installmentNumber: due.installmentNumber,
              enabled: !anotherRowIsEditing && !isSavingDueDate,
            ),
          );
        },
      );

      if (expand) {
        return Expanded(child: list);
      }
      return SizedBox(
        height: widget.listMaxHeight ?? 260,
        child: list,
      );
    }

    final useFixedHeight = widget.height != null && widget.height! > 0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 14),
        progressBlock,
        const SizedBox(height: 12),
        duesList(expand: useFixedHeight),
      ],
    );

    final card = _SectionCard(
      expand: useFixedHeight,
      child: content,
    );

    if (useFixedHeight) {
      return SizedBox(height: widget.height, child: card);
    }
    return card;
  }
}

class _EditablePendingDueTile extends StatelessWidget {
  const _EditablePendingDueTile({
    super.key,
    required this.entry,
    required this.formatCurrency,
    required this.formatDate,
    required this.isSaving,
    required this.onPickDate,
    required this.onCancel,
    required this.onSave,
  });

  final _PendingDueEntry entry;
  final String Function(double amount) formatCurrency;
  final String Function(DateTime? date) formatDate;
  final bool isSaving;
  final VoidCallback? onPickDate;
  final VoidCallback? onCancel;
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    final due = entry;
    final dateLabel = due.dueDate != null
        ? formatDate(due.dueDate)
        : 'Select due date';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Installment ${due.installmentNumber}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  due.badgeLabel,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Due date',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Material(
            color: const Color(0xFFF8F7FA),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: due.dueDate != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Amount due (read-only)',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              formatCurrency(due.amount),
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paid: ${formatCurrency(due.paidAmount)} (read-only)',
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: isSaving || onSave == null
                    ? null
                    : () => onSave!(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
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
    this.trailing,
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
  final Widget? trailing;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
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
