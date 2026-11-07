import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/investor_block_requests_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class TerminatedInvestorsSection extends StatefulWidget {
  const TerminatedInvestorsSection({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<TerminatedInvestorsSection> createState() =>
      _TerminatedInvestorsSectionState();
}

class _TerminatedInvestorsSectionState extends State<TerminatedInvestorsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
  }

  void _loadIfNeeded() {
    if (!mounted) return;
    final cubit = context.read<ManageUsersCubit>();
    final state = cubit.state;
    if (state is! ManageUsersSuccess) {
      cubit.fetchBlockRequests();
      return;
    }
    if (state.isBlockRequestsLoading) return;
    if (state.blockRequestsResponse != null) return;
    if (state.blockRequestsError != null) return;
    cubit.fetchBlockRequests();
  }

  List<InvestorBlockRequestModel> _filtered(
    List<InvestorBlockRequestModel> items,
  ) {
    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      return item.fullName.toLowerCase().contains(query) ||
          item.investorCode.toLowerCase().contains(query) ||
          item.email.toLowerCase().contains(query) ||
          item.phoneNumber.toLowerCase().contains(query) ||
          (item.requestedByName ?? '').toLowerCase().contains(query) ||
          item.remarks.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _approve(InvestorBlockRequestModel item) async {
    final message = await context.read<ManageUsersCubit>().reviewBlockRequest(
          requestId: item.requestId,
          status: 'Approved',
        );
    if (!mounted) return;
    if (message != null) {
      AppToast.success(
        message,
        title: 'Approved',
        context: context,
      );
      return;
    }
    _showReviewErrorIfAny();
  }

  Future<void> _reject(InvestorBlockRequestModel item) async {
    final message = await context.read<ManageUsersCubit>().reviewBlockRequest(
          requestId: item.requestId,
          status: 'Rejected',
        );
    if (!mounted) return;
    if (message != null) {
      AppToast.success(
        message,
        title: 'Rejected',
        context: context,
      );
      return;
    }
    _showReviewErrorIfAny();
  }

  void _showReviewErrorIfAny() {
    final state = context.read<ManageUsersCubit>().state;
    if (state is! ManageUsersSuccess) return;
    final feedback = state.statusFeedback;
    if (feedback == null || feedback.isSuccess) return;
    AppToast.error(
      feedback.message,
      title: feedback.title ?? 'Review failed',
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageUsersCubit, ManageUsersState>(
      builder: (context, state) {
        final success = state is ManageUsersSuccess ? state : null;
        final isLoading =
            success?.isBlockRequestsLoading == true &&
            (success?.blockRequestsResponse == null);
        final error = success?.blockRequestsError;
        final items = _filtered(success?.blockRequests ?? const []);
        final reviewingId = success?.blockRequestReviewingId;

        if (isLoading) {
          return const _BlockRequestsLoading();
        }

        if (error != null && (success?.blockRequests.isEmpty ?? true)) {
          return _BlockRequestsError(
            message: error,
            onRetry: () =>
                context.read<ManageUsersCubit>().fetchBlockRequests(),
          );
        }

        if (items.isEmpty) {
          return UserManagementTableCard(
            child: SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  widget.searchQuery.trim().isNotEmpty
                      ? 'No matches for your search'
                      : 'No block requests found',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            if (error != null) ...[
              _InlineErrorBanner(
                message: error,
                onRetry: () =>
                    context.read<ManageUsersCubit>().fetchBlockRequests(),
              ),
              const SizedBox(height: 10),
            ],
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _TerminatedInvestorCard(
                item: items[i],
                isReviewing: reviewingId == items[i].requestId,
                onApprove: items[i].isPendingReview && reviewingId == null
                    ? () => _approve(items[i])
                    : null,
                onReject: items[i].isPendingReview && reviewingId == null
                    ? () => _reject(items[i])
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BlockRequestsLoading extends StatelessWidget {
  const _BlockRequestsLoading();

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading block requests...',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockRequestsError extends StatelessWidget {
  const _BlockRequestsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return UserManagementTableCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _TerminatedInvestorCard extends StatelessWidget {
  const _TerminatedInvestorCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
    this.isReviewing = false,
  });

  final InvestorBlockRequestModel item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isReviewing;

  UserManagementBadgeTone get _tone {
    final status = item.status.trim().toLowerCase();
    if (status == 'approved') return UserManagementBadgeTone.success;
    if (status == 'rejected') return UserManagementBadgeTone.danger;
    return UserManagementBadgeTone.warning;
  }

  String get _statusLabel {
    final status = item.status.trim().toLowerCase();
    if (status == 'approved') return 'Termination approved';
    if (status == 'rejected') return 'Termination rejected';
    return 'Awaiting review';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final staffName = (item.requestedByName ?? '').trim().isNotEmpty
        ? item.requestedByName!.trim()
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;
          if (isCompact) {
            return _CompactBody(
              item: item,
              staffName: staffName,
              tone: _tone,
              statusLabel: _statusLabel,
              formattedDate: _formatDate(item.requestedDate),
              onApprove: onApprove,
              onReject: onReject,
              isReviewing: isReviewing,
            );
          }
          return _WideBody(
            item: item,
            staffName: staffName,
            tone: _tone,
            statusLabel: _statusLabel,
            formattedDate: _formatDate(item.requestedDate),
            onApprove: onApprove,
            onReject: onReject,
            isReviewing: isReviewing,
          );
        },
      ),
    );
  }
}

class _WideBody extends StatelessWidget {
  const _WideBody({
    required this.item,
    required this.staffName,
    required this.tone,
    required this.statusLabel,
    required this.formattedDate,
    required this.onApprove,
    required this.onReject,
    this.isReviewing = false,
  });

  final InvestorBlockRequestModel item;
  final String staffName;
  final UserManagementBadgeTone tone;
  final String statusLabel;
  final String formattedDate;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isReviewing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(name: item.fullName),
        const SizedBox(width: 14),
        Expanded(
          flex: 4,
          child: _InvestorDetails(item: item),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _StaffDetails(staffName: staffName),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: _ReasonBlock(reason: item.remarks),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 168,
          child: _ActionsColumn(
            tone: tone,
            statusLabel: statusLabel,
            formattedDate: formattedDate,
            onApprove: onApprove,
            onReject: onReject,
            isReviewing: isReviewing,
          ),
        ),
      ],
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({
    required this.item,
    required this.staffName,
    required this.tone,
    required this.statusLabel,
    required this.formattedDate,
    required this.onApprove,
    required this.onReject,
    this.isReviewing = false,
  });

  final InvestorBlockRequestModel item;
  final String staffName;
  final UserManagementBadgeTone tone;
  final String statusLabel;
  final String formattedDate;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isReviewing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _Avatar(name: item.fullName, size: 40),
            const SizedBox(width: 12),
            Expanded(child: _InvestorDetails(item: item)),
          ],
        ),
        const SizedBox(height: 12),
        _StaffDetails(staffName: staffName),
        const SizedBox(height: 12),
        _ReasonBlock(reason: item.remarks),
        const SizedBox(height: 12),
        _ActionsColumn(
          tone: tone,
          statusLabel: statusLabel,
          formattedDate: formattedDate,
          onApprove: onApprove,
          onReject: onReject,
          isReviewing: isReviewing,
          expanded: true,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.size = 46});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.cardBg,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _InvestorDetails extends StatelessWidget {
  const _InvestorDetails({required this.item});

  final InvestorBlockRequestModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.investorCode,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        _ContactLine(icon: ImageConstants.email, text: item.email),
        const SizedBox(height: 4),
        _ContactLine(icon: ImageConstants.phone, text: item.phoneNumber),
      ],
    );
  }
}

