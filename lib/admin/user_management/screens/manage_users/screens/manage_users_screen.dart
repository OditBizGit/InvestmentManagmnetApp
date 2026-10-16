import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/cubit/manage_users_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/model/manage_users_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/repository/manage_users_repository.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/user_status_update_screen.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/manage_users_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/manage_users/screens/widgets/manage_users_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ManageUsersRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => ManageUsersCubit(
          repository: context.read<ManageUsersRepository>(),
        )..fetchUsers(),
        child: const _ManageUsersView(),
      ),
    );
  }
}

class _ManageUsersView extends StatefulWidget {
  const _ManageUsersView();

  @override
  State<_ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<_ManageUsersView> {
  int? _selectedUserId;

  void _openUser(ManageUsersInvestor user) {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        setState(() => _selectedUserId = user.id);
      });
    });
  }

  void _backToUsers() {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        setState(() => _selectedUserId = null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedUserId = _selectedUserId;
    if (selectedUserId != null) {
      return UserStatusUpdateScreen(
        userId: selectedUserId,
        onBack: _backToUsers,
      );
    }

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
              final users = switch (state) {
                ManageUsersSuccess(:final users) => users,
                ManageUsersEmpty() => const <ManageUsersInvestor>[],
                _ => const <ManageUsersInvestor>[],
              };
              final showList =
                  state is ManageUsersSuccess || state is ManageUsersEmpty;

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
                    child: const AdminTopBar(),
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
                          if (showList)
                            ManageUsersOverviewSection(
                              totalUsers: state is ManageUsersSuccess
                                  ? state.totalUsers
                                  : 0,
                              activeUsers: state is ManageUsersSuccess
                                  ? state.activeUsers
                                  : 0,
                              blockedUsers: state is ManageUsersSuccess
                                  ? state.blockedUsers
                                  : 0,
                            //   usersWithPendingDues: state is ManageUsersSuccess
                            //       ? state.usersWithPendingDues
                            //       : 0,
                            )
                          else
                            const UserManagementSectionHeader(
                              title: 'Manage Users',
                              subtitle:
                                  'Review accounts, payment status, and access for all users',
                            ),
                          const SizedBox(height: 20),
                          if (state is ManageUsersLoading ||
                              state is ManageUsersInitial)
                            const _ManageUsersLoading()
                          else if (state is ManageUsersFailure)
                            _ManageUsersErrorPanel(
                              message: state.message,
                              onRetry: () => context
                                  .read<ManageUsersCubit>()
                                  .fetchUsers(),
                            )
                          else
                            ManageUsersTableSection(
                              users: users,
                              statusUpdatingUserId: state is ManageUsersSuccess
                                  ? state.statusUpdatingUserId
                                  : null,
                              onUserTap: _openUser,
                              onToggleBlock: (user) => context
                                  .read<ManageUsersCubit>()
                                  .toggleBlockStatus(user),
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

class _ManageUsersLoading extends StatelessWidget {
  const _ManageUsersLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading users...',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageUsersErrorPanel extends StatelessWidget {
  const _ManageUsersErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
