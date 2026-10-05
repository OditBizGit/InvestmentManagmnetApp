import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_side_drawer.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_toast.dart';
import 'package:sizer/sizer.dart';

import '../cubit/dashboard_cubit.dart';
import '../model/all_transaction_history_model.dart';
import '../model/recent_updates_model.dart';
import 'dashboard_shimmer.dart';

class DashboardActivitySection extends StatelessWidget {
  const DashboardActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.recentPaymentsLoading &&
              !current.recentPaymentsLoading &&
              current.recentPaymentsError != null,
          listener: (context, state) {
            final message = state.recentPaymentsError!;
            if (message == DashboardCubit.noInternetMessage) return;
            AppToast.error(message, context: context);
          },
        ),
        BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.recentUpdatesLoading &&
              !current.recentUpdatesLoading &&
              current.recentUpdatesError != null,
          listener: (context, state) {
            final message = state.recentUpdatesError!;
            if (message == DashboardCubit.noInternetMessage) return;
            AppToast.error(message, context: context);
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;

          if (isNarrow) {
            return const Column(
              children: [
                _RecentPaymentsCard(),
                SizedBox(height: 14),
                _RecentUpdatesCard(),
                SizedBox(height: 14),
                _QuickActionsCard(),
              ],
            );
          }

          return const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _RecentPaymentsCard()),
                SizedBox(width: 14),
                Expanded(child: _RecentUpdatesCard()),
                SizedBox(width: 14),
                Expanded(child: _QuickActionsCard()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  /// Matches the tallest common filled layout (~title + 5 list rows).
  static const double minHeight = 420;

  /// Body area used by empty / error states so height matches 5 data rows.
  static const double listBodyHeight = 340;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: minHeight),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardStatusBody extends StatelessWidget {
  const _CardStatusBody({
    required this.title,
    required this.message,
    this.isError = false,
  });

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        const SizedBox(height: 8),
        SizedBox(
          height: _Panel.listBodyHeight,
          width: double.infinity,
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: isError ? Colors.red : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    // this.actionLabel,
    // this.onAction,
  });

  final String title;
  // final String? actionLabel;
  // final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // if (actionLabel != null)
        //   TextButton(
        //     onPressed: onAction ?? () {},
        //     style: TextButton.styleFrom(
        //       padding: EdgeInsets.zero,
        //       minimumSize: Size.zero,
        //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //       foregroundColor: AppColors.accent,
        //     ),
        //     child: Text(
        //       actionLabel!,
        //       style: TextStyle(
        //         fontSize: 10.sp,
        //         fontWeight: FontWeight.w600,
        //         color: AppColors.accent,
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}

