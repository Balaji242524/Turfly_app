import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';

class TurfRegisterPage extends StatelessWidget {
  const TurfRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Turf Register',
      buttonText: 'Register',
      onSubmit: () {},
      footerText: 'Already have account? ',
      footerActionText: 'Signin',
      onFooterTap: () => Navigator.pushNamed(context, '/turf_login'),
      showBackButton: true,
    );
  }
}
