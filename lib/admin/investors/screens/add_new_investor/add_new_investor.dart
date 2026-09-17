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
  final _fullNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formCardsKey = GlobalKey();

  String? _investorType;
  DateTime? _investmentDate = DateTime.now();
  PickedPhoto? _profilePhoto;
  double? _formCardsHeight;
  bool _heightSyncScheduled = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _organizationController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      phoneNumber: _mobileController.text.trim(),
      investorType: _investorType!.trim(),
      organization: _organizationController.text.trim(),
      address: _addressController.text.trim(),
      investmentAmount: amount,
      investmentDate: _investmentDate!,
      profileImage: profileImage,
    );

    await context.read<InvestorsCubit>().registerInvestor(request);
  }

  void _scheduleFormCardsHeightSync() {
    if (_heightSyncScheduled) return;
    _heightSyncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heightSyncScheduled = false;
      if (!mounted) return;

      final box =
          _formCardsKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;

      final nextHeight = box.size.height;
      if (_formCardsHeight == nextHeight) return;

      if (!mounted) return;
      setState(() => _formCardsHeight = nextHeight);
    });
  }

  Future<void> _pickProfilePhoto() async {
    final photo = await PhotoPickerHelper.pickProfilePhoto();
    if (photo == null || !mounted) return;
    setState(() => _profilePhoto = photo);
  }

  void _clearProfilePhoto() {
    setState(() => _profilePhoto = null);
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

              if (!isNarrow) {
                _scheduleFormCardsHeightSync();
              } else if (_formCardsHeight != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _formCardsHeight != null) {
                    setState(() => _formCardsHeight = null);
                  }
                });
              }

              final formCards = AddInvestorFormCards(
                key: _formCardsKey,
                formKey: _formKey,
                fullNameController: _fullNameController,
                organizationController: _organizationController,
                mobileController: _mobileController,
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
              );

              final sidePanel = AddInvestorSidePanel(
                fillHeight: !isNarrow && _formCardsHeight != null,
                isLoading: isRegistering,
                onCancel: _handleBack,
                onAdd: _handleAdd,
              );

              return SingleChildScrollView(
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
                    if (isNarrow) ...[
                      formCards,
                      const SizedBox(height: 16),
                      sidePanel,
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: formCards),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: _formCardsHeight == null
                                ? sidePanel
                                : SizedBox(
                                    height: _formCardsHeight,
                                    child: sidePanel,
                                  ),
                          ),
                        ],
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