class _StaffDetails extends StatelessWidget {
  const _StaffDetails({required this.staffName});

  final String staffName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REQUESTED BY',
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          staffName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReasonBlock extends StatelessWidget {
  const _ReasonBlock({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REASON FOR BLOCK',
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.screenBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBg),
          ),
          child: Text(
            reason.trim().isEmpty ? '—' : reason,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 13,
          height: 13,
          colorFilter: const ColorFilter.mode(
            AppColors.textMuted,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionsColumn extends StatelessWidget {
  const _ActionsColumn({
    required this.tone,
    required this.statusLabel,
    required this.formattedDate,
    required this.onApprove,
    required this.onReject,
    this.isReviewing = false,
    this.expanded = false,
  });

  final UserManagementBadgeTone tone;
  final String statusLabel;
  final String formattedDate;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isReviewing;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final buttons = Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text(
              'Reject',
              style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(
                color: onReject == null
                    ? AppColors.border
                    : AppColors.error.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: onApprove,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(
              'Approve',
              style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment:
          expanded ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        UserManagementStatusBadge(label: statusLabel, tone: tone),
        const SizedBox(height: 8),
        Text(
          'Requested $formattedDate',
          style: TextStyle(
            fontSize: 9.sp,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        if (isReviewing)
          const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
          )
        else if (onApprove != null && onReject != null)
          buttons,
      ],
    );
  }
}
