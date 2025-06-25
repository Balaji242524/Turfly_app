import 'package:flutter/material.dart';
import 'package:turfly/widgets/auth_form.dart';

class TurfLoginPage extends StatelessWidget {
  const TurfLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Turf Login',
      buttonText: 'Login',
      onSubmit: () {},
      footerText: 'Already have account? ',
      footerActionText: 'SignUp',
      onFooterTap: () => Navigator.pushNamed(context, '/turf_register'),
    );
  }
}
