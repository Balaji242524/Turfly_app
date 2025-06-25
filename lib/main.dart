import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/turf_register.dart';
import 'screens/user_register.dart';
import 'screens/turf_login.dart';
import 'screens/user_login.dart';

void main() {
  runApp(const TurflyApp());
}

class TurflyApp extends StatelessWidget {
  const TurflyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turfly',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/turf_register': (_) => const TurfRegisterPage(),
        '/user_register': (_) => const UserRegisterPage(),
        '/turf_login': (_) => const TurfLoginPage(),
        '/user_login': (_) => const UserLoginPage(),
      },
    );
  }
}
