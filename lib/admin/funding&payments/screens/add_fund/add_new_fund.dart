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
  const AddNewFundScreen({super.key, this.onBack, this.onSaveSuccess});

  final VoidCallback? onBack;
  final VoidCallback? onSaveSuccess;

  @override
  Widget build(BuildContext context) {
    // Reuse the parent [FundingPaymentsCubit] so payment success + silent
    // refresh update the same list shown on Funding & Payments.
    final existingCubit = context.read<FundingPaymentsCubit>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InvestorsRepository>.value(
          value: getIt<InvestorsRepository>(),
        ),
        RepositoryProvider<InvestorPaymentRepository>.value(
          value: getIt<InvestorPaymentRepository>(),
        ),
      ],
      child: BlocProvider<FundingPaymentsCubit>.value(
        value: existingCubit,
        child: _AddNewFundView(onBack: onBack, onSaveSuccess: onSaveSuccess),
      ),
    );
  }
}

class _AddNewFundView extends StatefulWidget {
  const _AddNewFundView({this.onBack, this.onSaveSuccess});

  final VoidCallback? onBack;
  final VoidCallback? onSaveSuccess;

  @override
  State<_AddNewFundView> createState() => _AddNewFundViewState();
}

enum _FundPaymentAction { none, settleFull }

class _AddNewFundViewState extends State<_AddNewFundView> {
  static const _amountEpsilon = 0.009;

  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _totalPaidAmountController = TextEditingController();
  final _remainingAmountController = TextEditingController();
  final _payingNowController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();

  InvestorModel? _selectedInvestor;
  _FundPaymentAction _paymentAction = _FundPaymentAction.none;
  bool _programmaticPayingNowUpdate = false;
  DateTime _fundingDate = DateTime.now();
  String? _selectedPaymentMethod;

  /// Local UI-only due payment state (no backend).
  double _dueRemainingAmount = 0;
  DateTime? _dueDate;
  String _dueStatus = 'Pending';

  double get _basePaidAmount => _selectedInvestor?.totalPaidAmount ?? 0;

  /// Current outstanding balance for the selected investor.
  double get _outstandingBalance {
    if (_selectedInvestor == null) return 0;
    final investor = _selectedInvestor!;
    final computed = investor.totalInvestmentAmount - investor.totalPaidAmount;
    final balance = computed < 0 ? 0.0 : computed;
    if (investor.totalPendingAmount > 0) {
      return investor.totalPendingAmount;
    }
    return balance;
  }

  bool get _canSettleFull =>
      _selectedInvestor != null && _outstandingBalance > 0;

  bool _amountsEqual(double a, double b) => (a - b).abs() < _amountEpsilon;

  double get _currentDiscount {
    final discount = _parseAmount(_discountController.text);
    return discount == null || discount < 0 ? 0 : discount;
  }

