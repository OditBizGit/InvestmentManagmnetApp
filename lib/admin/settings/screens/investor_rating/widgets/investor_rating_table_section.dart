import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/cubit/investor_rating_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/model/investor_rating_details_model.dart';
import 'package:maribel_wellness_centre_application/admin/settings/screens/investor_rating/widgets/interactive_star_rating.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

class InvestorRatingTableSection extends StatefulWidget {
  const InvestorRatingTableSection({super.key});

  @override
  State<InvestorRatingTableSection> createState() =>
      _InvestorRatingTableSectionState();
}

class _InvestorRatingTableSectionState extends State<InvestorRatingTableSection> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InvestorRatingDetailsModel> _filtered(InvestorRatingState state) {
    final text = _query.trim().toLowerCase();
    if (text.isEmpty) return state.investors;
    return state.investors.where((investor) {
      return investor.investorName.toLowerCase().contains(text) ||
          investor.userId.toString().contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestorRatingCubit, InvestorRatingState>(
      builder: (context, state) {
        final cubit = context.read<InvestorRatingCubit>();
        final rows = _filtered(state);

        return UserManagementTableCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 720;
                  final title = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All investors',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Assign stars and manage Top Rated · ${state.investors.length} investors',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  );
                  final search = SizedBox(
                    width: stacked ? double.infinity : 260,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search name or user ID',
                        hintStyle: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.hint,
                        ),
                        suffixIcon: _query.isEmpty
                            ? const Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: AppColors.hint,
                              )
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                              ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        const SizedBox(height: 10),
                        search,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: title),
                      search,
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              if (state.isLoading)
                const SizedBox(
                  height: 220,
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
              else if (state.loadError != null && state.investors.isEmpty)
                _LoadErrorState(
                  message: state.loadError!,
                  onRetry: cubit.fetchInvestorRatingDetails,
                )
              else
                UserManagementTableFrame(
                  minTableWidth: _minTableWidth,
                  emptyMessage: _query.trim().isEmpty
                      ? 'No investors to review'
                      : 'No investors match your search',
                  header: const UserManagementHeaderRow(
                    children: [
                      UserManagementHeaderCell('', flex: 1),
                      UserManagementHeaderCell('Investor', flex: 4),
                      UserManagementHeaderCell('User ID', flex: 2),
                      UserManagementHeaderCell('Committed', flex: 2),
                      UserManagementHeaderCell('Due', flex: 1),
                      UserManagementHeaderCell('On time', flex: 2),
                      UserManagementHeaderCell('Delayed', flex: 2),
                      UserManagementHeaderCell('On-time %', flex: 2),
                      UserManagementHeaderCell('Stars', flex: 3),
                      UserManagementHeaderCell(
                        'Actions',
                        flex: 3,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  rowCount: rows.length,
                  rowBuilder: (context, index) {
                    final investor = rows[index];
                    return _InvestorRatingRow(
                      index: index,
                      investor: investor,
                      state: state,
                      onRatingChanged: (rating) =>
                          cubit.setDraftRating(investor.investorCode, rating),
                      onToggleSelected: () =>
                          cubit.toggleInvestorSelected(investor.investorCode),
                      onSaveRating: () =>
                          cubit.saveInvestorRating(investor.investorCode),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static const double _minTableWidth = 1180;
}

class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.error,
              ),
              const SizedBox(height: 10),
              Text(
                'Could not load investors',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestorRatingRow extends StatelessWidget {
  const _InvestorRatingRow({
    required this.index,
    required this.investor,
    required this.state,
    required this.onRatingChanged,
    required this.onToggleSelected,
    required this.onSaveRating,
  });

  final int index;
  final InvestorRatingDetailsModel investor;
  final InvestorRatingState state;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onToggleSelected;
  final VoidCallback onSaveRating;

  @override
  Widget build(BuildContext context) {
    final code = investor.investorCode;
    final percentage = investor.totalDueCount == 0
        ? null
        : investor.onTimePaymentPercentage;
    final isSavingRow = state.isSavingInvestor(code);
    final isEven = index.isEven;
    final isSelected = state.selectedInvestorCodes.contains(code);
    final isTopRated = state.isInTopRated(code);
    final effectiveRating = state.effectiveRating(code);
    final hasUnsaved = state.hasUnsavedRating(code);
    final checkboxEnabled = !isTopRated && !state.isSaving;

    return Material(
      color: isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 46,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      value: isTopRated ? true : isSelected,
                      tristate: false,
                      onChanged: checkboxEnabled
                          ? (_) => onToggleSelected()
                          : null,
                      activeColor: AppColors.accent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.investorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isTopRated)
                            Text(
                              'Top Rated',
                              style: TextStyle(
                                fontSize: 7.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              UserManagementDataCell('${investor.userId}', flex: 2),
              UserManagementDataCell(
                CurrencyFormatter.format(investor.totalInvestmentAmount),
                flex: 2,
              ),
              UserManagementDataCell('${investor.totalDueCount}', flex: 1),
              UserManagementDataCell('${investor.onTimePaymentCount}', flex: 2),
              UserManagementDataCell('${investor.delayedPaymentCount}', flex: 2),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: UserManagementStatusBadge(
                    label: percentage == null
                        ? 'N/A'
                        : '${percentage.toStringAsFixed(0)}%',
                    tone: _percentageTone(percentage),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InteractiveStarRating(
                    rating: effectiveRating,
                    starSize: 16,
                    onRatingChanged: onRatingChanged,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 0,
                    children: [
                      if (hasUnsaved)
                        TextButton(
                          onPressed: isSavingRow ? null : onSaveRating,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: isSavingRow
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.green,
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

UserManagementBadgeTone _percentageTone(double? percentage) {
  if (percentage == null) return UserManagementBadgeTone.neutral;
  if (percentage >= 90) return UserManagementBadgeTone.success;
  if (percentage >= 70) return UserManagementBadgeTone.warning;
  return UserManagementBadgeTone.danger;
}
