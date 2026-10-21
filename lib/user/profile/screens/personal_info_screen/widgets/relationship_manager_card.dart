import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/utils/app_snack_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class RelationshipManagerCard extends StatelessWidget {
  const RelationshipManagerCard({
    super.key,
    required this.name,
    required this.phoneNumber,
  });

  final String name;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.disabled.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(color: AppColors.disabled.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.4.h),
            child: Row(
              children: [
                Text(
                  'Relationship Manager',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.disabled,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.disabled.withValues(alpha: 0.4),
            indent: 4.w,
            endIndent: 4.w,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.disabled,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    SvgPicture.asset(
                      ImageConstants.phone,
                      width: 4.w,
                      height: 4.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.disabled,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.disabled,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.6.h),
                _SlideToCall(phoneNumber: phoneNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideToCall extends StatefulWidget {
  const _SlideToCall({required this.phoneNumber});

  final String phoneNumber;

  @override
  State<_SlideToCall> createState() => _SlideToCallState();
}

class _SlideToCallState extends State<_SlideToCall>
    with SingleTickerProviderStateMixin {
  static const _completeAt = 0.82;

  double _progress = 0;
  bool _busy = false;
  late final AnimationController _controller;
  Animation<double> _animation = const AlwaysStoppedAnimation<double>(0);

  bool get _canCall {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 6;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        if (!mounted) return;
        setState(() => _progress = _animation.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _progress, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0);
  }

  Future<void> _placeCall() async {
    final number = widget.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final launched = await launchUrl(Uri(scheme: 'tel', path: number));
    if (!mounted || launched) return;
    AppSnackBar.show(
      context,
      message: 'Unable to open the phone app',
      icon: Icons.phone_disabled_rounded,
    );
  }

  Future<void> _onDragEnd() async {
    if (_progress < _completeAt) {
      _animateTo(0);
      return;
    }

    setState(() {
      _progress = 1;
      _busy = true;
    });
    HapticFeedback.mediumImpact();
    await _placeCall();
    if (!mounted) return;
    setState(() => _busy = false);
    _animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final thumb = 11.w;
    final label = !_canCall
        ? 'Call unavailable'
        : _busy
            ? 'Calling...'
            : 'Slide to call';

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTravel = (constraints.maxWidth - thumb - 1.2.w)
            .clamp(0.0, double.infinity);
        final travel = maxTravel * _progress.clamp(0.0, 1.0);

        return GestureDetector(
          onHorizontalDragStart: !_canCall || _busy
              ? null
              : (_) => _controller.stop(),
          onHorizontalDragUpdate: !_canCall || _busy
              ? null
              : (details) {
                  setState(() {
                    _progress = ((_progress * maxTravel + details.delta.dx) /
                            maxTravel)
                        .clamp(0.0, 1.0);
                  });
                },
          onHorizontalDragEnd:
              !_canCall || _busy ? null : (_) => _onDragEnd(),
          child: Container(
            height: thumb + 1.4.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.disabled.withValues(alpha: 0.35),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                FractionallySizedBox(
                  widthFactor: (0.08 + (_progress * 0.92)).clamp(0.0, 1.0),
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.disabled.withValues(
                        alpha: _canCall ? 0.16 : 0.08,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: (1 - (_progress * 1.4)).clamp(0.0, 1.0),
                    child: Padding(
                      padding: EdgeInsets.only(left: thumb * 0.35),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.disabled.withValues(
                                alpha: _canCall ? 0.75 : 0.4,
                              ),
                            ),
                          ),
                          if (_canCall && !_busy) ...[
                            SizedBox(width: 1.5.w),
                            for (var i = 0; i < 5; i++) ...[
                              if (i > 0) SizedBox(width: 0.8.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 2.5.w,
                                color: AppColors.disabled.withValues(alpha: 0.55),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0.6.w + travel,
                  child: Container(
                    width: thumb,
                    height: thumb,
                    decoration: BoxDecoration(
                      color: _canCall
                          ? AppColors.disabled
                          : AppColors.disabled.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.phone_rounded,
                      color: AppColors.white,
                      size: 5.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
