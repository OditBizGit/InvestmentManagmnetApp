import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/my_complaints_response_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class RegisteredComplaintsSection extends StatelessWidget {
  const RegisteredComplaintsSection({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.complaints,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<MyComplaintModel> complaints;
  final VoidCallback onRetry;

  static String _formatDate(DateTime date) {
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
    final day = date.day.toString().padLeft(2, '0');
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} · $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final items = complaints
        .map(_ComplaintItem.fromModel)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLoading
              ? 'Registered Complaints'
              : 'Registered Complaints (${complaints.length})',
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        if (isLoading)
          const _ComplaintsListShimmer()
        else if (errorMessage != null)
          _ComplaintsError(message: errorMessage!, onRetry: onRetry)
        else if (items.isEmpty)
          const _EmptyComplaints()
        else
          Column(
            children: [
              for (final complaint in items)
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: _RegisteredComplaintCard(
                    complaint: complaint,
                    formattedDate: complaint.createdAt != null
                        ? _formatDate(complaint.createdAt!)
                        : '—',
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

enum _ComplaintStatus { pending, viewed, solved }

class _ComplaintItem {
  const _ComplaintItem({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String message;
  final DateTime? createdAt;
  final _ComplaintStatus status;

  factory _ComplaintItem.fromModel(MyComplaintModel model) {
    return _ComplaintItem(
      id: 'CMP-${model.complaintId}',
      message: model.complaint,
      createdAt: model.complaintDate,
      status: _parseStatus(model.status),
    );
  }

  static _ComplaintStatus _parseStatus(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized == 'viewed') return _ComplaintStatus.viewed;
    if (normalized == 'solved') return _ComplaintStatus.solved;
    return _ComplaintStatus.pending;
  }
}

class _RegisteredComplaintCard extends StatelessWidget {
  const _RegisteredComplaintCard({
    required this.complaint,
    required this.formattedDate,
  });

  /// Same soft green as payment-completed cards on Investment Details.
  static const Color _solvedCardColor = Color(0xFFE6F6EC);

  final _ComplaintItem complaint;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(complaint.status);
    final isSolved = complaint.status == _ComplaintStatus.solved;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.6.h),
      decoration: BoxDecoration(
        color: isSolved ? _solvedCardColor : AppColors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isSolved ? _solvedCardColor : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                complaint.id,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 0.4.h,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.bg,
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  statusStyle.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusStyle.fg,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            complaint.message,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Registered on: $formattedDate',
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(_ComplaintStatus status) {
    switch (status) {
      case _ComplaintStatus.pending:
        return const _StatusStyle(
          label: 'Pending',
          bg: Color(0xFFFEE2E2),
          fg: Color(0xFFDC2626),
        );
      case _ComplaintStatus.viewed:
        return const _StatusStyle(
          label: 'Viewed',
          bg: Color(0xFFE6F6EC),
          fg: AppColors.green,
        );
      case _ComplaintStatus.solved:
        return const _StatusStyle(
          label: 'Solved',
          bg: Color(0xFF2BB8A8),
          fg: AppColors.white,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;
}

class _ComplaintsError extends StatelessWidget {
  const _ComplaintsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 1.2.h),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyComplaints extends StatelessWidget {
  const _EmptyComplaints();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'No complaints yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 0.4.h),
            Text(
              'Your registered complaints will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintsListShimmer extends StatelessWidget {
  const _ComplaintsListShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 1.5.h),
          child: const _ComplaintCardShimmer(),
        ),
      ),
    );
  }
}

class _ComplaintCardShimmer extends StatelessWidget {
  const _ComplaintCardShimmer();

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Shimmer.fromColors(
        baseColor: _shimmerBase,
        highlightColor: _shimmerHighlight,
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 1400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18.w,
                  height: 1.6.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 16.w,
                  height: 2.2.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
            Container(
              width: double.infinity,
              height: 1.4.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            SizedBox(height: 0.7.h),
            Container(
              width: 70.w,
              height: 1.4.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            SizedBox(height: 1.2.h),
            Container(
              width: 40.w,
              height: 1.2.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
