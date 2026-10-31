import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/cubit/investor_rating_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/repository/investor_rating_repository.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/investor_rating_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/top_rated_investors_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

class InvestorRatingScreen extends StatelessWidget {
  const InvestorRatingScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<InvestorRatingRepository>(
      create: (_) => InvestorRatingRepository(getIt<Dio>()),
      child: BlocProvider(
        create: (context) => InvestorRatingCubit(
          repository: context.read<InvestorRatingRepository>(),
        )..fetchInvestorRatingDetails(),
        child: _InvestorRatingView(onBack: onBack),
      ),
    );
  }
}

class _InvestorRatingView extends StatefulWidget {
  const _InvestorRatingView({this.onBack});

  final VoidCallback? onBack;

  @override
  State<_InvestorRatingView> createState() => _InvestorRatingViewState();
}

class _InvestorRatingViewState extends State<_InvestorRatingView> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;

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
                child: BlocBuilder<InvestorRatingCubit, InvestorRatingState>(
                  builder: (context, state) {
                    return _InvestorRatingHeader(
                      onBack: widget.onBack,
                      isSaving: state.isSaving,
                      onSave: () =>
                          context.read<InvestorRatingCubit>().saveAllRatings(),
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocConsumer<InvestorRatingCubit, InvestorRatingState>(
                  listenWhen: (previous, current) {
                    final bannerChanged =
                        previous.bannerMessage != current.bannerMessage &&
                            current.bannerMessage != null;
                    final loadErrorChanged =
                        previous.loadError != current.loadError &&
                            current.loadError != null &&
                            !current.isLoading;
                    return bannerChanged || loadErrorChanged;
                  },
                  listener: (context, state) {
                    final cubit = context.read<InvestorRatingCubit>();
                    const title = 'Investor Rating';

                    if (state.bannerMessage != null) {
                      if (state.bannerIsError) {
                        AppToast.error(
                          state.bannerMessage!,
                          title: title,
                          context: context,
                        );
                      } else {
                        AppToast.success(
                          state.bannerMessage!,
                          title: title,
                          context: context,
                        );
                      }
                      cubit.dismissBanner();
                    } else if (state.loadError != null) {
                      AppToast.error(
                        state.loadError!,
                        title: title,
                        context: context,
                      );
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!state.isLoading && state.loadError == null)
                            TopRatedInvestorsSection(state: state),
                          if (!state.isLoading && state.loadError == null)
                            const SizedBox(height: 16),
                          const InvestorRatingTableSection(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InvestorRatingHeader extends StatelessWidget {
  const _InvestorRatingHeader({
    this.onBack,
    required this.isSaving,
    required this.onSave,
  });

  final VoidCallback? onBack;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings  >  Investor Rating',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Investor Rating',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Save star ratings per row, select Top Rated with checkboxes, then Save',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final saveButton = SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: const Color(0xFFE8E6EC),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );

        final back = onBack == null
            ? null
            : Material(
                color: AppColors.newBorder,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              saveButton,
              if (back != null) ...[
                const SizedBox(height: 8),
                back,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            saveButton,
            if (back != null) ...[
              const SizedBox(width: 10),
              back,
            ],
          ],
        );
      },
    );
  }
}
