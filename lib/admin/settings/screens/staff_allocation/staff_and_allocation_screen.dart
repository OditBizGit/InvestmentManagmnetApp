import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/cubit/staff_allocation_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/model/get_staff_response_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/repository/staff_allocation_repository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/widgets/add_staff_form_card.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/widgets/staff_allocation_header.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/widgets/staff_investor_allocations_view.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/staff_allocation/widgets/staff_list_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:sizer/sizer.dart';

class StaffAndAllocationScreen extends StatelessWidget {
  const StaffAndAllocationScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<StaffRepository>(
      create: (_) => StaffRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => StaffAllocationCubit(
          repository: context.read<StaffRepository>(),
        )..fetchStaff(),
        child: _StaffAndAllocationView(onBack: onBack),
      ),
    );
  }
}

class _StaffAndAllocationView extends StatefulWidget {
  const _StaffAndAllocationView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_StaffAndAllocationView> createState() =>
      _StaffAndAllocationViewState();
}

class _StaffAndAllocationViewState extends State<_StaffAndAllocationView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedDesignation;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleBackToSettings() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleBackToList() {
    context.read<StaffAllocationCubit>().closeStaffDetail();
  }

  void _openStaffDetail(StaffModel staff) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<StaffAllocationCubit>().fetchInvestorsByStaff(staff);
  }

  void _clearForm() {
    FocusScope.of(context).unfocus();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() => _selectedDesignation = null);
    _formKey.currentState?.reset();
  }

  void _handleAddStaff() {
    submitAddStaffForm(
      context: context,
      formKey: _formKey,
      fullNameController: _fullNameController,
      emailController: _emailController,
      phoneController: _phoneController,
      selectedDesignation: _selectedDesignation,
    );
  }

  List<StaffModel> _staffMembersFromState(StaffAllocationState state) {
    if (state is StaffAllocationStaffLoaded) {
      return state.staffMembers;
    }
    if (state is StaffAllocationStaffLoadFailure) {
      return const [];
    }
    return const [];
  }

  Widget? _buildStaffDetailView(
    BuildContext context,
    StaffAllocationState state,
  ) {
    if (state is StaffAllocationInvestorsLoading) {
      return StaffInvestorAllocationsView(
        staff: state.staff,
        investors: const [],
        isLoadingInvestors: true,
        onBack: _handleBackToList,
      );
    }
    if (state is StaffAllocationInvestorsLoaded) {
      return StaffInvestorAllocationsView(
        staff: state.staff,
        investors: state.investors,
        onBack: _handleBackToList,
      );
    }
    if (state is StaffAllocationInvestorsLoadFailure) {
      return StaffInvestorAllocationsView(
        staff: state.staff,
        investors: const [],
        onBack: _handleBackToList,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffAllocationCubit, StaffAllocationState>(
      builder: (context, state) {
        final detailView = _buildStaffDetailView(context, state);
        if (detailView != null) {
          return AddStaffCreationListener(
            onClearForm: _clearForm,
            child: detailView,
          );
        }

        final staffMembers = _staffMembersFromState(state);
        final isCreating =
            state is StaffAllocationStaffLoaded && state.isCreating;
        final isListLoading = state is StaffAllocationStaffLoading;
        final isListRefreshing =
            state is StaffAllocationStaffLoaded && state.isRefreshing;

        return AddStaffCreationListener(
          onClearForm: _clearForm,
          child: ColoredBox(
            color: AppColors.screenBg,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth < 600 ? 16.0 : 24.0;
                final isNarrow = constraints.maxWidth < 980;

                final formCard = AddStaffFormCard(
                  formKey: _formKey,
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  selectedDesignation: _selectedDesignation,
                  onDesignationChanged: (value) {
                    setState(() => _selectedDesignation = value);
                  },
                );

                final listSection = isListLoading
                    ? const _StaffListLoadingPlaceholder()
                    : StaffListSection(
                        staffMembers: staffMembers,
                        onStaffTap: _openStaffDetail,
                        isRefreshing: isListRefreshing,
                      );

                final actionButtons = AddStaffActionButtons(
                  onClear: _clearForm,
                  onAdd: _handleAddStaff,
                  isLoading: isCreating,
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
                      child: StaffAllocationHeader(
                        breadcrumbLeaf: 'Add Staff and Allocation',
                        title: 'Add Staff and Allocation',
                        subtitle:
                            'Manage staff members and investor assignments',
                        backLabel: 'Back to Settings',
                        onBack: _handleBackToSettings,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        child: isNarrow
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  formCard,
                                  const SizedBox(height: 16),
                                  actionButtons,
                                  const SizedBox(height: 20),
                                  listSection,
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 7, child: formCard),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _StaffNotesCard(),
                                            const SizedBox(height: 16),
                                            actionButtons,
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  listSection,
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _StaffListLoadingPlaceholder extends StatelessWidget {
  const _StaffListLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}

class _StaffNotesCard extends StatelessWidget {
  static const _notes = [
    'Full name, designation, and phone are required',
    'Tap a staff row to view assigned investors',
    'Staff list is loaded from the server',
    'New staff are saved via the Create Staff API',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final note in _notes) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 5,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
