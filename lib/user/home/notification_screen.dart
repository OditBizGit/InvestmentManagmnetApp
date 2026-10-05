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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..loadNotifications(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

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
              child: InkWell(
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
                        .loadNotifications(silent: true),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 1.4.h),
                      itemBuilder: (context, index) {
                        return _NotificationCard(
                          item: notifications[index],
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
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
        itemCount: 5,
        separatorBuilder: (_, _) => SizedBox(height: 1.4.h),
        itemBuilder: (_, _) => Container(
          height: 12.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
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
  const _NotificationCard({required this.item});

  final AppNotificationModel item;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.9.h),
      decoration: BoxDecoration(
        color: isUnread
            ? NotificationScreen._time.withValues(alpha: 0.2)
            : NotificationScreen._bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: NotificationScreen._textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatRelativeTime(item.createdDate),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: isUnread
                      ? NotificationScreen._time
                      : NotificationScreen._textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          Text(
            item.message,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: NotificationScreen._textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRelativeTime(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final local = date.isUtc ? date.toLocal() : date;
  final diff = now.difference(local);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
