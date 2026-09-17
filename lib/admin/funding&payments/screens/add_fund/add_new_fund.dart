import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/cubit/funding_payments_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/model/investor_payment_model.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/add_fund/widgets/add_fund_form_card.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/screens/add_fund/widgets/add_fund_side_panel.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class AddNewFundScreen extends StatelessWidget {
  const AddNewFundScreen({
    super.key,
    this.onBack,
    this.onSaveSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSaveSuccess;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InvestorsRepository>.value(
          value: getIt<InvestorsRepository>(),
        ),
        RepositoryProvider<InvestorPaymentRepository>.value(
          value: getIt<InvestorPaymentRepository>(),
        ),
      ],
      child: BlocProvider(
        create: (context) => FundingPaymentsCubit(
          investorsRepository: context.read<InvestorsRepository>(),
          paymentRepository: context.read<InvestorPaymentRepository>(),
        )..fetchInvestors(),
        child: _AddNewFundView(
          onBack: onBack,
          onSaveSuccess: onSaveSuccess,
        ),
      ),
    );
  }
}

class _AddNewFundView extends StatefulWidget {
  const _AddNewFundView({
    this.onBack,
    this.onSaveSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSaveSuccess;

  @override
  State<_AddNewFundView> createState() => _AddNewFundViewState();
}

class _AddNewFundViewState extends State<_AddNewFundView> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _payingNowController = TextEditingController();
  final _descriptionController = TextEditingController();

  InvestorModel? _selectedInvestor;
  DateTime _fundingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _payingNowController.addListener(_onPayingNowChanged);
  }

  void _onPayingNowChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _payingNowController.removeListener(_onPayingNowChanged);
    _totalAmountController.dispose();
    _payingNowController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onInvestorChanged(String? name) {
    final investors = context.read<FundingPaymentsCubit>().investors;
    final selected = investors.cast<InvestorModel?>().firstWhere(
          (investor) => investor?.fullName == name,
          orElse: () => null,
        );

    setState(() {
      _selectedInvestor = selected;
      _totalAmountController.text = selected == null
          ? ''
          : _formatCurrency(selected.totalInvestmentAmount);
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _handleSave() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }

    if (_selectedInvestor == null) {
      AppToast.error('Please select an investor', context: context);
      return;
    }

    final paidAmount = double.tryParse(
      _payingNowController.text.trim().replaceAll(',', ''),
    );
    if (paidAmount == null || paidAmount <= 0) {
      AppToast.error('Enter a valid paying amount', context: context);
      return;
    }

    final request = AddInvestorPaymentRequestModel(
      userId: _selectedInvestor!.userId,
      paidAmount: paidAmount,
      narration: _descriptionController.text.trim(),
    );

    await context.read<FundingPaymentsCubit>().addInvestorPayment(request);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fundingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _fundingDate = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatCurrency(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw = isWhole
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final digits = parts.first;
    final withCommas = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FundingPaymentsCubit, FundingPaymentsState>(
      listener: (context, state) {
        if (state is FundingInvestorsFailure) {
          AppToast.error(state.message, context: context);
        } else if (state is AddPaymentSuccess) {
          AppToast.success(state.message, context: context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (widget.onSaveSuccess != null) {
              widget.onSaveSuccess!();
              return;
            }
            _handleBack();
          });
        } else if (state is AddPaymentFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<FundingPaymentsCubit>();
        final investors = state is FundingInvestorsSuccess
            ? state.investors
            : cubit.investors;
        final isLoadingInvestors = state is FundingInvestorsLoading ||
            (state is FundingPaymentsInitial && investors.isEmpty);
        final isSaving = state is AddPaymentLoading;

        final investorNames = investors
            .map((investor) => investor.fullName)
            .where((name) => name.trim().isNotEmpty)
            .toList();

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 16.0 : 24.0;
              final isNarrow = constraints.maxWidth < 980;

              final formCard = AddFundFormCard(
                formKey: _formKey,
                investor: _selectedInvestor?.fullName,
                investorOptions: investorNames,
                onInvestorChanged: _onInvestorChanged,
                investorType: _selectedInvestor?.investorType,
                totalAmountController: _totalAmountController,
                payingNowController: _payingNowController,
                fundingDate: _fundingDate,
                onPickDate: _pickDate,
                formatDate: _formatDate,
                descriptionController: _descriptionController,
                isLoadingInvestors: isLoadingInvestors,
              );

              final sidePanel = AddFundSidePanel(
                investor: _selectedInvestor?.fullName,
                fundingType: _selectedInvestor?.investorType,
                totalAmount: _totalAmountController.text.isEmpty
                    ? null
                    : _totalAmountController.text,
                payingNow: _payingNowController.text.trim().isEmpty
                    ? null
                    : _payingNowController.text.trim(),
                isLoading: isSaving,
                onCancel: _handleBack,
                onSave: _handleSave,
              );

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
                    child: _BreadcrumbHeader(onBack: _handleBack),
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
                          if (isNarrow) ...[
                            formCard,
                            const SizedBox(height: 16),
                            sidePanel,
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 7, child: formCard),
                                const SizedBox(width: 16),
                                Expanded(flex: 4, child: sidePanel),
                              ],
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
      },
    );
  }
}

class _BreadcrumbHeader extends StatelessWidget {
  const _BreadcrumbHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Funding & Payments',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  'Add New Fund',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Add New Fund',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a new funding entry to track investor contributions and project financing',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.newBorder,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.newBorder, width: 1),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Funding',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndTitle,
              const SizedBox(height: 8),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: breadcrumbAndTitle),
            backButton,
          ],
        );
      },
    );
  }
}
