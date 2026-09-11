import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';

class AdminInvestorsScreen extends StatelessWidget {
  const AdminInvestorsScreen({super.key});

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
                child: const InvestorsTopBar(),
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
                      InvestorsOverviewSection(),

                      SizedBox(height: 20),

                      InvestorsTableSection(),
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