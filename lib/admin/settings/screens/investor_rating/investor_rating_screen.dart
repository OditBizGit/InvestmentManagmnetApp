import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/cubit/investor_rating_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/investor_rating_table_section.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/top_rated_investors_section.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class InvestorRatingScreen extends StatefulWidget {
  const InvestorRatingScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<InvestorRatingScreen> createState() => _InvestorRatingScreenState();
}

class _InvestorRatingScreenState extends State<InvestorRatingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvestorRatingCubit(),
      child: ColoredBox(
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
                        onSaveAll: () =>
                            context.read<InvestorRatingCubit>().saveAllRatings(),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocConsumer<InvestorRatingCubit, InvestorRatingState>(
                    listenWhen: (previous, current) =>
                        previous.bannerMessage != current.bannerMessage &&
                        current.bannerMessage != null,
                    listener: (context, state) {},
                    builder: (context, state) {
                      final cubit = context.read<InvestorRatingCubit>();

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
                            if (state.bannerMessage != null)
                              _RatingBanner(
                                message: state.bannerMessage!,
                                isError: state.bannerIsError,
                                onDismiss: cubit.dismissBanner,
                              ),
                            TopRatedInvestorsSection(
                              state: state,
                              onRemove: cubit.removeFromTopRated,
                            ),
                            const SizedBox(height: 16),
                            InvestorRatingTableSection(
                              state: state,
                              query: _query,
                              searchController: _searchController,
                              onQueryChanged: (value) =>
                                  setState(() => _query = value),
                              onClearQuery: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              onRatingChanged: cubit.setDraftRating,
                              onToggleSelected: cubit.toggleInvestorSelected,
                              onSaveInvestorRating: cubit.saveInvestorRating,
                              onAddToTopRated: cubit.addToTopRated,
                            ),
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
      ),
    );
  }
}

class _RatingBanner extends StatelessWidget {
  const _RatingBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final bg = isError ? const Color(0xFFFDECEE) : const Color(0xFFE6F6EC);
    final fg = isError ? AppColors.error : AppColors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
                size: 18,
                color: fg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close_rounded, size: 18, color: fg),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestorRatingHeader extends StatelessWidget {
  const _InvestorRatingHeader({
    this.onBack,
    required this.isSaving,
    required this.onSaveAll,
  });

  final VoidCallback? onBack;
  final bool isSaving;
  final VoidCallback onSaveAll;

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
              'Assign star ratings and manage up to five Top Rated investors',
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
            onPressed: isSaving ? null : onSaveAll,
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
                    'Save Ratings',
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
