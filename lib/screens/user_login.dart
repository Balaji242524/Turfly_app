import 'package:flutter/material.dart';
import 'package:turfly/widgets/auth_form.dart';

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'User Login',
      buttonText: 'Login',
      onSubmit: () {},
      footerText: 'Already have account? ',
      footerActionText: 'SignUp',
      onFooterTap: () => Navigator.pushNamed(context, '/user_register'),
    );
  }
}
