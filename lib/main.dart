import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turfly_new/screens/turf_owner/turf_owner_personal_details.dart';
import 'package:turfly_new/screens/user/user_personal_details.dart';
import 'screens/landing_page.dart';
import 'screens/turf_register.dart';
import 'screens/user_register.dart';
import 'screens/turf_login.dart';
import 'screens/user_login.dart';
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
      theme: ThemeData(fontFamily: 'Sans-Sherif'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/turf_register': (_) => const TurfRegisterPage(),
        '/user_register': (_) => const UserRegisterPage(),
        '/turf_login': (_) => const TurfLoginPage(),
        '/user_login': (_) => const UserLoginPage(),
        '/user/user_personal_details': (context) => UserPersonalDetailsPage(),
        '/turf_owner/turf_owner_personal_details': (context) => TurfOwnerPersonalDetailsPage(),
      },
    );
  }
}
