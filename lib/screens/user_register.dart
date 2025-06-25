import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';

class UserRegisterPage extends StatelessWidget {
  const UserRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'User Register',
      buttonText: 'Register',
      onSubmit: () {},
      footerText: 'Already have account? ',
      footerActionText: 'Signin',
      onFooterTap: () => Navigator.pushNamed(context, '/user_login'),
      showBackButton: true,
    );
  }
}
