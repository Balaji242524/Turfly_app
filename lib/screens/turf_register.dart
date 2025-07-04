import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';

class TurfRegisterPage extends StatelessWidget {
  const TurfRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Turf Owner Register',
      buttonText: 'Register',
      isLogin: false,
      role: AuthRole.turf,
      onSwitch: () => Navigator.pushReplacementNamed(context, '/turf_login'),
      onNavigateBack: () => Navigator.pushReplacementNamed(context, '/'),
      onSuccess: (_) => Navigator.pushReplacementNamed(context, '/turf_login'),
      footerText: 'Already have an account? ',
      footerActionText: 'Login',
      showBackButton: true,
    );
  }
}
