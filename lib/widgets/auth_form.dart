import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthRole { user, turf }

class AuthForm extends StatelessWidget {
  final String title, buttonText, footerText, footerActionText;
  final bool isLogin, showBackButton;
  final AuthRole role;
  final VoidCallback onSwitch, onNavigateBack;
  final Function(String role) onSuccess;

  const AuthForm({
    super.key,
    required this.title,
    required this.buttonText,
    required this.footerText,
    required this.footerActionText,
    required this.isLogin,
    required this.role,
    required this.onSwitch,
    required this.onNavigateBack,
    required this.onSuccess,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final emailCtl = TextEditingController();
    final passCtl = TextEditingController();
    final auth = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Stack(children: [
          if (showBackButton)
            Positioned(top: 4, left: 4, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onNavigateBack)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Image.asset('assets/images/turf_logof.png', height: 100),
                const SizedBox(height: 10),
                Image.asset('assets/images/TURFLY.png', height: 30),
                const SizedBox(height: 20),
                Text(title, style: const TextStyle(fontSize: 22, color: Color(0xFF00ED0C))),
                const SizedBox(height: 30),
                TextField(controller: emailCtl, decoration: const InputDecoration(prefixIcon: Icon(Icons.email, color: Colors.green), hintText: 'Enter your Email...', filled: true, fillColor: Colors.white)),
                const SizedBox(height: 16),
                TextField(controller: passCtl, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock, color: Colors.green), hintText: 'Enter your Password...', filled: true, fillColor: Colors.white)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String? r;
                      if (isLogin) {
                        r = await auth.loginWithEmail(emailCtl.text.trim(), passCtl.text.trim());
                      } else {
                        await auth.registerWithEmail(emailCtl.text.trim(), passCtl.text.trim(), role.name);
                        onSwitch(); return;
                      }
                      if (r != null) onSuccess(r);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth failed: $e')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00ED0C), minimumSize: const Size.fromHeight(50)),
                  child: Text(buttonText),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    try {
                      final r = await auth.signInWithGoogle(role.name);
                      if (r != null) onSuccess(r);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
                    }
                  },
                  child: Image.asset('assets/images/google_icon.png', height: 40),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onSwitch,
                  child: Text.rich(TextSpan(text: footerText, children: [
                    TextSpan(text: footerActionText, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00ED0C))),
                  ])),
                ),
              ]),
            ),
          )
        ]),
      ),
    );
  }
}
