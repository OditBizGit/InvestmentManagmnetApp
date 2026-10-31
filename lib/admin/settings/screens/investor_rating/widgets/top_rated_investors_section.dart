import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/cubit/investor_rating_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/top_investors_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/interactive_star_rating.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class TopRatedInvestorsSection extends StatelessWidget {
  const TopRatedInvestorsSection({
    super.key,
    required this.state,
  });

  final InvestorRatingState state;

  @override
  Widget build(BuildContext context) {
    final entries = state.topInvestors;

    return UserManagementTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Rated Investors',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Up to ${InvestorRatingState.maxTopRated} investors shown on dashboards',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBF6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.topRatedCounterLabel,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isLoadingTopInvestors)
            const SizedBox(
              height: 80,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.accent,
                  ),
                ),
              ),
            )
          else if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'No Top Rated investors yet. Save star ratings per row, select '
                'investors with the checkboxes, then tap Save.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final investor in entries)
                  _TopRatedChip(
                    investor: investor,
                    isRemoving: state.isRemovingTopInvestor(investor.userId),
                    removeEnabled:
                        !state.isSaving && !state.isRemovingTopInvestorAny,
                    onRemove: () => context
                        .read<InvestorRatingCubit>()
                        .removeTopInvestor(investor.userId),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TopRatedChip extends StatelessWidget {
  const _TopRatedChip({
    required this.investor,
    required this.isRemoving,
    required this.removeEnabled,
    required this.onRemove,
  });

  final TopInvestorModel investor;
  final bool isRemoving;
  final bool removeEnabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final rating = investor.savedStarRating ?? 0;
    final canTapRemove = removeEnabled && !isRemoving;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFF0EBF6),
                child: Text(
                  investor.initials,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investor.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (rating >= 1)
                      ReadOnlyStarRating(rating: rating, starSize: 14)
                    else
                      Text(
                        'Not rated',
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: AppColors.white,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: canTapRemove ? onRemove : null,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 26,
                height: 26,
                child: Center(
                  child: isRemoving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        )
                      : Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: canTapRemove
                              ? AppColors.textMuted
                              : AppColors.hint,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
