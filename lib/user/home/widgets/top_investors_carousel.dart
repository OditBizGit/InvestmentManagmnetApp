import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/user/home/model/top_investor_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class TopInvestorsCarousel extends StatelessWidget {
  const TopInvestorsCarousel({
    super.key,
    this.isLoading = false,
    this.investors = const [],
  });

  final bool isLoading;
  final List<TopInvestorModel> investors;

  static const Color _cardBg = Color(0xFFF0EBF6);
  static const Color _accent = Color(0xFFA28CC1);
  static const Color _textPrimary = Color(0xFF4A3F5C);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);
  static const int _shimmerCardCount = 3;

  static CarouselOptions get _carouselOptions => CarouselOptions(
        height: 22.h,
        viewportFraction: 0.42,
        enableInfiniteScroll: false,
        padEnds: false,
        autoPlay: false,
        enlargeCenterPage: false,
      );

  static String formatAmount(double amount) {
    if (amount >= 10000000) {
      final crore = amount / 10000000;
      return '${_trimDecimal(crore)} Cr';
    }
    if (amount >= 100000) {
      final lakh = amount / 100000;
      return '${_trimDecimal(lakh)} Lakh';
    }
    final isWhole = amount == amount.roundToDouble();
    final raw = isWhole
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final withCommas = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    if (parts.length > 1) {
      return '₹$withCommas.${parts[1]}';
    }
    return '₹$withCommas';
  }

  static String _trimDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    final text = value.toStringAsFixed(1);
    if (text.endsWith('.0')) {
      return text.substring(0, text.length - 2);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = isLoading
        ? _shimmerCardCount
        : (investors.isEmpty ? 0 : investors.length);
    final topAmount = _topInvestmentAmount(investors);

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
        if (!isLoading && investors.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              'No top investors found',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: _textPrimary.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          CarouselSlider.builder(
            itemCount: itemCount,
            itemBuilder: (context, index, realIndex) {
              if (isLoading) {
                return const _InvestorCardShimmer();
              }
              final investor = investors[index];
              return _InvestorCard(
                investor: investor,
                showTopBadge: topAmount != null &&
                    investor.investmentAmount == topAmount,
              );
            },
            options: _carouselOptions,
          ),
      ],
    );
  }

  static double? _topInvestmentAmount(List<TopInvestorModel> investors) {
    if (investors.isEmpty) return null;

    var topAmount = investors.first.investmentAmount;
    for (final investor in investors.skip(1)) {
      if (investor.investmentAmount > topAmount) {
        topAmount = investor.investmentAmount;
      }
    }
    return topAmount;
  }
}

class _InvestorCard extends StatelessWidget {
  const _InvestorCard({
    required this.investor,
    this.showTopBadge = false,
  });

  final TopInvestorModel investor;
  final bool showTopBadge;

  static String _toTitleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    return trimmed.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = investor.profileImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _InvestorCardShell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 8.w,
                backgroundColor: TopInvestorsCarousel._cardBg,
                backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                child: hasImage
                    ? null
                    : Icon(
                        Icons.person_rounded,
                        size: 8.w,
                        color: TopInvestorsCarousel._accent,
                      ),
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: _SlidingText(
                  text: _toTitleCase(
                    investor.fullName.isNotEmpty
                        ? investor.fullName
                        : 'Investor',
                  ),
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
                TopInvestorsCarousel.formatAmount(investor.investmentAmount),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 0.6.h),
              _StarRating(
                rating: investor.rating,
                size: 4.2.w,
              ),
            ],
          ),
        ),
        if (showTopBadge)
          Positioned(
            top: 0.6.h,
            right: 2.8.w,
            child: SvgPicture.asset(
              ImageConstants.topBadge,
              width: 6.w,
              height: 6.w,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.rating,
    required this.size,
  });

  final double rating;
  final double size;

  static const Color _filled = Color(0xFFFFC107);
  static const Color _empty = Color(0xFFD0D0D0);

  @override
  Widget build(BuildContext context) {
    final clamped = rating.clamp(0.0, 5.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = clamped - index;
        final IconData icon;
        final Color color;

        if (starValue >= 1) {
          icon = Icons.star;
          color = _filled;
        } else if (starValue >= 0.5) {
          icon = Icons.star_half;
          color = _filled;
        } else {
          icon = Icons.star;
          color = _empty;
        }

        return Icon(icon, size: size, color: color);
      }),
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
              sample: '25 Lakh',
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
