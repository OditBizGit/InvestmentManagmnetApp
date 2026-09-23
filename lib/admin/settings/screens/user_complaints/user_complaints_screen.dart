import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/model/complaint_ui_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/widgets/complaint_card.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/user_complaints/widgets/complaints_date_filter.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

/// User Complaints page shown from Settings.
/// Keeps the admin side drawer visible (in-shell navigation).
/// UI-only for now — wire to complaints API later.
class UserComplaintsScreen extends StatefulWidget {
  const UserComplaintsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<UserComplaintsScreen> createState() => _UserComplaintsScreenState();
}

class _UserComplaintsScreenState extends State<UserComplaintsScreen> {
  late List<ComplaintUiModel> _complaints;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _complaints = sampleComplaints();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  String _formatDate(DateTime date) {
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

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_fromDate ?? now.subtract(const Duration(days: 30)))
        : (_toDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
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

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = _fromDate;
        }
      } else {
        _toDate = _fromDate != null && picked.isBefore(_fromDate!)
            ? _fromDate
            : picked;
      }
    });
  }

  void _clearDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  List<ComplaintUiModel> get _filteredComplaints {
    return _complaints.where((complaint) {
      final date = DateTime(
        complaint.createdAt.year,
        complaint.createdAt.month,
        complaint.createdAt.day,
      );

      if (_fromDate != null) {
        final from = DateTime(
          _fromDate!.year,
          _fromDate!.month,
          _fromDate!.day,
        );
        if (date.isBefore(from)) return false;
      }

      if (_toDate != null) {
        final to = DateTime(
          _toDate!.year,
          _toDate!.month,
          _toDate!.day,
        );
        if (date.isAfter(to)) return false;
      }

      return true;
    }).toList();
  }

  void _markAsRead(String id) {
    setState(() {
      _complaints = _complaints
          .map(
            (item) => item.id == id ? item.copyWith(isRead: true) : item,
          )
          .toList();
    });
    AppToast.success('Complaint marked as read', context: context);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredComplaints;
    final unreadCount = filtered.where((c) => !c.isRead).length;

    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  16,
                ),
                child: _BreadcrumbHeader(onBack: _handleBack),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ComplaintsDateFilterBar(
                        fromDate: _fromDate,
                        toDate: _toDate,
                        formatDate: _formatDate,
                        onPickFrom: () => _pickDate(isFrom: true),
                        onPickTo: () => _pickDate(isFrom: false),
                        onClear: _clearDates,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Complaints',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EBF6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filtered.length} total'
                              '${unreadCount > 0 ? ' · $unreadCount unread' : ''}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        const ComplaintsEmptyState()
                      else
                        LayoutBuilder(
                          builder: (context, gridConstraints) {
                            final width = gridConstraints.maxWidth;
                            final crossAxisCount = width >= 1100
                                ? 3
                                : width >= 700
                                    ? 2
                                    : 1;
                            const spacing = 12.0;
                            final cardWidth = (width -
                                    (spacing * (crossAxisCount - 1))) /
                                crossAxisCount;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (final complaint in filtered)
                                  SizedBox(
                                    width: cardWidth,
                                    height: 210,
                                    child: ComplaintCard(
                                      complaint: complaint,
                                      formatDate: _formatDate,
                                      onMarkAsRead: () =>
                                          _markAsRead(complaint.id),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BreadcrumbHeader extends StatelessWidget {
  const _BreadcrumbHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  'User Complaints',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'User Complaints',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review user feedback and mark complaints as read',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.newBorder,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.newBorder, width: 1),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Settings',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndTitle,
              const SizedBox(height: 12),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: breadcrumbAndTitle),
            backButton,
          ],
        );
      },
    );
  }
}
