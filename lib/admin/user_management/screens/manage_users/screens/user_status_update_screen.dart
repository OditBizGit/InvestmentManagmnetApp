import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/model/managed_user_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_benefits_summary_card.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_status_checkbox_card.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/user_status_update_header.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class UserStatusUpdateScreen extends StatelessWidget {
  const UserStatusUpdateScreen({
    super.key,
    required this.userId,
    required this.onBack,
  });

  final int userId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocBuilder<ManageUsersCubit, ManageUsersState>(
            builder: (context, state) {
              final user = state is ManageUsersSuccess
                  ? _userById(state.users, userId)
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
                        onBack: onBack,
                      ),
                    ),
                  ],
                );
              }

              final mouStatus = state is ManageUsersSuccess
                  ? state.mouStatus[user.id] ?? DocumentProcessStatus.pending
                  : DocumentProcessStatus.pending;
              final llpStatus = state is ManageUsersSuccess
                  ? state.llpStatus[user.id] ?? DocumentProcessStatus.pending
                  : DocumentProcessStatus.pending;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UserBenefitsSummaryCard(amountPaid: user.amountPaid),
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
                                selected: mouStatus,
                                onChanged: (status) {
                                  context
                                      .read<ManageUsersCubit>()
                                      .updateMouStatus(user.id, status);
                                  AppToast.success(
                                    'MOU status set to ${status.label}',
                                    title: 'MOU Updated',
                                    context: context,
                                  );
                                },
                              );
                              final llpCard = UserStatusCheckboxCard(
                                title: 'Update LLP registration status',
                                subtitle:
                                    'Select the current LLP registration status',
                                selected: llpStatus,
                                onChanged: (status) {
                                  context
                                      .read<ManageUsersCubit>()
                                      .updateLlpStatus(user.id, status);
                                  AppToast.success(
                                    'LLP status set to ${status.label}',
                                    title: 'LLP Updated',
                                    context: context,
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
