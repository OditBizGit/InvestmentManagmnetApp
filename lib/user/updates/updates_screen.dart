import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserUpdatesScreen extends StatelessWidget {
  const UserUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final updates = [
      {
        'title': 'Q3 Structural Progress Drone Tour',
        'time': 'Uploaded 2 days ago',
        'image':
        'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800',
      },
      {
        'title': 'Q3 Structural Progress Drone Tour',
        'time': 'Uploaded 2 days ago',
        'image':
        'https://images.unsplash.com/photo-1541976590-713941681591?w=800',
      },
      {
        'title': 'Q3 Structural Progress Drone Tour',
        'time': 'Uploaded 2 days ago',
        'image':
        'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=800',
      },
      {
        'title': 'Q3 Structural Progress Drone Tour',
        'time': 'Uploaded 2 days ago',
        'image':
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: 3.h,
            left: 4.w,
            right: 4.w,
            bottom: 2.h,
          ),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            final item = updates[index];
            return _UpdateCard(
              title: item['title']!,
              time: item['time']!,
              imageUrl: item['image']!,
            );
          },
        ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final String title;
  final String time;
  final String imageUrl;

  const _UpdateCard({
    required this.title,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.w),
              topRight: Radius.circular(5.w),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                  // Slight dark overlay for play button contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black87,
                        size: 7.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 3.5.w, color: Colors.grey[500]),
                    SizedBox(width: 1.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.grey[600],
                      ),
                    ),
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