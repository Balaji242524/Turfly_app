import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';

class TurfLoginPage extends StatelessWidget {
  const TurfLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Turf Owner Login',
      buttonText: 'Login',
      isLogin: true,
      role: AuthRole.turf,
      onSwitch: () => Navigator.pushReplacementNamed(context, '/turf_register'),
      onNavigateBack: () => Navigator.pushReplacementNamed(context, '/'),
      onSuccess: (_) => Navigator.pushReplacementNamed(context, '/personal_details'),
      footerText: 'Don\'t have an account? ',
      footerActionText: 'Sign Up',
      showBackButton: true,
    );
  }
}
