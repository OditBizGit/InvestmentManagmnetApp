import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class ServiceGalleryCarousel extends StatefulWidget {
  const ServiceGalleryCarousel({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  static const Color _accent = Color(0xFFA28CC1);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  @override
  State<ServiceGalleryCarousel> createState() =>
      _ServiceGalleryCarouselState();
}

class _ServiceGalleryCarouselState extends State<ServiceGalleryCarousel> {
  int _currentIndex = 0;

  static const List<String> _galleryImages = [
    'https://maribel.in/wp-content/uploads/2026/02/Untitled-design-2026-01-22T204942.807-1024x512.png',
    'https://maribel.in/wp-content/uploads/2026/02/BROCHURE-COPY-4-1024x724.png',
    'https://maribel.in/wp-content/uploads/2026/02/BROCHURE-COPY-1-1536x1086.png',
    'https://maribel.in/wp-content/uploads/2026/02/Untitled-design-2026-02-12T043147.060.png',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const _GalleryShimmer();
    }

    return SizedBox(
      height: 25.h,
      width: double.infinity,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: _galleryImages.length,
            itemBuilder: (context, index, realIndex) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                child: _GalleryImage(url: _galleryImages[index]),
              );
            },
            options: CarouselOptions(
              height: 25.h,
              viewportFraction: 1,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 1.5.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_galleryImages.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 0.8.w),
                  width: isActive ? 2.5.w : 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isActive
                        ? null
                        : Border.all(color: Colors.white, width: 1),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryShimmer extends StatelessWidget {
  const _GalleryShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25.h,
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: ServiceGalleryCarousel._shimmerBase,
        highlightColor: ServiceGalleryCarousel._shimmerHighlight,
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 1400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({required this.url});

  static const Color _accent = Color(0xFFA28CC1);
  static const Color _cardBg = Color(0xFFF0EBF6);

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: _cardBg,
          child: Icon(
            Icons.local_hospital_outlined,
            color: _accent,
            size: 8.w,
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: _cardBg,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}
