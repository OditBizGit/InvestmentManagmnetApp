import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/profile/complaint_success_screen.dart';
import 'package:sizer/sizer.dart';

class ChangeRequestScreen extends StatefulWidget {
  const ChangeRequestScreen({super.key});

  @override
  State<ChangeRequestScreen> createState() => _ChangeRequestScreenState();
}

class _ChangeRequestScreenState extends State<ChangeRequestScreen> {
  final TextEditingController _requestController = TextEditingController();
  bool _hasRequestText = false;

  @override
  void initState() {
    super.initState();
    _requestController.addListener(_onRequestChanged);
  }

  void _onRequestChanged() {
    final hasText = _requestController.text.trim().isNotEmpty;
    if (hasText != _hasRequestText) {
      setState(() => _hasRequestText = hasText);
    }
  }

  @override
  void dispose() {
    _requestController
      ..removeListener(_onRequestChanged)
      ..dispose();
    super.dispose();
  }

  void _onSubmitRequest() {
    if (!_hasRequestText) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ComplaintSuccessScreen(
          message: 'Your change request has been submitted\nsuccessfully.',
        ),
      ),
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
                        'Request Change',
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
                      "Submit your change request by providing the required details below. We'll review your request and keep you updated on its progress.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    TextField(
                      controller: _requestController,
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.5.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasRequestText ? _onSubmitRequest : null,
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
                    'Submit Request',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
