import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onSubmit;
  final String footerText;
  final String footerActionText;
  final VoidCallback onFooterTap;
  final bool showBackButton;

  const AuthForm({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.onSubmit,
    required this.footerText,
    required this.footerActionText,
    required this.onFooterTap,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Stack(
          children: [
            if (showBackButton)
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pushNamed(context, '/'),
                ),
              ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/turf_logo.png', height: 90),
                    const SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00ED0C), Color(0xFF00ED0C)],
                      ).createShader(bounds),
                      child: const Text(
                        'Turfly',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              color: Colors.greenAccent,
                              offset: Offset(0, 0),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00ED0C),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.green),
                        hintText: 'Enter your Email...',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                        hintText: 'Enter your Password...',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xFF00ED0C),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onSubmit,
                      child: Text(buttonText),
                    ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                    },
                    child: Image.asset(
                      'assets/images/google_icon.png',
                      height: 40,
                    ),
                  ),

                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onFooterTap,
                      child: Text.rich(
                        TextSpan(
                          text: footerText,
                          children: [
                            TextSpan(
                              text: footerActionText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00ED0C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
