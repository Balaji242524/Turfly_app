import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/landing_page.dart';
import 'screens/turf_register.dart';
import 'screens/user_register.dart';
import 'screens/turf_login.dart';
import 'screens/user_login.dart';
import 'screens/personal_details.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turfly',
      theme: ThemeData(fontFamily: 'Arial'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/turf_register': (_) => const TurfRegisterPage(),
        '/user_register': (_) => const UserRegisterPage(),
        '/turf_login': (_) => const TurfLoginPage(),
        '/user_login': (_) => const UserLoginPage(),
        '/personal_details': (_) => const PersonalDetailsPage(),
      },
    );
  }
}
