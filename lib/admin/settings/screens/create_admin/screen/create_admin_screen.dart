import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/cubit/create_admin_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/model/create_admin_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/repository/create_admin_repository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/create_admin/screen/widgets/create_admin_form_card.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class CreateAdminScreen extends StatelessWidget {
  const CreateAdminScreen({
    super.key,
    this.onBack,
    this.onCreateSuccess,
  });

  final VoidCallback? onBack;
  final ValueChanged<CreateAdminModel>? onCreateSuccess;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<CreateAdminRepository>(
      create: (_) => CreateAdminRepository(dio: getIt<Dio>()),
      child: BlocProvider(
        create: (context) => CreateAdminCubit(
          repository: context.read<CreateAdminRepository>(),
        ),
        child: _CreateAdminView(
          onBack: onBack,
          onCreateSuccess: onCreateSuccess,
        ),
      ),
    );
  }
}

class _CreateAdminView extends StatefulWidget {
  const _CreateAdminView({
    this.onBack,
    this.onCreateSuccess,
  });

  final VoidCallback? onBack;
  final ValueChanged<CreateAdminModel>? onCreateSuccess;

  @override
  State<_CreateAdminView> createState() => _CreateAdminViewState();
}

class _CreateAdminViewState extends State<_CreateAdminView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _formCardKey = GlobalKey();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternativePhoneController = TextEditingController();

  double? _formCardHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncFormCardHeight();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncFormCardHeight();
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternativePhoneController.dispose();
    super.dispose();
  }

  void _syncFormCardHeight() {
    final box = _formCardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final height = box.size.height;
    if (_formCardHeight == height) return;
    setState(() => _formCardHeight = height);
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    _usernameController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _alternativePhoneController.clear();
    // Remount the Form so AutovalidateMode.onUserInteraction fields
    // do not keep showing errors after controllers are cleared.
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFormCardHeight());
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFormCardHeight());
    if (!isValid) return;

    final model = CreateAdminModel(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      alternativeNumber: _alternativePhoneController.text.trim(),
    );

    context.read<CreateAdminCubit>().createAdmin(model);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateAdminCubit, CreateAdminState>(
      listener: (context, state) {
        if (state is CreateAdminSuccess) {
          AppToast.success(
            state.message,
            title: 'Create Admin',
            context: context,
          );
          _resetForm();
          if (widget.onCreateSuccess != null && state.data != null) {
            widget.onCreateSuccess!(state.data!);
          }
        } else if (state is CreateAdminFailure) {
          AppToast.error(
            state.message,
            title: 'Create Admin',
            context: context,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateAdminLoading;

        return ColoredBox(
          color: AppColors.screenBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 16.0 : 24.0;
              final isNarrow = constraints.maxWidth < 980;

              final formCard = KeyedSubtree(
                key: _formCardKey,
                child: CreateAdminFormCard(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  alternativePhoneController: _alternativePhoneController,
                ),
              );

              final notesCard = CreateAdminNotesCard(
                matchFormHeight: !isNarrow && _formCardHeight != null,
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
                      child: isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                formCard,
                                const SizedBox(height: 16),
                                CreateAdminSidePanel(
                                  onCancel: _handleBack,
                                  onCreate: _handleSubmit,
                                  isLoading: isLoading,
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 7, child: formCard),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 4,
                                      child: _formCardHeight == null
                                          ? notesCard
                                          : SizedBox(
                                              height: _formCardHeight,
                                              child: notesCard,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Spacer(flex: 7),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 4,
                                      child: CreateAdminActionButtons(
                                        onCancel: _handleBack,
                                        onCreate: _handleSubmit,
                                        isLoading: isLoading,
                                      ),
                                    ),
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
                  'Settings',
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
                  'Add New Admin',
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
              'Add New Admin',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a new admin account with login credentials',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Material(
          color: AppColors.newBorder,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    'Back to Settings',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndTitle,
              const SizedBox(height: 12),
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
