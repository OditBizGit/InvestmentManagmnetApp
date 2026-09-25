import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/profile/complaint_success_screen.dart';
import 'package:sizer/sizer.dart';

class RegisterComplaintScreen extends StatefulWidget {
  const RegisterComplaintScreen({super.key});

  @override
  State<RegisterComplaintScreen> createState() =>
      _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  final TextEditingController _complaintController = TextEditingController();
  bool _hasComplaintText = false;

  // Dummy data — replace with API later.
  static final List<_ComplaintItem> _registeredComplaints = [
    _ComplaintItem(
      id: 'CMP-1001',
      message:
          'I paid my installment two days ago but the pending amount still shows as due. Please check and update my payment status.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: _ComplaintStatus.pending,
    ),
    _ComplaintItem(
      id: 'CMP-1002',
      message:
          'Unable to download the transaction receipt from the investments screen. The download button does nothing after tapping.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: _ComplaintStatus.inProgress,
    ),
    _ComplaintItem(
      id: 'CMP-1003',
      message:
          'My profile photo is not updating after upload. I tried both JPEG and PNG formats under 2 MB.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      status: _ComplaintStatus.resolved,
    ),
    _ComplaintItem(
      id: 'CMP-1004',
      message:
          'Need clarification on the next due date for installment 4. The schedule shows a different date than the email reminder.',
      createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 8)),
      status: _ComplaintStatus.pending,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _complaintController.addListener(_onComplaintChanged);
  }

  void _onComplaintChanged() {
    final hasText = _complaintController.text.trim().isNotEmpty;
    if (hasText != _hasComplaintText) {
      setState(() => _hasComplaintText = hasText);
    }
  }

  @override
  void dispose() {
    _complaintController
      ..removeListener(_onComplaintChanged)
      ..dispose();
    super.dispose();
  }

  void _onRegisterComplaint() {
    if (!_hasComplaintText) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ComplaintSuccessScreen(),
      ),
    );
  }

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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 5.5.w,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Register Complaint',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Submit your complaint by providing the required details below. We'll review your request and keep you updated on its progress.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    TextField(
                      controller: _complaintController,
                      maxLines: 10,
                      minLines: 8,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Text here...',
                        hintStyle: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.hint,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.8.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _hasComplaintText ? _onRegisterComplaint : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor: AppColors.border,
                          foregroundColor: AppColors.white,
                          disabledForegroundColor: AppColors.hint,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        child: Text(
                          'Register Complaint',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          'Registered Complaints (${_registeredComplaints.length})',
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    if (_registeredComplaints.isEmpty)
                      const _EmptyComplaints()
                    else
                      ..._registeredComplaints.map(
                        (complaint) => Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: _RegisteredComplaintCard(
                            complaint: complaint,
                            formattedDate: _formatDate(complaint.createdAt),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ComplaintStatus { pending, inProgress, resolved }

class _ComplaintItem {
  const _ComplaintItem({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String message;
  final DateTime createdAt;
  final _ComplaintStatus status;
}

class _RegisteredComplaintCard extends StatelessWidget {
  const _RegisteredComplaintCard({
    required this.complaint,
    required this.formattedDate,
  });

  final _ComplaintItem complaint;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(complaint.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                complaint.id,
                style: TextStyle(
                  fontSize: 13.sp,
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
                    fontSize: 11.sp,
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 11.5.sp,
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

  _StatusStyle _statusStyle(_ComplaintStatus status) {
    switch (status) {
      case _ComplaintStatus.pending:
        return const _StatusStyle(
          label: 'Pending',
          bg: Color(0xFFFFF4E5),
          fg: Color(0xFFD97706),
        );
      case _ComplaintStatus.inProgress:
        return const _StatusStyle(
          label: 'In Progress',
          bg: Color(0xFFEAF1FC),
          fg: Color(0xFF5B8DEF),
        );
      case _ComplaintStatus.resolved:
        return const _StatusStyle(
          label: 'Resolved',
          bg: Color(0xFFE6F6EC),
          fg: AppColors.green,
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

class _EmptyComplaints extends StatelessWidget {
  const _EmptyComplaints();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 8.w,
            color: AppColors.accent,
          ),
          SizedBox(height: 1.h),
          Text(
            'No complaints yet',
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
    );
  }
}
