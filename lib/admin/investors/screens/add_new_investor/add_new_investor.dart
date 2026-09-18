import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/investors/cubit/investors_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/register_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_form_cards.dart';
import 'package:maribel_wellness_centre_application/admin/investors/screens/add_new_investor/widget/add_investor_side_panel.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/photo_picker_helper.dart';
import 'package:sizer/sizer.dart';

class AddNewInvestorScreen extends StatelessWidget {
  const AddNewInvestorScreen({
    super.key,
    this.onBack,
    this.onAddSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onAddSuccess;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<InvestorsRepository>.value(
      value: getIt<InvestorsRepository>(),
      child: BlocProvider(
        create: (context) => InvestorsCubit(
          repository: context.read<InvestorsRepository>(),
        )..fetchInvestorTypes(),
        child: _AddNewInvestorView(
          onBack: onBack,
          onAddSuccess: onAddSuccess,
        ),
      ),
    );
  }
}

class _AddNewInvestorView extends StatefulWidget {
  const _AddNewInvestorView({
    this.onBack,
    this.onAddSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onAddSuccess;

  @override
  State<_AddNewInvestorView> createState() => _AddNewInvestorViewState();
}

class _AddNewInvestorViewState extends State<_AddNewInvestorView> {
  static const List<String> _frequencyOptions = [
    'Month',
    'Week',
    'Day',
  ];
  static const List<String> _installmentCountOptions = [
    '10',
    '12',
    '20',
    '25',
    'Custom',
  ];

  final _fullNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _mobileController = TextEditingController();
  final _alternateMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _customInstallmentController = TextEditingController();
  final _intervalController = TextEditingController();
  final _advancePaymentController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _nomineeNameController = TextEditingController();
  final _nomineeAddressController = TextEditingController();
  final _nomineePhoneController = TextEditingController();
  final _nomineeAadhaarController = TextEditingController();
  final _nomineePanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _investorType;
  DateTime? _investmentDate = DateTime.now();
  PickedPhoto? _profilePhoto;
  PickedPhoto? _nomineePhoto;
  String? _nomineeRelationship;
  DateTime? _nomineeDateOfBirth;
  DateTime? _dateOfBirth;

  /// Set Due Date / Split Payment is always required.
  String _selectedFrequency = 'Month';
  String? _selectedInstallmentCount = '12';
  List<PaymentScheduleInstallment> _paymentSchedule = const [];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_rebuildPaymentSchedule);
    _advancePaymentController.addListener(_rebuildPaymentSchedule);
    _customInstallmentController.addListener(_rebuildPaymentSchedule);
    _intervalController.addListener(_rebuildPaymentSchedule);
    _paymentSchedule = _buildPaymentSchedule();
  }

  @override
  void dispose() {
    _amountController.removeListener(_rebuildPaymentSchedule);
    _advancePaymentController.removeListener(_rebuildPaymentSchedule);
    _customInstallmentController.removeListener(_rebuildPaymentSchedule);
    _intervalController.removeListener(_rebuildPaymentSchedule);
    _fullNameController.dispose();
    _organizationController.dispose();
    _mobileController.dispose();
    _alternateMobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _customInstallmentController.dispose();
    _intervalController.dispose();
    _advancePaymentController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _nomineeNameController.dispose();
    _nomineeAddressController.dispose();
    _nomineePhoneController.dispose();
    _nomineeAadhaarController.dispose();
    _nomineePanController.dispose();
    super.dispose();
  }

  bool get _needsInterval =>
      _selectedFrequency == 'Week' || _selectedFrequency == 'Day';

