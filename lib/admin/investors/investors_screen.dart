import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/investors/add_new_investor.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/investors/widgets/investors_top_bar.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/success_screen.dart';

class AdminInvestorsScreen extends StatefulWidget {
  const AdminInvestorsScreen({super.key});

  @override
  State<AdminInvestorsScreen> createState() => _AdminInvestorsScreenState();
}

class _AdminInvestorsScreenState extends State<AdminInvestorsScreen> {
  bool _showAddInvestor = false;

  void _openAddInvestor() {
    setState(() => _showAddInvestor = true);
  }

  void _backToInvestors() {
    setState(() => _showAddInvestor = false);
  }

  Future<void> _showAddSuccess() async {
    setState(() => _showAddInvestor = false);

    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SuccessScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddInvestor) {
      return AddNewInvestorScreen(
        onBack: _backToInvestors,
        onAddSuccess: _showAddSuccess,
      );
    }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InvestorsOverviewSection(
                        onAddInvestor: _openAddInvestor,
                      ),
                      const SizedBox(height: 20),
                      const InvestorsTableSection(),
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
