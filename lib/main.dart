import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_main_screen.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/auth/repository/login_repository.dart';
import 'package:maribel_wellness_centre_application/auth/splash_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

/// `true` → Admin interface · `false` → User interface
const bool isAdmin = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  if (!isAdmin) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String fontFamily = 'Montserrat';

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: fontFamily,
    );
    final basePrimaryTextTheme = ThemeData.light().primaryTextTheme.apply(
      fontFamily: fontFamily,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: getIt<AuthRepository>(),
        ),
        RepositoryProvider<InvestorsRepository>.value(
          value: getIt<InvestorsRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (_) => getIt<LoginCubit>(),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, screenType) {
            return ToastificationWrapper(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: isAdmin ? 'Maribel Admin' : 'Maribel Wellness Centre',
                theme: ThemeData(
                  fontFamily: fontFamily,
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: AppColors.accent),
                  useMaterial3: true,
                  textTheme: baseTextTheme,
                  primaryTextTheme: basePrimaryTextTheme,
                ),
                home: SplashScreen(
                  homeAfterLogin: isAdmin
                      ? const AdminMainScreen()
                      : const UserMainScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
