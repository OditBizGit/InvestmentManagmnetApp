import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_details_section.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_overview_cards.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_recent_transactions_table.dart';
import 'package:maribel_wellness_centre_application/admin/reports/screens/widgets/reports_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 16.0 : 24.0;

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
                child: const ReportsTopBar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReportsOverviewCards(),
                      SizedBox(height: 20),
                      ReportsDetailsSection(),
                      SizedBox(height: 20),
                      ReportsRecentTransactionsTable(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
