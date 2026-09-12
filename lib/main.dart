import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_main_screen.dart';
import 'package:maribel_wellness_centre_application/auth/splash_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:sizer/sizer.dart';

/// `true` → Admin interface · `false` → User interface
const bool isAdmin = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: isAdmin ? 'Maribel Admin' : 'Maribel Wellness Centre',
          theme: ThemeData(
            fontFamily: fontFamily,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
            useMaterial3: true,
            textTheme: baseTextTheme,
            primaryTextTheme: basePrimaryTextTheme,
          ),
          home: SplashScreen(
            homeAfterLogin:
                isAdmin ? const AdminMainScreen() : const UserMainScreen(),
          ),
        );
      },
    );
  }
}
