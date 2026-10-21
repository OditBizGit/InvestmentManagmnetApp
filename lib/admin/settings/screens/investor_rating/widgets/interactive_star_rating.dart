import 'package:flutter/material.dart';
class InteractiveStarRating extends StatelessWidget {
  const InteractiveStarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 18,
    this.enabled = true,
  });

  final int? rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final bool enabled;

  static const Color _filled = Color(0xFFFFC107);
  static const Color _empty = Color(0xFFD0D0D0);

  @override
  Widget build(BuildContext context) {
    final selected = rating ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final filled = starIndex <= selected;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => onRatingChanged(starIndex) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: starSize,
                color: filled ? _filled : _empty,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ReadOnlyStarRating extends StatelessWidget {
  const ReadOnlyStarRating({
    super.key,
    required this.rating,
    this.starSize = 16,
  });

  final int rating;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return InteractiveStarRating(
      rating: rating.clamp(1, 5),
      onRatingChanged: (_) {},
      starSize: starSize,
      enabled: false,
    );
  }
}
