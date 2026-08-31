import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PhaseProgressCard extends StatelessWidget {
  const PhaseProgressCard({super.key});

  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _progress = Color(0xFF4DB6AC);
  static const Color _track = Color(0xFFE8E8E8);

  static const List<_ProgressItem> _items = [
    _ProgressItem(label: 'Structure', progress: 0.12),
    _ProgressItem(label: 'Brick work', progress: 0.48),
    _ProgressItem(label: 'MEP', progress: 0.68),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.handyman_outlined,
                color: _progress,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Phase 1 progress.',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          for (int i = 0; i < _items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == _items.length - 1 ? 0 : 1.6.h,
              ),
              child: _ProgressRow(item: _items[i]),
            ),
        ],
      ),
    );
  }
}

class _ProgressItem {
  const _ProgressItem({
    required this.label,
    required this.progress,
  });

  final String label;
  final double progress;
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final _ProgressItem item;

  @override
  Widget build(BuildContext context) {
    final percent = (item.progress * 100).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: PhaseProgressCard._textPrimary,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: PhaseProgressCard._textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 0.7.h,
            backgroundColor: PhaseProgressCard._track,
            valueColor: const AlwaysStoppedAnimation<Color>(
              PhaseProgressCard._progress,
            ),
          ),
        ),
      ],
    );
  }
}