  double? get _parsedInvestmentAmount {
    final raw = _amountController.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  double? get _parsedAdvancePayment {
    final raw = _advancePaymentController.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return 0;
    return double.tryParse(raw);
  }

  int? get _resolvedInstallmentCount {
    if (_selectedInstallmentCount == null) return null;

    if (_selectedInstallmentCount == 'Custom') {
      final custom = int.tryParse(_customInstallmentController.text.trim());
      if (custom == null || custom <= 0) return null;
      return custom;
    }

    return int.tryParse(_selectedInstallmentCount!);
  }

  int? get _resolvedInterval {
    if (!_needsInterval) return 1;
    final interval = int.tryParse(_intervalController.text.trim());
    if (interval == null || interval <= 0) return null;
    return interval;
  }

  void _rebuildPaymentSchedule() {
    final next = _buildPaymentSchedule();
    if (!_schedulesEqual(_paymentSchedule, next)) {
      setState(() => _paymentSchedule = next);
    }
  }

  bool _schedulesEqual(
    List<PaymentScheduleInstallment> a,
    List<PaymentScheduleInstallment> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].installmentNumber != b[i].installmentNumber ||
          a[i].dueDate != b[i].dueDate ||
          a[i].installmentAmount != b[i].installmentAmount ||
          a[i].paymentStatus != b[i].paymentStatus) {
        return false;
      }
    }
    return true;
  }

  List<PaymentScheduleInstallment> _buildPaymentSchedule() {
    final amount = _parsedInvestmentAmount;
    final advance = _parsedAdvancePayment;
    final count = _resolvedInstallmentCount;
    final interval = _resolvedInterval;
    if (amount == null ||
        amount <= 0 ||
        advance == null ||
        advance < 0 ||
        advance > amount ||
        count == null ||
        count <= 0 ||
        interval == null ||
        interval <= 0) {
      return const [];
    }

    final remaining = _roundToTwoDecimals(amount - advance);
    if (remaining <= 0) return const [];

    final today = DateTime.now();
    final baseAmount = _roundToTwoDecimals(remaining / count);
    final schedule = <PaymentScheduleInstallment>[];

    for (var i = 0; i < count; i++) {
      final isLast = i == count - 1;
      final installmentAmount = isLast
          ? _roundToTwoDecimals(remaining - (baseAmount * (count - 1)))
          : baseAmount;

      schedule.add(
        PaymentScheduleInstallment(
          installmentNumber: i + 1,
          dueDate: _dueDateForInstallment(
            today: today,
            installmentIndex: i,
            interval: interval,
          ),
          installmentAmount: installmentAmount,
          paymentStatus: 'Pending',
        ),
      );
    }

    return schedule;
  }

  DateTime _dueDateForInstallment({
    required DateTime today,
    required int installmentIndex,
    required int interval,
  }) {
    final step = installmentIndex + 1;
    switch (_selectedFrequency) {
      case 'Week':
        return today.add(Duration(days: interval * 7 * step));
      case 'Day':
        return today.add(Duration(days: interval * step));
      case 'Month':
      default:
        // First payment is one month after today, then every month.
        return _addMonthsKeepingDay(today, step);
    }
  }

  static double _roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// Adds [months] to [date], clamping the day when the target month is shorter.
  static DateTime _addMonthsKeepingDay(DateTime date, int months) {
    final totalMonths = date.month - 1 + months;
    final year = date.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
    return DateTime(year, month, day);
  }

  void _onFrequencyChanged(String? frequency) {
    if (frequency == null) return;
    setState(() {
      _selectedFrequency = frequency;
      if (!_needsInterval) {
        _intervalController.clear();
      }
      _paymentSchedule = _buildPaymentSchedule();
    });
  }

  void _onInstallmentCountChanged(String? option) {
    setState(() {
      _selectedInstallmentCount = option;
      if (option != 'Custom') {
        _customInstallmentController.clear();
      }
      _paymentSchedule = _buildPaymentSchedule();
    });
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

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _handleAdd() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }

    if (_investorType == null || _investorType!.trim().isEmpty) {
      AppToast.error('Please select investor type', context: context);
      return;
    }

    if (_investmentDate == null) {
      AppToast.error('Please select investment date', context: context);
      return;
    }

    if (_selectedInstallmentCount == null ||
        _selectedInstallmentCount!.isEmpty) {
      AppToast.error('Please select number of installments', context: context);
      return;
    }

    final count = _resolvedInstallmentCount;
    if (count == null || count <= 0) {
      AppToast.error(
        'Enter a valid number of installments greater than zero',
        context: context,
      );
      return;
    }

    if (_needsInterval) {
      final interval = _resolvedInterval;
      if (interval == null || interval <= 0) {
        AppToast.error(
          _selectedFrequency == 'Week'
              ? 'Enter a valid week interval greater than zero'
              : 'Enter a valid day interval greater than zero',
          context: context,
        );
        return;
      }
    }

    final advance = _parsedAdvancePayment;
    final investmentAmount = _parsedInvestmentAmount;
    if (advance == null || advance < 0) {
      AppToast.error('Enter a valid advance payment', context: context);
      return;
    }
    if (investmentAmount != null && advance > investmentAmount) {
      AppToast.error(
        'Advance payment cannot exceed total investment',
        context: context,
      );
      return;
    }

    if (_paymentSchedule.isEmpty) {
      AppToast.error(
        'Unable to build payment schedule. Check investment and advance amounts.',
        context: context,
      );
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );

    MultipartFile? profileImage;
    if (_profilePhoto != null) {
      profileImage = MultipartFile.fromBytes(
        _profilePhoto!.bytes,
        filename: _profilePhoto!.name,
      );
    }

    final request = RegisterInvestorRequestModel(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      alternativeNumber: _alternateMobileController.text.trim(),
      phoneNumber: _mobileController.text.trim(),
      investorType: _investorType!.trim(),
      organization: _organizationController.text.trim(),
      address: _addressController.text.trim(),
      investmentAmount: amount,
      investmentDate: _investmentDate!,
      profileImage: profileImage,
      investmentSplitMonths: count,
      investmentSplitType: _selectedFrequency,
      investmentAdvanceAmount: advance,
      aadhaarNumber: _aadhaarController.text.trim(),
      panCardNumber: _panController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscController.text.trim(),
      bankName: _bankNameController.text.trim(),
      nomineeName: _nomineeNameController.text.trim(),
      nomineeRelationship: _nomineeRelationship ?? '',
      nomineeAddress: _nomineeAddressController.text.trim(),
      nomineeDateOfBirth: _nomineeDateOfBirth,
      nomineeAadhaarNumber: _nomineeAadhaarController.text.trim(),
      nomineePanCardNumber: _nomineePanController.text.trim(),
      dateOfBirth: _dateOfBirth,
      nomineePhoneNumber: _nomineePhoneController.text.trim(),
      nomineeProfilePhoto: _nomineePhoto != null
          ? MultipartFile.fromBytes(
              _nomineePhoto!.bytes,
              filename: _nomineePhoto!.name,
            )
          : null,
    );

    await context.read<InvestorsCubit>().registerInvestor(request);
  }

  Future<void> _pickProfilePhoto() async {
    final photo = await PhotoPickerHelper.pickProfilePhoto();
    if (photo == null || !mounted) return;
    setState(() => _profilePhoto = photo);
  }

  void _clearProfilePhoto() {
    setState(() => _profilePhoto = null);
  }

  Future<void> _pickNomineePhoto() async {
    final photo = await PhotoPickerHelper.pickProfilePhoto();
    if (photo == null || !mounted) return;
    setState(() => _nomineePhoto = photo);
  }

  void _clearNomineePhoto() {
    setState(() => _nomineePhoto = null);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _investmentDate ?? now,
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
    setState(() => _investmentDate = picked);
  }

  Future<void> _pickNomineeDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nomineeDateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
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
    setState(() => _nomineeDateOfBirth = picked);
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestorsCubit, InvestorsState>(
      listener: (context, state) {
        if (state is RegisterInvestorSuccess) {
          AppToast.success(state.message, context: context);
          // Defer navigation so this screen can finish the current frame
          // before being removed from the tree.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (widget.onAddSuccess != null) {
              widget.onAddSuccess!();
              return;
            }
            _handleBack();
          });
        } else if (state is RegisterInvestorFailure) {
          AppToast.error(state.message, context: context);
        }
      },
      builder: (context, state) {
        final isRegistering = state is RegisterInvestorLoading;

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 16.0 : 24.0;
              final isNarrow = constraints.maxWidth < 980;

              final formCards = AddInvestorFormCards(
                formKey: _formKey,
                fullNameController: _fullNameController,
                organizationController: _organizationController,
                mobileController: _mobileController,
                alternateMobileController: _alternateMobileController,
                emailController: _emailController,
                addressController: _addressController,
                amountController: _amountController,
                usernameController: _usernameController,
                passwordController: _passwordController,
                investorType: _investorType,
                onTypeChanged: (value) =>
                    setState(() => _investorType = value),
                investmentDate: _investmentDate,
                onPickDate: _pickDate,
                formatDate: _formatDate,
                profilePhoto: _profilePhoto,
                onPickProfilePhoto: _pickProfilePhoto,
                onClearProfilePhoto: _clearProfilePhoto,
                monthOptions: _installmentCountOptions,
                selectedMonthOption: _selectedInstallmentCount,
                onMonthOptionChanged: _onInstallmentCountChanged,
                customMonthsController: _customInstallmentController,
                advancePaymentController: _advancePaymentController,
                paymentSchedule: _paymentSchedule,
                formatCurrency: _formatCurrency,
                frequencyOptions: _frequencyOptions,
                selectedFrequency: _selectedFrequency,
                onFrequencyChanged: _onFrequencyChanged,
                intervalController: _intervalController,
                aadhaarController: _aadhaarController,
                panController: _panController,
                bankNameController: _bankNameController,
                ifscController: _ifscController,
                accountNumberController: _accountNumberController,
                nomineeNameController: _nomineeNameController,
                nomineeAddressController: _nomineeAddressController,
                nomineeRelationship: _nomineeRelationship,
                onNomineeRelationshipChanged: (value) =>
                    setState(() => _nomineeRelationship = value),
                nomineeAadhaarController: _nomineeAadhaarController,
                nomineePanController: _nomineePanController,
                nomineeDateOfBirth: _nomineeDateOfBirth,
                dateOfBirth: _dateOfBirth,
                onPickNomineeDateOfBirth: _pickNomineeDateOfBirth,
                nomineePhoneController: _nomineePhoneController,
                nomineePhoto: _nomineePhoto,
                onPickNomineePhoto: _pickNomineePhoto,
                onClearNomineePhoto: _clearNomineePhoto,
              );

              final sidePanel = AddInvestorSidePanel(
                isLoading: isRegistering,
                onCancel: _handleBack,
                onAdd: _handleAdd,
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BreadcrumbHeader(onBack: _handleBack),
                    const SizedBox(height: 20),
                    Expanded(
                      child: isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: formCards,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: constraints.maxHeight * 0.38,
                                  child: sidePanel,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: SingleChildScrollView(
                                    child: formCards,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(flex: 4, child: sidePanel),
                              ],
                            ),
                    ),
                  ],
                ),
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
                  'Investors',
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
                  'Add New Investor',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Add New Investor',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the details to add a new investor to the system.',
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
                  'Back to Investors',
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
