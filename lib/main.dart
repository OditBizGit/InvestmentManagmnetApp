import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/cubit/dashboard_cubit.dart';
import 'package:maribel_wellness_centre_application/admin/dashboard/repository/dashboard_repository.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/repository/funding_payments_repository.dart';
import 'package:maribel_wellness_centre_application/admin/investors/repository/investors_repository.dart';
import 'package:maribel_wellness_centre_application/admin/navigation/admin_main_screen.dart';
import 'package:maribel_wellness_centre_application/admin/work_progress/screens/add_update/update_phase/repository/update_phase_repository.dart';
import 'package:maribel_wellness_centre_application/auth/cubit/login_cubit.dart';
import 'package:maribel_wellness_centre_application/auth/repository/login_repository.dart';
import 'package:maribel_wellness_centre_application/auth/splash_screen.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:maribel_wellness_centre_application/core/network/service_locator.dart';
import 'package:maribel_wellness_centre_application/core/notifications/notification_service.dart';
import 'package:maribel_wellness_centre_application/user/home/repository/home_repository.dart';
import 'package:maribel_wellness_centre_application/user/navigation/user_main_screen.dart';
import 'package:maribel_wellness_centre_application/user/profile/repository/profile_repository.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// `true` → Admin interface · `false` → User interface
const bool isAdmin = true;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await setupDi();
//
//   // Push notifications are user/investor only — skip on admin builds.
//   if (!isAdmin) {
//     await Firebase.initializeApp(    options: DefaultFirebaseOptions.currentPlatform,
//     );
//
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//     await getIt<NotificationService>().initialize();
//
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//   }
//
//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDi();

  // Notifications are ONLY for Android and iOS.
  // No notifications on Web or Windows.
  if (!kIsWeb &&
      !isAdmin &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await getIt<NotificationService>().initialize();

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
        RepositoryProvider<InvestorPaymentRepository>.value(
          value: getIt<InvestorPaymentRepository>(),
        ),
        RepositoryProvider<HomeRepository>.value(
          value: getIt<HomeRepository>(),
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: getIt<ProfileRepository>(),
        ),
        RepositoryProvider<AddPhaseRepository>.value(
          value: getIt<AddPhaseRepository>(),
        ),
        RepositoryProvider<DashboardRepository>.value(
          value: getIt<DashboardRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (_) => getIt<LoginCubit>(),
          ),
          BlocProvider<DashboardCubit>(
            create: (_) => getIt<DashboardCubit>(),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, screenType) {
            return ToastificationWrapper(
              child: MaterialApp(
                navigatorKey: isAdmin ? null : notificationNavigatorKey,
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
