import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';

class UserRegisterPage extends StatelessWidget {
  const UserRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'User Register',
      buttonText: 'Register',
      isLogin: false,
      role: AuthRole.user,
      onSwitch: () => Navigator.pushReplacementNamed(context, '/user_login'),
      onNavigateBack: () => Navigator.pushReplacementNamed(context, '/'),
      onSuccess: (_) => Navigator.pushReplacementNamed(context, '/user_login'),
      footerText: 'Already have an account? ',
      footerActionText: 'Login',
      showBackButton: true,
    );
  }
}
