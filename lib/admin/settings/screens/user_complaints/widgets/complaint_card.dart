import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/model/complaint_ui_model.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.formatDate,
    required this.onMarkAsRead,
    required this.onMarkAsSolved,
    this.isMarking = false,
    this.isSolving = false,
  });

  final UserComplaintModel complaint;
  final String Function(DateTime date) formatDate;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsSolved;
  final bool isMarking;
  final bool isSolving;

  String get _statusLabel {
    final normalized = complaint.status.trim().toLowerCase();
    if (normalized == 'solved') return 'Solved';
    if (normalized == 'viewed' || normalized == 'read') return 'Viewed';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final isRead = complaint.isRead;
    final isSolved = complaint.isSolved;
    final statusLabel = _statusLabel;
    final canSolve = !isSolved && !isSolving;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? AppColors.border
              : AppColors.accent.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF0EBF6),
                backgroundImage: complaint.profileImageUrl != null
                    ? NetworkImage(complaint.profileImageUrl!)
                    : null,
                child: complaint.profileImageUrl == null
                    ? Text(
                        _initials(complaint.username),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      complaint.userId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: canSolve ? onMarkAsSolved : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSolving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.green,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: isSolved,
                            onChanged: canSolve
                                ? (_) => onMarkAsSolved()
                                : null,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 1.4,
                            ),
                            activeColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      const SizedBox(width: 2),
                      Text(
                        isSolved ? 'Solved' : 'Mark as Solved',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isSolved
                              ? AppColors.green
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            complaint.id,
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5B8DEF),
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: Text(
              complaint.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Text(
                  formatDate(complaint.createdAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              _MetaChip(
                label: statusLabel,
                bg: isSolved
                    ? const Color(0xFFE6F6EC)
                    : isRead
                        ? const Color(0xFFEAF1FC)
                        : const Color(0xFFFDECEE),
                fg: isSolved
                    ? AppColors.green
                    : isRead
                        ? const Color(0xFF5B8DEF)
                        : const Color(0xFFE06B7A),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: isRead || isMarking ? null : onMarkAsRead,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: const Color(0xFFE8E6EC),
                disabledForegroundColor: AppColors.textMuted,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isMarking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : Text(
                      isRead ? 'Already Read' : 'Mark as Read',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class ComplaintsEmptyState extends StatelessWidget {
  const ComplaintsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 48,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 24,
              color: Color(0xFF5B8DEF),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No data found',
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are no complaints for the selected date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
