import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LatestProjectUpdates extends StatelessWidget {
  const LatestProjectUpdates({super.key});

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF8A8A8A);
  static const Color _button = Color(0xFFA28CC1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Project Updates',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&h=450&fit=crop',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFF0EBF6),
                child: Icon(
                  Icons.apartment_outlined,
                  color: _button,
                  size: 10.w,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  color: const Color(0xFFF0EBF6),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Second Floor Structural Work Completed',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          'The main load-bearing walls and celling structures for the secondary patient wing are now fully cured and approved by site inspectors',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
            height: 1.45,
          ),
        ),
        SizedBox(height: 1.8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: _button,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.2.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Update',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 4.5.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
