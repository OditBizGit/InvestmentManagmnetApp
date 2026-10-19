import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/cubit/pending_requests_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/model/pending_request_model.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/review_request_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/pending_requests/screens/review_request/widgets/review_request_header.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_confirm_dialog.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';

class ReviewRequestScreen extends StatelessWidget {
  const ReviewRequestScreen({
    super.key,
    required this.requestId,
    required this.onBack,
  });

  final String requestId;
  final VoidCallback onBack;

  PendingRequestModel? _requestFrom(PendingRequestsState state) {
    if (state is! PendingRequestsSuccess) return null;
    for (final request in state.requests) {
      if (request.id == requestId) return request;
    }
    return null;
  }

  Future<void> _accept(BuildContext context, PendingRequestModel request) async {
    final confirmed = await showUserManagementConfirmDialog(
      context: context,
      title: 'Accept request?',
      message:
          'Accept ${request.applicantName}\'s registration request for ${request.allocation}?',
      confirmLabel: 'Accept',
      confirmColor: AppColors.green,
    );
    if (!confirmed || !context.mounted) return;

    context.read<PendingRequestsCubit>().markCompleted(request.id);
    AppToast.success(
      'Request accepted for ${request.applicantName}',
      title: 'Accepted',
      context: context,
    );
    onBack();
  }

  Future<void> _reject(BuildContext context, PendingRequestModel request) async {
    final confirmed = await showUserManagementConfirmDialog(
      context: context,
      title: 'Reject request?',
      message:
          'Reject ${request.applicantName}\'s registration request? This action cannot be undone.',
      confirmLabel: 'Reject',
      confirmColor: AppColors.error,
    );
    if (!confirmed || !context.mounted) return;

    context.read<PendingRequestsCubit>().markRejected(request.id);
    AppToast.error(
      'Request rejected for ${request.applicantName}',
      title: 'Rejected',
      context: context,
    );
    onBack();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocBuilder<PendingRequestsCubit, PendingRequestsState>(
            builder: (context, state) {
              final request = _requestFrom(state);

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
                            'This registration request is no longer available',
                        onBack: onBack,
                      ),
                    ),
                  ],
                );
              }

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
                    child: ReviewRequestHeader.forRequest(
                      request: request,
                      onBack: onBack,
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
              );
            },
          );
        },
      ),
    );
  }
}
