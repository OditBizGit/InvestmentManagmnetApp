import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ServiceGalleryCarousel extends StatefulWidget {
  const ServiceGalleryCarousel({super.key});

  @override
  State<ServiceGalleryCarousel> createState() =>
      _ServiceGalleryCarouselState();
}

class _ServiceGalleryCarouselState extends State<ServiceGalleryCarousel> {
  static const Color _accent = Color(0xFFA28CC1);

  int _currentIndex = 0;

  static const List<List<String>> _galleryPages = [
    [
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&h=400&fit=crop',
      'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=400&h=400&fit=crop',
    ],
    [
      'https://images.unsplash.com/photo-1581594693702-fbdc51b2763b?w=400&h=400&fit=crop',
      'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1584515933487-779824d29309?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400&h=400&fit=crop',
    ],
    [
      'https://images.unsplash.com/photo-1666214280557-f1b5022eb634?w=400&h=400&fit=crop',
      'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=400&h=600&fit=crop',
      'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=400&h=400&fit=crop',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _galleryPages.length,
          itemBuilder: (context, index, realIndex) {
            return _GalleryCollage(images: _galleryPages[index]);
          },
          options: CarouselOptions(
            height: 28.h,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_galleryPages.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 0.8.w),
              width: isActive ? 2.5.w : 1.8.w,
              height: 1.8.w,
              decoration: BoxDecoration(
                color: isActive ? _accent : const Color(0xFFD0C8DB),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _GalleryCollage extends StatelessWidget {
  const _GalleryCollage({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(child: _GalleryImage(url: images[0])),
                SizedBox(height: 0.6.w),
                Expanded(child: _GalleryImage(url: images[3])),
              ],
            ),
          ),
          SizedBox(width: 0.6.w),
          Expanded(
            flex: 3,
            child: _GalleryImage(url: images[1]),
          ),
          SizedBox(width: 0.6.w),
          Expanded(
            flex: 3,
            child: _GalleryImage(url: images[2]),
          ),
        ],
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
      borderRadius: BorderRadius.circular(4),
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
