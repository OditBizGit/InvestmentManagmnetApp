import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/transaction_details/transaction_detail_screen.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/widgets/funding_overview_section.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/widgets/funding_payments_top_bar.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/widgets/funding_transactions_table.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';

import 'add_fund/add_new_fund.dart';

class AdminFundingPaymentsScreen extends StatefulWidget {
  const AdminFundingPaymentsScreen({super.key});

  @override
  State<AdminFundingPaymentsScreen> createState() =>
      _AdminFundingPaymentsScreenState();
}

class _AdminFundingPaymentsScreenState
    extends State<AdminFundingPaymentsScreen> {
  FundingTransaction? _selectedTransaction;
  bool _showAddFund = false;

  void _openTransaction(FundingTransaction transaction) {
    setState(() {
      _selectedTransaction = transaction;
      _showAddFund = false;
    });
  }

  void _openAddFund() {
    setState(() {
      _showAddFund = true;
      _selectedTransaction = null;
    });
  }

  void _backToFunding() {
    setState(() {
      _selectedTransaction = null;
      _showAddFund = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddFund) {
      return AddNewFundScreen(
        onBack: _backToFunding,
        onSaveSuccess: _backToFunding,
      );
    }

    if (_selectedTransaction != null) {
      return TransactionDetailScreen(
        transaction: _selectedTransaction!,
        onBack: _backToFunding,
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
                child: const FundingPaymentsTopBar(),
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
                      FundingOverviewSection(
                        onAddFunding: _openAddFund,
                      ),
                      const SizedBox(height: 20),
                      FundingTransactionsTable(
                        onTransactionTap: _openTransaction,
                      ),
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
