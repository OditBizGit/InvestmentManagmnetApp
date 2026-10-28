import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/cubit/pending_requests_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/reject_payment_request_dialog.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/review_request_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/review_request_header.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';

class ReviewRequestScreen extends StatefulWidget {
  const ReviewRequestScreen({
    super.key,
    required this.requestId,
    required this.onBack,
  });

  final String requestId;
  final VoidCallback onBack;

  @override
  State<ReviewRequestScreen> createState() => _ReviewRequestScreenState();
}

class _ReviewRequestScreenState extends State<ReviewRequestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<PendingRequestsCubit>().state;
      final request = _requestFrom(state);
      if (request == null || request.userId <= 0) return;
      context.read<PendingRequestsCubit>().fetchInvestorDetails(request.userId);
    });
  }

  PendingRequestModel? _requestFrom(PendingRequestsState state) {
    if (state is! PendingRequestsSuccess) return null;
    for (final request in state.requests) {
      if (request.id == widget.requestId) return request;
    }
    return null;
  }

  void _handleBack() {
    context.read<PendingRequestsCubit>().clearInvestorDetails();
    widget.onBack();
  }

  Future<void> _accept(BuildContext context, PendingRequestModel request) async {
    final cubit = context.read<PendingRequestsCubit>();
    final current = cubit.state;
    if (current is PendingRequestsSuccess && current.isReviewSubmitting) {
      return;
    }

    final confirmed = await showUserManagementConfirmDialog(
      context: context,
      title: 'Approve request?',
      message:
          'Approve ${request.applicantName}\'s payment request for ${request.allocation}?',
      confirmLabel: 'Approve',
      confirmColor: AppColors.green,
    );
    if (!confirmed || !context.mounted) return;

    await cubit.reviewPaymentRequest(
      requestId: int.tryParse(request.id) ?? 0,
      status: 'Approved',
    );
  }

  Future<void> _reject(BuildContext context, PendingRequestModel request) async {
    final cubit = context.read<PendingRequestsCubit>();
    final current = cubit.state;
    if (current is PendingRequestsSuccess && current.isReviewSubmitting) {
      return;
    }

    final remarks = await showRejectPaymentRequestDialog(
      context: context,
      applicantName: request.applicantName,
    );
    if (remarks == null || !context.mounted) return;

    await cubit.reviewPaymentRequest(
      requestId: int.tryParse(request.id) ?? 0,
      status: 'Rejected',
      remarks: remarks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocConsumer<PendingRequestsCubit, PendingRequestsState>(
            listenWhen: (previous, current) {
              if (current is! PendingRequestsSuccess) return false;
              if (current.reviewFeedback == null) return false;
              if (previous is! PendingRequestsSuccess) return true;
              return previous.reviewFeedback != current.reviewFeedback;
            },
            listener: (context, state) {
              if (state is! PendingRequestsSuccess) return;
              final feedback = state.reviewFeedback;
              if (feedback == null) return;

              if (feedback.isSuccess) {
                AppToast.success(
                  feedback.message,
                  title: feedback.status == PendingRequestStatus.rejected
                      ? 'Rejected'
                      : 'Approved',
                  context: context,
                );
                context.read<PendingRequestsCubit>().clearReviewFeedback();
                _handleBack();
              } else {
                AppToast.error(
                  feedback.message,
                  title: 'Unable to update request',
                  context: context,
                );
                context.read<PendingRequestsCubit>().clearReviewFeedback();
              }
            },
            builder: (context, state) {
              final request = _requestFrom(state);
              final success =
                  state is PendingRequestsSuccess ? state : null;
              final isReviewSubmitting = success?.isReviewSubmitting ?? false;

              if (request == null) {
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
                      child: ReviewRequestHeader(
                        title: 'Request not found',
                        subtitle:
                            'This payment request is no longer available',
                        onBack: _handleBack,
                      ),
                    ),
                  ],
                );
              }

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          16,
                        ),
                        child: ReviewRequestHeader.forRequest(
                          request: request,
                          onBack: isReviewSubmitting ? () {} : _handleBack,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            24,
                          ),
                          child: ReviewRequestDetailsSection(
                            request: request,
                            investorDetails: success?.investorDetails,
                            isInvestorDetailsLoading:
                                success?.isInvestorDetailsLoading ?? false,
                            investorDetailsError:
                                success?.investorDetailsError,
                            isReviewSubmitting: isReviewSubmitting,
                            onRetryInvestorDetails: request.userId > 0 &&
                                    !isReviewSubmitting
                                ? () => context
                                    .read<PendingRequestsCubit>()
                                    .fetchInvestorDetails(request.userId)
                                : null,
                            onAccept: request.isAwaitingReview
                                ? () => _accept(context, request)
                                : null,
                            onReject: request.isAwaitingReview
                                ? () => _reject(context, request)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isReviewSubmitting)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x66FFFFFF),
                        child: Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.8,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
