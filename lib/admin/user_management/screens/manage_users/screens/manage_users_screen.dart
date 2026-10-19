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

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({
    super.key,
    this.isActive = false,
  });

  /// When true, this tab is visible in the admin [IndexedStack].
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ManageUsersRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => ManageUsersCubit(
          repository: context.read<ManageUsersRepository>(),
        ),
        child: _ManageUsersView(isActive: isActive),
      ),
    );
  }
}

class _ManageUsersView extends StatefulWidget {
  const _ManageUsersView({required this.isActive});

  final bool isActive;

  @override
  State<_ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<_ManageUsersView> {
  int? _selectedUserId;
  double? _selectedCommittedAmount;
  double? _selectedPaidAmount;

  @override
  void initState() {
    super.initState();
    _refreshIfActive();
  }

  @override
  void didUpdateWidget(covariant _ManageUsersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshIfActive();
    }
  }

  void _refreshIfActive() {
    if (!widget.isActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      context.read<ManageUsersCubit>().fetchUsers();
    });
  }

  void _openUser(ManageUsersInvestor user) {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        setState(() {
          _selectedUserId = user.id;
          _selectedCommittedAmount = user.totalPayable;
          _selectedPaidAmount = user.amountPaid;
        });
      });
    });
  }

  void _backToUsers() {
    FocusManager.instance.primaryFocus?.unfocus();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!mounted) return;
        setState(() {
          _selectedUserId = null;
          _selectedCommittedAmount = null;
          _selectedPaidAmount = null;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedUserId = _selectedUserId;
    if (selectedUserId != null) {
      return UserStatusUpdateScreen(
        userId: selectedUserId,
        committedAmount: _selectedCommittedAmount ?? 0,
        paidAmount: _selectedPaidAmount ?? 0,
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
              final showOverview =
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
                          if (showOverview)
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
                            )
                          else
                            const UserManagementSectionHeader(
                              title: 'Manage Users',
                              subtitle:
                                  'Review accounts, payment status, and access for all users',
                            ),
                          const SizedBox(height: 20),
                          ManageUsersTableSection(
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
