import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _textAnimDuration = Duration(milliseconds: 1400);
  static const Duration _delayBeforeNavigate = Duration(seconds: 1);

  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textScale;

  bool _gifFinished = false;
  bool _textFinished = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: _textAnimDuration,
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textScale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutBack),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _textController.forward();
      if (!mounted) return;
      _textFinished = true;
      _tryNavigate();
    });
  }

  void _onGifFinished() {
    _gifFinished = true;
    _tryNavigate();
  }

  Future<void> _tryNavigate() async {
    if (_navigating || !_gifFinished || !_textFinished || !mounted) return;
    _navigating = true;

    await Future<void>.delayed(_delayBeforeNavigate);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: GifView.asset(
                ImageConstants.splashGif,
                width: 55.w,
                fit: BoxFit.contain,
                loop: false,
                onFinish: _onGifFinished,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 4.h,
              child: FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: ScaleTransition(
                    scale: _textScale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Maribel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 0.8,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          'Wellness Centre',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
