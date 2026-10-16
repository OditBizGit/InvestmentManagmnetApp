import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/cubit/user_management_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/due_payments_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/screens/due_payments/widgets/due_payments_table_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/admin_top_bar.dart';

class DuePaymentsScreen extends StatelessWidget {
  const DuePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

          return BlocBuilder<UserManagementCubit, UserManagementState>(
            builder: (context, state) {
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
                          DuePaymentsOverviewSection(
                            totalOutstandingDues: state.totalOutstandingDues,
                            usersWithPendingDues: state.usersWithPendingDues,
                            partiallyPaidUsers: state.partiallyPaidUsers,
                            fullyPaidUsers: state.fullyPaidUsers,
                          ),
                          const SizedBox(height: 20),
                          DuePaymentsTableSection(users: state.users),
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
