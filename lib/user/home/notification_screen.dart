import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/user/home/cubit/notifications_cubit.dart';
import 'package:maribel_wellness_centre_application/user/home/model/app_notification_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const Color _bg = Color(0xFFF3F2F2);
  static const Color _textPrimary = Color(0xFF2F2F2F);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _time = Color(0xFF4DB6AC);
  static const Color _unreadDot = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..loadNotifications(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  static const _silentRefreshInterval = Duration(seconds: 5);

  Timer? _silentRefreshTimer;
  bool _isSilentRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startSilentRefresh();
  }

  @override
  void dispose() {
    _stopSilentRefresh();
    super.dispose();
  }

  void _startSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = Timer.periodic(
      _silentRefreshInterval,
      (_) => _silentRefresh(),
    );
  }

  void _stopSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = null;
  }

  Future<void> _silentRefresh() async {
    if (!mounted || _isSilentRefreshing) return;

    _isSilentRefreshing = true;
    try {
      await context.read<NotificationsCubit>().loadNotifications(silent: true);
    } finally {
      _isSilentRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.8.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 5.5.w,
                            color: NotificationScreen._textPrimary,
                          ),
                          SizedBox(width: 1.5.w),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: NotificationScreen._textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    buildWhen: (previous, current) {
                      final prevUnread = previous is NotificationsSuccess
                          ? previous.unreadCount
                          : -1;
                      final currUnread = current is NotificationsSuccess
                          ? current.unreadCount
                          : -1;
                      return prevUnread != currUnread ||
                          previous.runtimeType != current.runtimeType;
                    },
                    builder: (context, state) {
                      final unreadCount = state is NotificationsSuccess
                          ? state.unreadCount
                          : 0;
                      if (unreadCount <= 0) {
                        return const SizedBox.shrink();
                      }

                      return TextButton(
                        onPressed: () => context
                            .read<NotificationsCubit>()
                            .markAllAsRead(),
                        style: TextButton.styleFrom(
                          foregroundColor: NotificationScreen._time,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.6.h,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mark all as read',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading ||
                      state is NotificationsInitial) {
                    return const _NotificationsShimmer();
                  }

                  if (state is NotificationsFailure) {
                    return _NotificationsError(
                      message: state.message,
                      onRetry: () => context
                          .read<NotificationsCubit>()
                          .loadNotifications(),
                    );
                  }

                  final notifications =
                      (state as NotificationsSuccess).notifications;

                  if (notifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: NotificationScreen._textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: NotificationScreen._time,
                    onRefresh: () => context
                        .read<NotificationsCubit>()
                        .loadNotifications(),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 1.4.h),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _NotificationCard(
                          item: item,
                          onTap: () => context
                              .read<NotificationsCubit>()
                              .markAsRead(item.notificationId),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsShimmer extends StatelessWidget {
  const _NotificationsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      itemCount: 5,
      separatorBuilder: (_, _) => SizedBox(height: 1.4.h),
      itemBuilder: (_, _) => const _NotificationCardShimmer(),
    );
  }
}

class _NotificationCardShell extends StatelessWidget {
  const _NotificationCardShell({
    required this.child,
    this.color = NotificationScreen._bg,
  });

  final Widget child;
  final Color color;

  /// Matches a typical card: title + 2-line message + 2-line time.
  static double get minHeight => 16.h;

  static EdgeInsets get padding =>
      EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NotificationCardShimmer extends StatelessWidget {
  const _NotificationCardShimmer();

  static const Color _shimmerBase = Color(0xFFD6D6D6);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const Color _block = Color(0xFFD6D6D6);

  @override
  Widget build(BuildContext context) {
    final titleHeight = 15.sp * 1.2;
    final lineHeight = 13.sp * 1.4;
    final timeLineHeight = 13.sp * 1.3;

    // Keep the card shell static so only the inner bars animate.
    return _NotificationCardShell(
      child: Shimmer.fromColors(
        baseColor: _shimmerBase,
        highlightColor: _shimmerHighlight,
        direction: ShimmerDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBar(width: 42.w, height: titleHeight),
                  SizedBox(height: 0.8.h),
                  FractionallySizedBox(
                    widthFactor: 0.85,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBar(
                          width: double.infinity,
                          height: lineHeight,
                        ),
                        SizedBox(height: 0.45.h),
                        _ShimmerBar(width: 55.w, height: lineHeight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ShimmerBar(width: 14.w, height: timeLineHeight),
                SizedBox(height: 0.35.h),
                _ShimmerBar(width: 18.w, height: timeLineHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _NotificationCardShimmer._block,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: NotificationScreen._textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
  });

  final AppNotificationModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: _NotificationCardShell(
          color: isUnread
              ? NotificationScreen._time.withValues(alpha: 0.2)
              : NotificationScreen._bg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread) ...[
                Padding(
                  padding: EdgeInsets.only(top: 0.4.h),
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: const BoxDecoration(
                      color: NotificationScreen._unreadDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: NotificationScreen._textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    FractionallySizedBox(
                      widthFactor: 0.85,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: NotificationScreen._textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatRelativeTime(item.createdDate),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: isUnread
                      ? NotificationScreen._time
                      : NotificationScreen._textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatRelativeTime(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final local = date.isUtc ? date.toLocal() : date;

  final today = DateTime(now.year, now.month, now.day);
  final localDay = DateTime(local.year, local.month, local.day);
  final dayDiff = today.difference(localDay).inDays;

  if (dayDiff == 0) {
    final diff = now.difference(local);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  if (dayDiff == 1) return 'Yesterday';

  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final day = local.day.toString().padLeft(2, '0');
  final hour24 = local.hour;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day-${months[local.month - 1]}-${local.year}\n$hour12:$minute $period';
}
