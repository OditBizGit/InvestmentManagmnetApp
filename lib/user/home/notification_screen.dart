import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _textPrimary = Color(0xFF2F2F2F);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _time = Color(0xFF4DB6AC);

  static const List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'New Project Updates',
      time: '10m ago',
      description:
          'High-resolution site photos uploaded for alpha healthcare facility',
    ),
    _NotificationItem(
      title: 'New Project Updates',
      time: '2h ago',
      description:
          'High-resolution site photos uploaded for alpha healthcare facility',
    ),
    _NotificationItem(
      title: 'New Project Updates',
      time: '1d ago',
      description:
          'High-resolution site photos uploaded for alpha healthcare facility',
    ),
    _NotificationItem(
      title: 'New Project Updates',
      time: '1d ago',
      description:
          'High-resolution site photos uploaded for alpha healthcare facility',
    ),
    _NotificationItem(
      title: 'New Project Updates',
      time: '1d ago',
      description:
          'High-resolution site photos uploaded for alpha healthcare facility',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                        color: _textPrimary,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => SizedBox(height: 1.4.h),
                itemBuilder: (context, index) {
                  return _NotificationCard(
                    item: _notifications[index],
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

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.time,
    required this.description,
  });

  final String title;
  final String time;
  final String description;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.9.h),
      decoration: BoxDecoration(
        color: Colors.white,
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
                item.time,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: NotificationScreen._time,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          Text(
            item.description,
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
