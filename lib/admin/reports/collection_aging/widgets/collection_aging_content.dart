import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_stat_cards.dart';
import 'package:maribel_wellness_centre_application/admin/user_management/widgets/user_management_table_widgets.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:maribel_wellness_centre_application/core/utils/currency_formatter.dart';
import 'package:sizer/sizer.dart';

import '../cubit/collection_aging_cubit.dart';
import '../model/collection_aging_model.dart';

const String collectionAgingFootnote =
    'Some outstanding amounts (unpaid advance) are not in a due bucket.';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

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
  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} ${date.year}';
}

/// Stat cards + filter toolbar + table. Owns the as-of date and the search
/// text; the screen remounts it (new key) to reset them.
class CollectionAgingContent extends StatefulWidget {
  const CollectionAgingContent({super.key});

  @override
  State<CollectionAgingContent> createState() => _CollectionAgingContentState();
}

class _CollectionAgingContentState extends State<CollectionAgingContent> {
  static const double _minTableWidth = 1500;
  static const double _searchFieldMaxWidth = 260;

  final TextEditingController _searchController = TextEditingController();
  DateTime _asOf = _dateOnly(DateTime.now());
  String? _lastToastedMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetch() => context.read<CollectionAgingCubit>().load(_asOf);

  Future<void> _pickDate() async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _asOf.isAfter(today) ? today : _asOf,
      firstDate: DateTime(2020),
      lastDate: today,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: AppColors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _asOf = _dateOnly(picked));
    _fetch();
  }

  List<CollectionAgingRowModel> _filter(List<CollectionAgingRowModel> rows) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return rows;
    return rows.where((row) {
      return row.name.toLowerCase().contains(query) ||
          row.investorCode.toLowerCase().contains(query) ||
          row.phoneNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionAgingCubit, CollectionAgingState>(
      listener: (context, state) {
        if (state is CollectionAgingError) {
          if (state.message != _lastToastedMessage) {
            _lastToastedMessage = state.message;
            AppToast.error(state.message, context: context);
          }
        } else if (state is CollectionAgingLoaded) {
          _lastToastedMessage = null;
        }
      },
      child: BlocBuilder<CollectionAgingCubit, CollectionAgingState>(
        builder: (context, state) {
          final totals = state is CollectionAgingLoaded
              ? state.report.totals
              : null;
          String money(double? v) =>
              totals == null ? '—' : CurrencyFormatter.format(v ?? 0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserManagementStatCards(
                stats: [
                  UserManagementStatCardData(
                    label: 'Total Overdue',
                    value: money(totals?.totalOverdue),
                    icon: ImageConstants.totalFunding,
                    iconColor: const Color(0xFFE5645F),
                    iconBg: const Color(0xFFFDECEB),
                  ),
                  UserManagementStatCardData(
                    label: '1–30 days',
                    value: money(totals?.days1To30),
                    icon: ImageConstants.reports,
                    iconColor: const Color(0xFF5B8DEF),
                    iconBg: const Color(0xFFEAF1FC),
                  ),
                  UserManagementStatCardData(
                    label: '31–60 days',
                    value: money(totals?.days31To60),
                    icon: ImageConstants.workProgress,
                    iconColor: const Color(0xFFE89A3C),
                    iconBg: const Color(0xFFFFF3E8),
                  ),
                  UserManagementStatCardData(
                    label: '61–90 days',
                    value: money(totals?.days61To90),
                    icon: ImageConstants.totalInvestors,
                    iconColor: const Color(0xFF9B7EBF),
                    iconBg: const Color(0xFFF0EBF6),
                  ),
                  UserManagementStatCardData(
                    label: '90+ days',
                    value: money(totals?.days90Plus),
                    icon: ImageConstants.reports,
                    iconColor: const Color(0xFFE5645F),
                    iconBg: const Color(0xFFFDECEB),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              UserManagementTableCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Toolbar(
                      searchController: _searchController,
                      asOf: _asOf,
                      searchFieldMaxWidth: _searchFieldMaxWidth,
                      onPickDate: _pickDate,
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, _, _) => _buildBody(context, state),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CollectionAgingState state) {
    if (state is CollectionAgingLoading || state is CollectionAgingInitial) {
      return const Padding(
        padding: EdgeInsets.only(top: 14),
        child: SizedBox(
          height: 260,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    if (state is CollectionAgingError) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SizedBox(
          height: 260,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _fetch,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final all = (state as CollectionAgingLoaded).report.rows;
    final rows = _filter(all);
    final showFootnote = rows.any((r) => r.hasUnbucketedOutstanding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (all.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${rows.length} investor records found',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 14),
        UserManagementTableFrame(
          minTableWidth: _minTableWidth,
          header: const UserManagementHeaderRow(
            children: [
              UserManagementHeaderCell('Code', flex: 2),
              UserManagementHeaderCell('Name', flex: 3),
              UserManagementHeaderCell('Status', flex: 2),
              UserManagementHeaderCell('Outstanding', flex: 3),
              UserManagementHeaderCell('Not yet due', flex: 3),
              UserManagementHeaderCell('1–30', flex: 3),
              UserManagementHeaderCell('31–60', flex: 3),
              UserManagementHeaderCell('61–90', flex: 3),
              UserManagementHeaderCell('90+', flex: 3),
              UserManagementHeaderCell('Oldest due', flex: 3),
            ],
          ),
          rowCount: rows.length,
          emptyMessage: 'No records found',
          rowBuilder: (context, index) =>
              _AgingRow(index: index, row: rows[index]),
        ),
        if (showFootnote) ...[
          const SizedBox(height: 10),
          Text(
            collectionAgingFootnote,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _AgingRow extends StatelessWidget {
  const _AgingRow({required this.index, required this.row});

  final int index;
  final CollectionAgingRowModel row;

  @override
  Widget build(BuildContext context) {
    String money(double v) => CurrencyFormatter.format(v);
    final oldest = row.oldestDueDate;

    return ColoredBox(
      color: index.isEven ? AppColors.white : const Color(0xFFFBF9FC),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  row.investorCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              UserManagementDataCell(row.name, flex: 3),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: UserManagementStatusBadge(
                    label: row.isActive ? 'Active' : 'Blocked',
                    tone: row.isActive
                        ? UserManagementBadgeTone.success
                        : UserManagementBadgeTone.danger,
                  ),
                ),
              ),
              UserManagementDataCell(money(row.outstanding), flex: 3),
              UserManagementDataCell(money(row.notYetDue), flex: 3),
              UserManagementDataCell(money(row.days1To30), flex: 3),
              UserManagementDataCell(money(row.days31To60), flex: 3),
              UserManagementDataCell(money(row.days61To90), flex: 3),
              UserManagementDataCell(money(row.days90Plus), flex: 3),
              UserManagementDataCell(
                oldest == null ? '—' : _formatDate(oldest),
                flex: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.asOf,
    required this.searchFieldMaxWidth,
    required this.onPickDate,
  });

  final TextEditingController searchController;
  final DateTime asOf;
  final double searchFieldMaxWidth;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final searchField = SizedBox(
          width: isCompact ? double.infinity : searchFieldMaxWidth,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, value, _) {
              return TextField(
                controller: searchController,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name, code or phone',
                  hintStyle: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.hint,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      ImageConstants.search,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.hint,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          onPressed: searchController.clear,
                          splashRadius: 18,
                          tooltip: 'Clear search',
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.white,
                  isDense: true,
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
              );
            },
          ),
        );

        final dateButton = InkWell(
          onTap: onPickDate,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  ImageConstants.calender,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'As of ${_formatDate(asOf)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: dateButton),
            ],
          );
        }

        return Row(children: [searchField, const Spacer(), dateButton]);
      },
    );
  }
}
