import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/storage/local_storage.dart';
import 'package:maribel_wellness_centre_application/user/profile/model/investor_details_model.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/additional_information_card.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/bank_details_card.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/legal_documentation_card.dart';
import 'package:maribel_wellness_centre_application/user/profile/screens/document_screen/widgets/nominee_details_card.dart';
import 'package:sizer/sizer.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final GlobalKey<LegalDocumentationCardState> _legalCardKey =
      GlobalKey<LegalDocumentationCardState>();

  InvestorDetailsModel? _details;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDetails(showLoading: true);
    });
  }

  Future<void> _loadDetails({required bool showLoading}) async {
    if (showLoading && mounted) {
      setState(() => _isLoadingDetails = true);
    }

    try {
      final userId = getIt<LocalStorage>().getUserId();
      if (userId == null || userId.isEmpty) {
        return;
      }

      final repository = context.read<ProfileRepository>();
      final response = await repository.getInvestorDetails(userId);

      final looksSuccessful = response.status ||
          response.code == 200 ||
          response.message.toLowerCase().contains('success');

      if (!mounted) return;

      if (looksSuccessful && response.data != null) {
        setState(() => _details = response.data);
      }
      // On failure / offline: keep last successful `_details` (option 2).
    } on DioException {
      // Keep last successful details.
    } catch (_) {
      // Keep last successful details.
    } finally {
      if (mounted && showLoading) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoadingDetails = true);

    try {
      final legalRefresh =
          _legalCardKey.currentState?.refresh(showLoading: true) ??
              Future<void>.value();

      await Future.wait<void>([
        legalRefresh,
        _loadDetails(showLoading: false),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;

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
                        'Documents',
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
                    children: [
                      LegalDocumentationCard(
                        key: _legalCardKey,
                        investorId: details?.userId,
                      ),
                      SizedBox(height: 1.8.h),
                      AdditionalInformationCard(
                        details: details,
                        isLoading: _isLoadingDetails,
                      ),
                      SizedBox(height: 1.8.h),
                      BankDetailsCard(
                        details: details,
                        isLoading: _isLoadingDetails,
                      ),
                      SizedBox(height: 1.8.h),
                      NomineeDetailsCard(
                        nominees: details?.nominees ?? const [],
                        isLoading: _isLoadingDetails,
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
