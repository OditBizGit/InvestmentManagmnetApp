import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.userMain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => _goToHome(context),
          child: const Text('User Login'),
        ),
      ),
    );
  }
}