class _RecentPaymentsCard extends StatelessWidget {
  const _RecentPaymentsCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.recentPaymentsLoading != current.recentPaymentsLoading ||
            previous.recentPaymentsError != current.recentPaymentsError ||
            previous.recentPayments != current.recentPayments ||
            previous.recentPaymentsLoaded != current.recentPaymentsLoaded,
        builder: (context, state) {
          if (state.recentPaymentsLoading) {
            return _buildLoading();
          }

          if (state.recentPaymentsError != null) {
            return _CardStatusBody(
              title: 'Recent Payments',
              message: state.recentPaymentsError!,
              isError: true,
            );
          }

          if (state.recentPaymentsLoaded) {
            return _buildContent(state.recentPayments);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const DashboardRecentPaymentsShimmer();
  }

  Widget _buildContent(List<TransactionHistoryModel> payments) {
    final visiblePayments = payments.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Recent Payments',
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _Panel.listBodyHeight,
          ),
          child: SizedBox(
            width: double.infinity,
            child: visiblePayments.isEmpty
                ? SizedBox(
                    height: _Panel.listBodyHeight,
                    child: Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < visiblePayments.length; i++) ...[
                        _PaymentRow(payment: visiblePayments[i]),
                        if (i < visiblePayments.length - 1)
                          const Divider(height: 1, color: AppColors.border),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final TransactionHistoryModel payment;

  @override
  Widget build(BuildContext context) {
    final name =
        payment.fullName.isNotEmpty ? payment.fullName : 'Unknown Investor';
    final amount = _formatAmount(
      payment.paidAmount > 0 ? payment.paidAmount : payment.pendingAmount,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.cardBg,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(payment.date),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]}, ${date.year}';
  }

  String _formatAmount(double amount) {
    final isWhole = amount == amount.roundToDouble();
    final raw =
        isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final withCommas = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }
}

class _RecentUpdatesCard extends StatelessWidget {
  const _RecentUpdatesCard();

  static const List<Color> _accentColors = [
    Color(0xFF5B8DEF),
    Color(0xFFE89A3C),
    Color(0xFF3CB371),
    Color(0xFF9B7EBF),
    Color(0xFFE57373),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.recentUpdatesLoading != current.recentUpdatesLoading ||
            previous.recentUpdatesError != current.recentUpdatesError ||
            previous.recentUpdates != current.recentUpdates ||
            previous.recentUpdatesLoaded != current.recentUpdatesLoaded,
        builder: (context, state) {
          if (state.recentUpdatesLoading) {
            return _buildLoading();
          }

          if (state.recentUpdatesError != null) {
            return _CardStatusBody(
              title: 'Recent Updates',
              message: state.recentUpdatesError!,
              isError: true,
            );
          }

          if (state.recentUpdatesLoaded) {
            return _buildContent(state.recentUpdates);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Recent Updates',
        ),
        const SizedBox(height: 8),
        const SizedBox(
          height: _Panel.listBodyHeight,
          width: double.infinity,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(List<WorkUpdateModel> updates) {
    final visibleUpdates = updates.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Recent Updates',
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _Panel.listBodyHeight,
          ),
          child: SizedBox(
            width: double.infinity,
            child: visibleUpdates.isEmpty
                ? SizedBox(
                    height: _Panel.listBodyHeight,
                    child: Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < visibleUpdates.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _UpdateRow(
                          update: visibleUpdates[i],
                          color: _accentColors[i % _accentColors.length],
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({
    required this.update,
    required this.color,
  });

  final WorkUpdateModel update;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.construction_outlined,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                update.title.isNotEmpty ? update.title : 'Untitled update',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(update.createdDate),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]}, ${date.year}';
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  static const List<_QuickActionItem> _actions = [
    _QuickActionItem(
      label: 'Add Investor',
      icon: ImageConstants.investors,
      color: AppColors.accent,
      destination: AdminDrawerItem.investors,
    ),
    _QuickActionItem(
      label: 'Add Payment',
      icon: ImageConstants.addPayment,
      color: Color(0xFF2CB5A8),
      destination: AdminDrawerItem.fundingPayments,
    ),
    _QuickActionItem(
      label: 'Work Progress',
      icon: ImageConstants.workProgress,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.workProgress,
    ),
    _QuickActionItem(
      label: 'Reports',
      icon: ImageConstants.reports,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.reports,
    ),
    _QuickActionItem(
      label: 'Settings',
      icon: ImageConstants.updates,
      color: AppColors.textMuted,
      destination: AdminDrawerItem.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topRow = _actions.take(3).toList();
    final bottomRow = _actions.skip(3).toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Quick Actions',
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _Panel.listBodyHeight,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < topRow.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionTile(item: topRow[i]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (var i = 0; i < bottomRow.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionTile(item: bottomRow[i]),
                      ),
                    ],
                    // Keep bottom tiles the same width as the top row of 3.
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _QuickActionItem {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.destination,
  });

  final String label;
  final String icon;
  final Color color;
  final AdminDrawerItem destination;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            AdminNavigateNotification(item.destination).dispatch(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.color.withValues(alpha: 0.45)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  item.icon,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(item.color, BlendMode.srcIn),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
