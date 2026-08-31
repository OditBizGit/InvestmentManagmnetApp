import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maribel_wellness_centre_application/auth/login_screen.dart';
import 'package:maribel_wellness_centre_application/auth/splash_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_routes.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Maribel Wellness Centre',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFA28CC1),
            ),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.userMain: (_) => const UserMainScreen(),
          },
        );
      },
    );
  }
}
