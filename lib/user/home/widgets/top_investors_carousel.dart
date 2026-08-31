import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TopInvestorsCarousel extends StatelessWidget {
  const TopInvestorsCarousel({super.key});

  static const Color _cardBg = Color(0xFFF0EBF6);
  static const Color _textPrimary = Color(0xFF4A3F5C);

  static const List<_InvestorData> _investors = [
    _InvestorData(
      name: 'Investors Nam..',
      amount: '2 Cr',
      imageUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
      rating: 5,
    ),
    _InvestorData(
      name: 'Investors Nam..',
      amount: '25 Lack',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop',
      rating: 5,
    ),
    _InvestorData(
      name: 'Investors Nam..',
      amount: '2 Cr',
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
      rating: 5,
    ),
    _InvestorData(
      name: 'Investors Nam..',
      amount: '1.5 Cr',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
      rating: 4,
    ),
    _InvestorData(
      name: 'Investors Nam..',
      amount: '80 Lack',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
      rating: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Investors',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        CarouselSlider.builder(
          itemCount: _investors.length,
          itemBuilder: (context, index, realIndex) {
            return _InvestorCard(investor: _investors[index]);
          },
          options: CarouselOptions(
            height: 22.h,
            viewportFraction: 0.42,
            enableInfiniteScroll: true,
            padEnds: false,
            autoPlay: false,
            enlargeCenterPage: false,
          ),
        ),
      ],
    );
  }
}

class _InvestorData {
  const _InvestorData({
    required this.name,
    required this.amount,
    required this.imageUrl,
    required this.rating,
  });

  final String name;
  final String amount;
  final String imageUrl;
  final double rating;
}

class _InvestorCard extends StatelessWidget {
  const _InvestorCard({required this.investor});

  final _InvestorData investor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(right: 1.2.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E0ED)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 6.5.w,
            backgroundColor: TopInvestorsCarousel._cardBg,
            backgroundImage: NetworkImage(investor.imageUrl),
          ),
          SizedBox(height: 1.h),
          Text(
            investor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            investor.amount,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final filled = index < investor.rating.round();
              return Icon(
                Icons.star,
                size: 4.2.w,
                color: filled
                    ? const Color(0xFFFFC107)
                    : const Color(0xFFD0D0D0),
              );
            }),
          ),
        ],
      ),
    );
  }
}
