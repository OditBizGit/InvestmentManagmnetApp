import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/api_error_message.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/my_complaints_response_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/register_complaint_screen/widgets/complaint_success_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/register_complaint_screen/widgets/register_complaint_section.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/register_complaint_screen/widgets/registered_complaints_section.dart';
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
  bool _isSubmitting = false;
  bool _isLoadingComplaints = true;
  String? _complaintsError;
  List<MyComplaintModel> _registeredComplaints = const [];

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
        _registeredComplaints = response.data;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = ApiErrorMessage.from(
          e,
          fallback: 'Failed to load complaints',
        );
        _registeredComplaints = const [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = ApiErrorMessage.from(
          e,
          fallback: 'Failed to load complaints',
        );
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
      AppSnackBar.show(
        context,
        message: ApiErrorMessage.from(
          e,
          fallback: 'Failed to register complaint',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: ApiErrorMessage.from(
          e,
          fallback: 'Failed to register complaint',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                      RegisterComplaintSection(
                        controller: _complaintController,
                        canSubmit: _hasComplaintText,
                        isSubmitting: _isSubmitting,
                        onRegister: _onRegisterComplaint,
                      ),
                      SizedBox(height: 2.h),
                      RegisteredComplaintsSection(
                        isLoading: _isLoadingComplaints,
                        errorMessage: _complaintsError,
                        complaints: _registeredComplaints,
                        onRetry: _loadComplaints,
                      ),
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
