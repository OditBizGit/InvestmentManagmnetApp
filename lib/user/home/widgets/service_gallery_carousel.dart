import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/user/home/model/banner_item_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class ServiceGalleryCarousel extends StatefulWidget {
  const ServiceGalleryCarousel({
    super.key,
    this.isLoading = false,
    this.banners = const [],
  });

  final bool isLoading;
  final List<BannerItemModel> banners;

  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  /// URLs that have finished loading at least once this session.
  static final Set<String> _warmUrls = <String>{};

  @override
  State<ServiceGalleryCarousel> createState() =>
      _ServiceGalleryCarouselState();
}

class _ServiceGalleryCarouselState extends State<ServiceGalleryCarousel> {
  int _currentIndex = 0;
  List<String> _imageUrls = const [];
  int? _cacheWidth;

  @override
  void initState() {
    super.initState();
    _imageUrls = _resolveUrls(widget.banners);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCacheSize();
    _precache(_imageUrls);
  }

  @override
  void didUpdateWidget(covariant ServiceGalleryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextUrls = _resolveUrls(widget.banners);
    if (!_listEquals(_imageUrls, nextUrls)) {
      _imageUrls = nextUrls;
      _precache(_imageUrls);
    }
    final count = _imageUrls.length;
    if (count == 0) {
      _currentIndex = 0;
    } else if (_currentIndex >= count) {
      _currentIndex = count - 1;
    }
  }

  void _updateCacheSize() {
    final mq = MediaQuery.of(context);
    // Width-only resize keeps each image's natural aspect ratio.
    _cacheWidth = (mq.size.width * mq.devicePixelRatio).round();
  }

  List<String> _resolveUrls(List<BannerItemModel> banners) {
    return banners
        .map((banner) => banner.bannerImageUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  ImageProvider _providerFor(String url) {
    return ResizeImage.resizeIfNeeded(
      _cacheWidth,
      null,
      CachedNetworkImageProvider(url),
    );
  }

  void _precache(List<String> urls) {
    for (final url in urls) {
      precacheImage(_providerFor(url), context).then((_) {
        if (!mounted) return;
        ServiceGalleryCarousel._warmUrls.add(url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const _GalleryShimmer();
    }

    final images = _imageUrls;
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 25.h,
      width: double.infinity,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: images.length,
            itemBuilder: (context, index, realIndex) {
              final url = images[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                child: _GalleryImage(
                  key: ValueKey(url),
                  url: url,
                  imageProvider: _providerFor(url),
                ),
              );
            },
            options: CarouselOptions(
              height: 25.h,
              viewportFraction: 1,
              enableInfiniteScroll: images.length > 1,
              autoPlay: images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 1.5.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
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
  const _GalleryImage({
    super.key,
    required this.url,
    required this.imageProvider,
  });

  static const Color _accent = Color(0xFFA28CC1);
  static const Color _cardBg = Color(0xFFF0EBF6);

  final String url;
  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    final isWarm = ServiceGalleryCarousel._warmUrls.contains(url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image(
        image: imageProvider,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            ServiceGalleryCarousel._warmUrls.add(url);
            return child;
          }

          // Already shown once — hold the slot without a spinner while
          // a resized frame is resolved from cache.
          if (isWarm) {
            return const ColoredBox(color: _cardBg);
          }

          return const ColoredBox(
            color: _cardBg,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _accent,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: _cardBg,
          child: Icon(
            Icons.local_hospital_outlined,
            color: _accent,
            size: 8.w,
          ),
        ),
      ),
    );
  }
}
