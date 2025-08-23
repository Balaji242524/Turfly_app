import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import "package:turfly_new/screens/user/user_check_page.dart";

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'User Login',
      buttonText: 'Login',
      isLogin: true,
      role: AuthRole.user,
      onSwitch: () => Navigator.pushReplacementNamed(context, '/user_register'),
      onNavigateBack: () => Navigator.pushReplacementNamed(context, '/'),
      onSuccess: (_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserCheckPage()),
        );
      },
      footerText: 'Don\'t have an account? ',
      footerActionText: 'Sign Up',
      showBackButton: true,
    );
  }
}
