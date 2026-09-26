import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/user/profile/complaint_success_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/my_complaints_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class RegisterComplaintScreen extends StatefulWidget {
  const RegisterComplaintScreen({super.key});

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  State<RegisterComplaintScreen> createState() =>
      _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  final TextEditingController _complaintController = TextEditingController();
  bool _hasComplaintText = false;
  bool _isSubmitting = false;
  bool _isLoadingComplaints = true;
  String? _complaintsError;
  List<_ComplaintItem> _registeredComplaints = const [];

  @override
  void initState() {
    super.initState();
    _complaintController.addListener(_onComplaintChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadComplaints());
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

  Future<void> _loadComplaints({bool showLoading = true}) async {
    setState(() {
      if (showLoading) _isLoadingComplaints = true;
      _complaintsError = null;
    });

    try {
      final response =
          await context.read<ProfileRepository>().getMyComplaints();

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!mounted) return;

      if (!looksSuccessful) {
        setState(() {
          _isLoadingComplaints = false;
          _complaintsError = response.message.isNotEmpty
              ? response.message
              : 'Failed to load complaints';
          _registeredComplaints = const [];
        });
        return;
      }

      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = null;
        _registeredComplaints = response.data
            .map(_ComplaintItem.fromModel)
            .toList(growable: false);
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = message?.isNotEmpty == true
            ? message
            : (e.message ?? 'Failed to load complaints');
        _registeredComplaints = const [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = e.toString().replaceFirst('Exception: ', '');
        _registeredComplaints = const [];
      });
    }
  }

  Future<void> _onRefresh() => _loadComplaints(showLoading: false);

  Future<void> _onRegisterComplaint() async {
    if (!_hasComplaintText || _isSubmitting) return;

    final complaint = _complaintController.text.trim();
    if (complaint.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final response =
          await context.read<ProfileRepository>().registerComplaint(complaint);

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!mounted) return;

      if (!looksSuccessful) {
        AppSnackBar.show(
          context,
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to register complaint',
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ComplaintSuccessScreen(
            message: response.message.isNotEmpty
                ? response.message
                : 'Your complaint has been registered\nsuccessfully.',
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String?)
          : null;
      AppSnackBar.show(
        context,
        message: message?.isNotEmpty == true
            ? message!
            : (e.message ?? 'Failed to register complaint'),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} · $hour12:$minute $period';
  }

  Widget _buildComplaintsSection() {
    if (_isLoadingComplaints) {
      return const _ComplaintsListShimmer();
    }

    if (_complaintsError != null) {
      return _ComplaintsError(
        message: _complaintsError!,
        onRetry: _loadComplaints,
      );
    }

    if (_registeredComplaints.isEmpty) {
      return const _EmptyComplaints();
    }

    return Column(
      children: [
        for (final complaint in _registeredComplaints)
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
    );
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
              child: RefreshIndicator(
                color: AppColors.accent,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.w),
                            borderSide:
                                const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hasComplaintText && !_isSubmitting
                              ? _onRegisterComplaint
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor: _isSubmitting
                                ? AppColors.accent
                                : AppColors.border,
                            foregroundColor: AppColors.white,
                            disabledForegroundColor: _isSubmitting
                                ? AppColors.white
                                : AppColors.hint,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 2.2.h,
                                  width: 2.2.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
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
                            _isLoadingComplaints
                                ? 'Registered Complaints'
                                : 'Registered Complaints (${_registeredComplaints.length})',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),
                      _buildComplaintsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        baseColor: RegisterComplaintScreen._shimmerBase,
        highlightColor: RegisterComplaintScreen._shimmerHighlight,
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
