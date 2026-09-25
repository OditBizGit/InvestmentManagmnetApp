// import 'package:flutter/material.dart';
// import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
// import 'package:sizer/sizer.dart';
//
// class WorkProgressBigCards extends StatelessWidget {
//   const WorkProgressBigCards({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isNarrow = constraints.maxWidth < 900;
//
//         if (isNarrow) {
//           return const Column(
//             children: [
//               _ConstructionProgressCard(),
//               SizedBox(height: 14),
//               _RecentWorkUpdatesCard(),
//             ],
//           );
//         }
//
//         return const IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(child: _ConstructionProgressCard()),
//               SizedBox(width: 14),
//               Expanded(child: _RecentWorkUpdatesCard()),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _Panel extends StatelessWidget {
//   const _Panel({required this.child});
//
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       alignment: Alignment.topLeft,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }
//
// class _ConstructionProgressCard extends StatelessWidget {
//   const _ConstructionProgressCard();
//
//   static const List<_ProgressItem> _items = [
//     _ProgressItem(label: 'Foundation', percent: 100, color: AppColors.green),
//     _ProgressItem(label: 'Structure', percent: 85, color: AppColors.green),
//     _ProgressItem(
//       label: 'Electrical',
//       percent: 60,
//       color: Color(0xFFF2C94C),
//     ),
//     _ProgressItem(
//       label: 'Pluming',
//       percent: 45,
//       color: Color(0xFFE57373),
//     ),
//     _ProgressItem(
//       label: 'Interior',
//       percent: 20,
//       color: Color(0xFFE57373),
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return _Panel(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Construction Progress',
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 18),
//           for (var i = 0; i < _items.length; i++) ...[
//             if (i > 0) const SizedBox(height: 14),
//             _ProgressRow(item: _items[i]),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _ProgressItem {
//   const _ProgressItem({
//     required this.label,
//     required this.percent,
//     required this.color,
//   });
//
//   final String label;
//   final int percent;
//   final Color color;
// }
//
// class _ProgressRow extends StatelessWidget {
//   const _ProgressRow({required this.item});
//
//   final _ProgressItem item;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 item.label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.textMuted,
//                 ),
//               ),
//             ),
//             Text(
//               '${item.percent}%',
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: LinearProgressIndicator(
//             value: item.percent / 100,
//             minHeight: 7,
//             backgroundColor: const Color(0xFFEDEDED),
//             color: item.color,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _RecentWorkUpdatesCard extends StatelessWidget {
//   const _RecentWorkUpdatesCard();
//
//   static const List<_UpdateItem> _updates = [
//     _UpdateItem(
//       title: '2nd Floor Construction Completed Successfully',
//       date: '03 Jun, 2026',
//       status: _UpdateStatus.completed,
//       icon: Icons.apartment_outlined,
//       color: Color(0xFF5B8DEF),
//     ),
//     _UpdateItem(
//       title: '2nd Floor Construction Completed Successfully',
//       date: '03 Jun, 2026',
//       status: _UpdateStatus.inProgress,
//       icon: Icons.construction_outlined,
//       color: Color(0xFFE89A3C),
//     ),
//     _UpdateItem(
//       title: '2nd Floor Construction Completed Successfully',
//       date: '03 Jun, 2026',
//       status: _UpdateStatus.pending,
//       icon: Icons.groups_outlined,
//       color: Color(0xFF3CB371),
//     ),
//     _UpdateItem(
//       title: '2nd Floor Construction Completed Successfully',
//       date: '03 Jun, 2026',
//       status: _UpdateStatus.completed,
//       icon: Icons.home_work_outlined,
//       color: Color(0xFF9B7EBF),
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return _Panel(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Recent Work Updates',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 style: TextButton.styleFrom(
//                   padding: EdgeInsets.zero,
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   foregroundColor: AppColors.accent,
//                 ),
//                 child: Text(
//                   'View All',
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.accent,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           for (var i = 0; i < _updates.length; i++) ...[
//             if (i > 0) const SizedBox(height: 14),
//             _UpdateRow(item: _updates[i]),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// enum _UpdateStatus { completed, inProgress, pending }
//
// class _UpdateItem {
//   const _UpdateItem({
//     required this.title,
//     required this.date,
//     required this.status,
//     required this.icon,
//     required this.color,
//   });
//
//   final String title;
//   final String date;
//   final _UpdateStatus status;
//   final IconData icon;
//   final Color color;
// }
//
// class _UpdateRow extends StatelessWidget {
//   const _UpdateRow({required this.item});
//
//   final _UpdateItem item;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: item.color.withValues(alpha: 0.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(item.icon, color: item.color, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 item.title,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                   height: 1.3,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 item.date,
//                 style: TextStyle(
//                   fontSize: 9.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.textMuted,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//         _StatusBadge(status: item.status),
//       ],
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   const _StatusBadge({required this.status});
//
//   final _UpdateStatus status;
//
//   @override
//   Widget build(BuildContext context) {
//     final (label, textColor, bgColor) = switch (status) {
//       _UpdateStatus.completed => (
//           'Completed',
//           const Color(0xFF1BA752),
//           const Color(0xFFE8F8EF),
//         ),
//       _UpdateStatus.inProgress => (
//           'In Progress',
//           const Color(0xFF5B8DEF),
//           const Color(0xFFEAF1FC),
//         ),
//       _UpdateStatus.pending => (
//           'Pending',
//           const Color(0xFFE06B7A),
//           const Color(0xFFFDECEE),
//         ),
//     };
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 9.sp,
//           fontWeight: FontWeight.w600,
//           color: textColor,
//         ),
//       ),
//     );
//   }
// }
