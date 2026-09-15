import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class TopInvestorsCarousel extends StatelessWidget {
  const TopInvestorsCarousel({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  static const Color _cardBg = Color(0xFFF0EBF6);
  static const Color _textPrimary = Color(0xFF4A3F5C);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const int _shimmerCardCount = 3;

  static const List<_InvestorData> _investors = [
    _InvestorData(
      name: 'Mary John Christopher Arakkal',
      amount: '2 Cr',
      imageUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
      rating: 5,
    ),
    _InvestorData(
      name: 'Alexander Christopher',
      amount: '25 Lack',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop',
      rating: 5,
    ),
    _InvestorData(
      name: 'Mary Mariyam John Mathew Chacko',
      amount: '2 Cr',
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
      rating: 5,
    ),
    _InvestorData(
      name: 'Sulaiman Chacko',
      amount: '1.5 Cr',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
      rating: 4,
    ),
    _InvestorData(
      name: 'Joel',
      amount: '80 Lack',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
      rating: 5,
    ),
  ];

  static CarouselOptions get _carouselOptions => CarouselOptions(
        height: 22.h,
        viewportFraction: 0.42,
        enableInfiniteScroll: false,
        padEnds: false,
        autoPlay: false,
        enlargeCenterPage: false,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Investors',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        CarouselSlider.builder(
          itemCount: isLoading ? _shimmerCardCount : _investors.length,
          itemBuilder: (context, index, realIndex) {
            if (isLoading) {
              return const _InvestorCardShimmer();
            }
            return _InvestorCard(investor: _investors[index]);
          },
          options: _carouselOptions,
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
    return _InvestorCardShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 8.w,
            backgroundColor: TopInvestorsCarousel._cardBg,
            backgroundImage: NetworkImage(investor.imageUrl),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            child: _SlidingText(
              text: investor.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            investor.amount,
            style: TextStyle(
              fontSize: 13.5.sp,
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

class _InvestorCardShimmer extends StatelessWidget {
  const _InvestorCardShimmer();

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      height: 1.35,
    );
    final amountStyle = TextStyle(
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );

    return _InvestorCardShell(
      child: Shimmer.fromColors(
        baseColor: TopInvestorsCarousel._shimmerBase,
        highlightColor: TopInvestorsCarousel._shimmerHighlight,
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 1400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 8.w,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 1.h),
            SizedBox(
              width: double.infinity,
              child: _PlaceholderLine(
                sample: 'Alexander Christopher',
                style: nameStyle,
                alignment: Alignment.center,
                widthFactor: 0.78,
              ),
            ),
            SizedBox(height: 0.2.h),
            _PlaceholderLine(
              sample: '25 Lack',
              style: amountStyle,
              alignment: Alignment.center,
              widthFactor: 0.45,
            ),
            SizedBox(height: 0.6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (_) {
                return Icon(
                  Icons.star,
                  size: 4.2.w,
                  color: Colors.white,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestorCardShell extends StatelessWidget {
  const _InvestorCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(right: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E0ED)),
      ),
      child: child,
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  const _PlaceholderLine({
    required this.sample,
    required this.style,
    this.widthFactor = 0.8,
    this.alignment = Alignment.centerLeft,
  });

  final String sample;
  final TextStyle style;
  final double widthFactor;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          sample,
          maxLines: 1,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: style.copyWith(color: Colors.transparent),
        ),
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: 0.68,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlidingText extends StatefulWidget {
  const _SlidingText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  State<_SlidingText> createState() => _SlidingTextState();
}

class _SlidingTextState extends State<_SlidingText>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  final ValueNotifier<double> _offset = ValueNotifier<double>(0);
  final GlobalKey _textKey = GlobalKey();

  double _textWidth = 0;
  double _textHeight = 0;
  double _maxWidth = 0;
  bool _needsSlide = false;
  bool _locked = false;
  bool _measureScheduled = false;
  bool _refineScheduled = false;
  Duration? _lastTick;

  static const double _gap = 40;
  static const double _pixelsPerSecond = 24;

  TextStyle get _style => widget.style.copyWith(
        height: widget.style.height ?? 1.35,
        leadingDistribution: TextLeadingDistribution.even,
      );

  @override
  void dispose() {
    _ticker?.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SlidingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _locked = false;
      _offset.value = 0;
      _lastTick = null;
      _stopTicker();
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    if (_measureScheduled || _locked) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      _measure();
    });
  }

  void _measure() {
    if (!mounted || _maxWidth <= 0 || _locked) return;

    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: _style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();

    final textWidth = painter.width;
    final textHeight = painter.height;
    final needsSlide = textWidth > _maxWidth + 1;

    setState(() {
      _textWidth = textWidth;
      _textHeight = textHeight;
      _needsSlide = needsSlide;
      _locked = true;
    });

    if (needsSlide) {
      _startTicker();
      _scheduleRefineWidth();
    } else {
      _stopTicker();
      _offset.value = 0;
    }
  }

  /// After the sliding text is built, sync travel distance to the real glyph width.
  void _scheduleRefineWidth() {
    if (_refineScheduled) return;
    _refineScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refineScheduled = false;
      if (!mounted || !_needsSlide) return;

      final box = _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize || box.size.width <= 0) return;

      final realWidth = box.size.width;
      if ((realWidth - _textWidth).abs() <= 0.5) return;

      _textWidth = realWidth;
      _textHeight = box.size.height;
    });
  }

  void _startTicker() {
    _ticker ??= createTicker(_onTick);
    if (!(_ticker?.isActive ?? false)) {
      _lastTick = null;
      _ticker!.start();
    }
  }

  void _stopTicker() {
    _ticker?.stop();
    _lastTick = null;
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;

    final dt = ((elapsed - last).inMicroseconds / 1e6).clamp(0.0, 1 / 45);
    if (dt <= 0) return;

    final travel = _textWidth + _gap;
    if (travel <= 0) return;

    var next = _offset.value + _pixelsPerSecond * dt;
    if (next >= travel) {
      next %= travel;
    }
    _offset.value = next;
  }

  Widget _nameText({Key? key}) {
    return Text(
      widget.text,
      key: key,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: _style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (!_locked && maxWidth.isFinite && maxWidth > 0) {
          _maxWidth = maxWidth;
          _scheduleMeasure();
        }

        final height =
            _textHeight > 0 ? _textHeight : (style.fontSize ?? 14) * 1.4;

        // Short names: show once, centered — never duplicate.
        if (!_needsSlide) {
          return SizedBox(
            height: height,
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          width: double.infinity,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: height,
              maxHeight: height,
              child: ValueListenableBuilder<double>(
                valueListenable: _offset,
                builder: (context, offset, child) {
                  return Transform.translate(
                    offset: Offset(-offset, 0),
                    child: child,
                  );
                },
                child: RepaintBoundary(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _nameText(key: _textKey),
                      const SizedBox(width: _gap),
                      _nameText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
