
import 'package:flutter/material.dart';

class InteractiveStarRating extends StatelessWidget {
  const InteractiveStarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 18,
    this.enabled = true,
  });

  final double? rating;
  final ValueChanged<double> onRatingChanged;
  final double starSize;
  final bool enabled;

  static const Color _filled = Color(0xFFFFC107);
  static const Color _empty = Color(0xFFD0D0D0);

  @override
  Widget build(BuildContext context) {
    final selected = (rating ?? 0.0).clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;

        final double fill;
        if (selected >= starValue) {
          fill = 1.0;
        } else if (selected >= starValue - 0.5) {
          fill = 0.5;
        } else {
          fill = 0.0;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () => onRatingChanged(starValue)
                : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: SizedBox(
                width: starSize,
                height: starSize,
                child: Stack(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: starSize,
                      color: _empty,
                    ),
                    if (fill > 0)
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: fill,
                          child: Icon(
                            Icons.star_rounded,
                            size: starSize,
                            color: _filled,
                          ),
                        ),
                      ),
                    if (enabled)
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    onRatingChanged(index + 0.5),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    onRatingChanged(index + 1.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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

  final double rating;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return InteractiveStarRating(
      rating: rating.clamp(0.0, 5.0),
      onRatingChanged: (_) {},
      starSize: starSize,
      enabled: false,
    );
  }
}