  @override
  void initState() {
    super.initState();
    _payingNowController.addListener(_onPayingNowAmountChanged);
    _discountController.addListener(_onDiscountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FundingPaymentsCubit>().fetchInvestors();
    });
  }

  void _onPayingNowAmountChanged() {
    if (!mounted) return;
    _syncAmountDisplays();
    setState(() {});
  }

  void _onDiscountChanged() {
    if (!mounted) return;
    if (_paymentAction == _FundPaymentAction.settleFull &&
        _selectedInvestor != null) {
      final deposit = _outstandingBalance - _currentDiscount;
      if (deposit < 0) {
        _syncAmountDisplays();
        setState(() {});
        return;
      }
      _setPayingNowAmount(deposit);
    }
    _syncAmountDisplays();
    setState(() {});
  }

  void _setPayingNowAmount(double amount) {
    _programmaticPayingNowUpdate = true;
    _payingNowController.text = _amountInputText(amount < 0 ? 0 : amount);
    _programmaticPayingNowUpdate = false;
    _syncAmountDisplays();
    setState(() {});
  }

  double? _parseAmount(String? value) {
    if (value == null) return null;
    final cleaned = value.trim().replaceAll(',', '').replaceAll('₹', '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  void _syncAmountDisplays() {
    if (_selectedInvestor == null) {
      _totalPaidAmountController.text = '';
      _remainingAmountController.text = '';
      return;
    }

    final payingNow = _parseAmount(_payingNowController.text);
    final deposit = (payingNow != null && payingNow > 0) ? payingNow : 0.0;
    final discount = _currentDiscount;
    final outstanding = _outstandingBalance;
    final projectedPaid = _basePaidAmount + deposit;
    final remainingAfterPayment = outstanding - deposit - discount;

    _totalPaidAmountController.text = _formatCurrency(projectedPaid);
    _remainingAmountController.text = _formatCurrency(
      remainingAfterPayment < 0 ? 0 : remainingAfterPayment,
    );
  }

  void _resetDueState() {
    _dueRemainingAmount = 0;
    _dueDate = null;
    _dueStatus = 'Pending';
  }

  void _initDueForInvestor(InvestorModel investor) {
    final dueAmount =
        investor.nextDueAmount < 0 ? 0.0 : investor.nextDueAmount;

    _dueRemainingAmount = dueAmount;
    _dueDate = investor.nextDueDate;
    _dueStatus = dueAmount <= 0 ? 'Completed' : 'Pending';
  }

  String _amountInputText(double amount) {
    final isWhole = amount == amount.roundToDouble();
    return isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
  }

  String? _validatePayingNow(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter amount paying now';
    }

    final amount = _parseAmount(value);
    if (amount == null) {
      return 'Enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    if (_selectedInvestor == null) {
      return 'Please select an investor first';
    }

    final outstanding = _outstandingBalance;
    final discount = _currentDiscount;
    final totalApplied = amount + discount;

    if (totalApplied - outstanding > _amountEpsilon) {
      return 'Payment plus discount cannot exceed outstanding balance';
    }

    if (_paymentAction == _FundPaymentAction.settleFull &&
        !_amountsEqual(totalApplied, outstanding)) {
      return 'Full settlement requires deposit plus discount to equal outstanding balance';
    }

    return null;
  }

  String? _validateDiscount(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final discount = _parseAmount(value);
    if (discount == null) {
      return 'Enter a valid discount';
    }
    if (discount < 0) {
      return 'Discount cannot be negative';
    }

    final deposit = _parseAmount(_payingNowController.text) ?? 0;
    final outstanding = _outstandingBalance;
    final totalApplied = deposit + discount;

    if (totalApplied - outstanding > _amountEpsilon) {
      return 'Payment plus discount cannot exceed outstanding balance';
    }

    if (_paymentAction == _FundPaymentAction.settleFull) {
      final expectedDeposit = outstanding - discount;
      if (expectedDeposit < 0) {
        return 'Discount cannot exceed outstanding balance';
      }
      if (!_amountsEqual(deposit, expectedDeposit)) {
        return 'Adjust deposit or discount so they equal the outstanding balance';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _payingNowController.removeListener(_onPayingNowAmountChanged);
    _discountController.removeListener(_onDiscountChanged);
    _totalAmountController.dispose();
    _totalPaidAmountController.dispose();
    _remainingAmountController.dispose();
    _payingNowController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onInvestorChanged(String? name) {
    if (!mounted) return;
    final investors = context.read<FundingPaymentsCubit>().investors;
    final selected = investors.cast<InvestorModel?>().firstWhere(
      (investor) => investor?.fullName == name,
      orElse: () => null,
    );

    setState(() {
      _selectedInvestor = selected;
      _paymentAction = _FundPaymentAction.none;
      _payingNowController.clear();
      _discountController.clear();
      _selectedPaymentMethod = null;
      if (selected == null) {
        _resetDueState();
        _totalAmountController.text = '';
      } else {
        _initDueForInvestor(selected);
        _totalAmountController.text = _formatCurrency(
          selected.totalInvestmentAmount,
        );
      }
      _syncAmountDisplays();
    });
  }

  void _handleSettleFull() {
    if (!mounted) return;
    if (_selectedInvestor == null) {
      AppToast.error('Please select an investor', context: context);
      return;
    }

    if (_outstandingBalance <= 0) {
      AppToast.error('Investment is already fully paid', context: context);
      return;
    }

    setState(() => _paymentAction = _FundPaymentAction.settleFull);
    _setPayingNowAmount(_outstandingBalance - _currentDiscount);
    _formKey.currentState?.validate();
  }

  void _handleBack() {
    if (!mounted) return;
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false);
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleSaveSuccess() {
    if (!mounted) return;
    if (widget.onSaveSuccess != null) {
      widget.onSaveSuccess!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
      return;
    }
    _handleBack();
  }

  Future<void> _handleSave() async {
    if (!mounted) return;

    final cubit = context.read<FundingPaymentsCubit>();
    if (cubit.state is AddPaymentLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }

    if (_selectedInvestor == null) {
      AppToast.error('Please select an investor', context: context);
      return;
    }

    final paidAmount = _parseAmount(_payingNowController.text);
    if (paidAmount == null || paidAmount <= 0) {
      AppToast.error('Enter a valid paying amount', context: context);
      return;
    }

    final discount = _parseAmount(_discountController.text) ?? 0;
    if (discount < 0) {
      AppToast.error('Discount cannot be negative', context: context);
      return;
    }

    final outstanding = _outstandingBalance;
    final totalApplied = paidAmount + discount;
    if (totalApplied - outstanding > _amountEpsilon) {
      AppToast.error(
        'Payment plus discount cannot exceed outstanding balance',
        context: context,
      );
      return;
    }

    final isFullSettlement = _paymentAction == _FundPaymentAction.settleFull;
    if (isFullSettlement && !_amountsEqual(totalApplied, outstanding)) {
      AppToast.error(
        'Full settlement requires deposit plus discount to equal outstanding balance',
        context: context,
      );
      return;
    }

    if (_selectedPaymentMethod == null ||
        _selectedPaymentMethod!.trim().isEmpty) {
      AppToast.error('Please select a payment method', context: context);
      return;
    }

    final request = AddInvestorPaymentRequestModel(
      userId: _selectedInvestor!.userId,
      paidAmount: paidAmount,
      narration: _descriptionController.text.trim(),
      paymentMethod: _selectedPaymentMethod!,
      isFullSettlement: isFullSettlement,
      discountAmount: discount,
      remarks: '',
    );

    await cubit.addInvestorPayment(request);
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
    final raw = isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
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
            _handleSaveSuccess();
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
        final isLoadingInvestors =
            state is FundingInvestorsLoading ||
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
              final horizontalPadding = constraints.maxWidth < 600
                  ? 16.0
                  : 24.0;
              final isNarrow = constraints.maxWidth < 980;

              final payingNowText = _payingNowController.text.trim();
              final payingNowAmount = _parseAmount(payingNowText);
              final formattedPayingNow =
                  payingNowAmount != null && payingNowAmount > 0
                  ? _formatCurrency(payingNowAmount)
                  : null;

              final formCard = AddFundFormCard(
                formKey: _formKey,
                investor: _selectedInvestor?.fullName,
                investorOptions: investorNames,
                onInvestorChanged: _onInvestorChanged,
                investorType: _selectedInvestor?.investorType,
                totalAmountController: _totalAmountController,
                totalPaidAmountController: _totalPaidAmountController,
                remainingAmountController: _remainingAmountController,
                dueAmountLabel: _selectedInvestor == null
                    ? null
                    : _formatCurrency(_dueRemainingAmount),
                dueDateLabel: _dueDate == null ? null : _formatDate(_dueDate!),
                dueStatus: _selectedInvestor == null ? null : _dueStatus,
                payingNowController: _payingNowController,
                payingNowValidator: _validatePayingNow,
                onSettleFull: _handleSettleFull,
                canSettleFull: _canSettleFull,
                discountController: _discountController,
                discountValidator: _validateDiscount,
                descriptionController: _descriptionController,
                paymentMethodOptions: kFundPaymentMethodOptions,
                selectedPaymentMethod: _selectedPaymentMethod,
                onPaymentMethodChanged: (value) =>
                    setState(() => _selectedPaymentMethod = value),
                fundingDate: _fundingDate,
                onPickDate: _pickDate,
                formatDate: _formatDate,
                isLoadingInvestors: isLoadingInvestors,
              );

              final sidePanel = AddFundSidePanel(
                investor: _selectedInvestor?.fullName,
                fundingType: _selectedInvestor?.investorType,
                totalAmount: _totalAmountController.text.isEmpty
                    ? null
                    : _totalAmountController.text,
                paidAmount: _totalPaidAmountController.text.isEmpty
                    ? null
                    : _totalPaidAmountController.text,
                remainingAmount: _remainingAmountController.text.isEmpty
                    ? null
                    : _remainingAmountController.text,
                dueAmount: _selectedInvestor == null
                    ? null
                    : _formatCurrency(_dueRemainingAmount),
                dueDate: _dueDate == null ? null : _formatDate(_dueDate!),
                dueStatus: _selectedInvestor == null ? null : _dueStatus,
                payingNow:
                    formattedPayingNow ??
                    (payingNowText.isEmpty ? null : payingNowText),
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
