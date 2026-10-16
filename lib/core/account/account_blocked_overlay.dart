import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/core/account/account_block_routes.dart';
import 'package:maribel_wellness_centre_application/core/account/auth_navigation_guard.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/constants/image_constants.dart';
import 'package:maribel_wellness_centre_application/core/notifications/notification_service.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:sizer/sizer.dart';

/// Full-screen, non-dismissible overlay shown when an investor account is blocked.
class AccountBlockedOverlay extends StatefulWidget {
  const AccountBlockedOverlay({super.key});

  @override
  State<AccountBlockedOverlay> createState() => _AccountBlockedOverlayState();
}

class _AccountBlockedOverlayState extends State<AccountBlockedOverlay> {
  bool _isLoggingOut = false;

  Future<void> _onLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    // Cover the shell until login is the only route. Resetting auth state
    // would otherwise uncover the home page before navigation runs.
    AuthNavigationGuard.holdBlockedOverlay.value = true;
    final loginCubit = context.read<LoginCubit>();

    try {
      // SharedPreferences first, then authentication state.
      await loginCubit.logout();

      final navigator = notificationNavigatorKey.currentState;
      if (navigator == null) {
        AuthNavigationGuard.holdBlockedOverlay.value = false;
        if (mounted) setState(() => _isLoggingOut = false);
        return;
      }

      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AccountBlockRoutes.login),
          builder: (_) => const LoginScreen(
            home: UserMainScreen(),
            snackBarMessage: 'Your account has been blocked',
          ),
        ),
        (route) => false,
      );

      final reachedLogin = accountBlockNavigatorObserver.onAuthRoute.value;
      AuthNavigationGuard.holdBlockedOverlay.value = !reachedLogin;
      if (!reachedLogin && mounted) {
        setState(() => _isLoggingOut = false);
      }
    } catch (_) {
      AuthNavigationGuard.holdBlockedOverlay.value = false;
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.disabled.withValues(alpha: 0.94),
                    AppColors.disabled.withValues(alpha: 0.86),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -size.height * 0.08,
              right: -size.width * 0.28,
              child: _DecorCircle(
                size: size.width * 0.7,
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.06,
              left: -size.width * 0.3,
              child: _DecorCircle(
                size: size.width * 0.55,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 3.h),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.22),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          ImageConstants.disableUser,
                          width: 10.w,
                          height: 10.w,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.8.h),
                    Text(
                      'Account Blocked',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 1.4.h),
                    Text(
                      'Your account has been blocked by the administrator.\n'
                      'Please contact support for assistance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: AppColors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      height: 5.5.h,
                      child: FilledButton(
                        onPressed: _isLoggingOut ? null : _onLogout,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.disabled,
                          disabledBackgroundColor:
                              AppColors.white.withValues(alpha: 0.7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoggingOut
                            ? SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.accentDark,
                                ),
                              )
                            : Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: AppColors.disabled,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
