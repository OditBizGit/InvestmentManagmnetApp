import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_benefits_summary_card.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_refund_card.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_status_checkbox_card.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_status_update_header.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class UserStatusUpdateScreen extends StatefulWidget {
  const UserStatusUpdateScreen({
    super.key,
    required this.userId,
    required this.committedAmount,
    required this.paidAmount,
    required this.onBack,
  });

  final int userId;
  final double committedAmount;
  final double paidAmount;
  final VoidCallback onBack;

  @override
  State<UserStatusUpdateScreen> createState() => _UserStatusUpdateScreenState();
}

class _UserStatusUpdateScreenState extends State<UserStatusUpdateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<ManageUsersCubit>();
      cubit.fetchInvestorMouStatus(widget.userId);
      cubit.fetchInvestorLlpStatus(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocConsumer<ManageUsersCubit, ManageUsersState>(
            listener: (context, state) {
              if (state is! ManageUsersSuccess) return;
              final feedback = state.statusFeedback;
              if (feedback == null) return;

              if (feedback.isSuccess) {
                AppToast.success(
                  feedback.message,
                  title: feedback.title ?? 'Success',
                  context: context,
                );
              } else {
                AppToast.error(
                  feedback.message,
                  title: feedback.title ?? 'Error',
                  context: context,
                );
              }

              context.read<ManageUsersCubit>().clearStatusFeedback();
            },
            builder: (context, state) {
              final user = state is ManageUsersSuccess
                  ? _userById(state.users, widget.userId)
                  : null;

              if (user == null) {
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
                      child: UserStatusUpdateHeader(
                        title: 'Investor not found',
                        subtitle: 'This investor is no longer available',
                        onBack: widget.onBack,
                      ),
                    ),
                  ],
                );
              }

              final successState =
                  state is ManageUsersSuccess ? state : null;
              final mouStatus = successState?.mouStatus[user.id] ??
                  DocumentProcessStatus.pending;
              final llpStatus = successState?.llpStatus[user.id] ??
                  DocumentProcessStatus.pending;
              final mouIssuedAt = successState?.mouIssuedAt[user.id];
              final mouCompletedAt = successState?.mouCompletedAt[user.id];
              final llpIssuedAt = successState?.llpIssuedAt[user.id];
              final llpCompletedAt = successState?.llpCompletedAt[user.id];
              final isRefundSaving =
                  successState?.refundUpdatingUserId == user.id;
              final isMouBusy = successState?.mouUpdatingUserId == user.id ||
                  successState?.mouLoadingUserId == user.id;
              final isLlpBusy = successState?.llpUpdatingUserId == user.id ||
                  successState?.llpLoadingUserId == user.id;

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
                    child: UserStatusUpdateHeader(
                      title: _displayOrNA(user.name),
                      subtitle:
                          '${_displayOrNA(user.userId)} · ${_displayOrNA(user.email)} · ${_displayOrNA(user.phoneNumber)}',
                      onBack: widget.onBack,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UserBenefitsSummaryCard(
                            committedAmount: user.totalPayable,
                            depositDiscountAmount: user.depositDiscountAmount,
                            medicalAllowanceNote:
                                user.medicalAllowanceDescription,
                          ),
                          const SizedBox(height: 20),
                          UserRefundCard(
                            user: user,
                            committedAmount: user.totalPayable,
                            paidAmount: user.amountPaid,
                            isSaving: isRefundSaving,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Document status',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, inner) {
                              final stacked = inner.maxWidth < 720;
                              final mouCard = UserStatusCheckboxCard(
                                title: 'Update MOU status',
                                subtitle:
                                    'Select the current memorandum of understanding status',
                                documentLabel: 'MOU',
                                selected: mouStatus,
                                issuedAt: mouIssuedAt,
                                completedAt: mouCompletedAt,
                                isLoading: isMouBusy,
                                onChanged: (status) {
                                  context
                                      .read<ManageUsersCubit>()
                                      .saveInvestorMouStatus(
                                        investorId: user.id,
                                        status: status,
                                      );
                                },
                              );
                              final llpCard = UserStatusCheckboxCard(
                                title: 'Update LLP registration status',
                                subtitle:
                                    'Select the current LLP registration status',
                                documentLabel: 'LLP',
                                selected: llpStatus,
                                issuedAt: llpIssuedAt,
                                completedAt: llpCompletedAt,
                                isLoading: isLlpBusy,
                                onChanged: (status) {
                                  context
                                      .read<ManageUsersCubit>()
                                      .saveInvestorLlpStatus(
                                        investorId: user.id,
                                        status: status,
                                      );
                                },
                              );

                              if (stacked) {
                                return Column(
                                  children: [
                                    mouCard,
                                    const SizedBox(height: 14),
                                    llpCard,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: mouCard),
                                  const SizedBox(width: 14),
                                  Expanded(child: llpCard),
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
          );
        },
      ),
    );
  }
}

ManageUsersInvestor? _userById(List<ManageUsersInvestor> users, int userId) {
  for (final user in users) {
    if (user.id == userId) return user;
  }
  return null;
}

String _displayOrNA(String value) {
  final text = value.trim();
  return text.isEmpty ? 'N/A' : text;
}
