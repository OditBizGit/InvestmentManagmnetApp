import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/cubit/investor_rating_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_record.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/interactive_star_rating.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class TopRatedInvestorsSection extends StatelessWidget {
  const TopRatedInvestorsSection({
    super.key,
    required this.state,
    required this.onRemove,
  });

  final InvestorRatingState state;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final entries = state.topRatedInvestorCodes
        .map(state.investorByCode)
        .whereType<InvestorRatingRecord>()
        .toList();

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
          if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'No Top Rated investors yet. Select investors from the table below, '
                'assign stars, then use Add to Top Rated.',
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
                    rating: state.effectiveRating(investor.investorCode) ?? 0,
                    onRemove: () => onRemove(investor.investorCode),
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
    required this.rating,
    required this.onRemove,
  });

  final InvestorRatingRecord investor;
  final int rating;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
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
                    'Rating required',
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.textMuted,
            tooltip: 'Remove from Top Rated',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
