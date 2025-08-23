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
    // Initialize AuthService here. It was commented out in your original code,
    // which would cause an error. Declaring it as 'late' and initializing it
    // allows it to be used within the build method if needed, or better yet,
    // inject it if you're using a state management solution.
    // For this example, we'll initialize it directly.
    late final AuthService auth = AuthService();


    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3), // Light background color
      body: SafeArea(
        child: Stack(
          children: [
            // Back button, if shown
            if (showBackButton)
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: onNavigateBack,
                ),
              ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo and Name
                    Image.asset('assets/images/turf_logof.png', height: 100),
                    const SizedBox(height: 10),
                    Image.asset('assets/images/TURFLY.png', height: 30),
                    const SizedBox(height: 20),

                    // Title of the form (Login/Register)
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00ED0C), // A vibrant green
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Input Field
                    TextField(
                      controller: emailCtl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.green),
                        hintText: 'Enter your Email...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none, // No border for a cleaner look
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password Input Field
                    TextField(
                      controller: passCtl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                        hintText: 'Enter your Password...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Action Button (Login/Register)
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          String? r;
                          if (isLogin) {
                            // Attempt to login using AuthService
                            r = await auth.loginWithEmail(emailCtl.text.trim(), passCtl.text.trim());
                          } else {
                            // Attempt to register using AuthService
                            await auth.registerWithEmail(emailCtl.text.trim(), passCtl.text.trim(), role.name);
                            onSwitch(); // Switch to login screen after successful registration
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration successful! Please log in.')),
                            );
                            return; // Exit after successful registration and switch
                          }
                          // If login is successful, call onSuccess callback
                          if (r != null) {
                            onSuccess(r);
                          } else {
                            // Handle login failure if auth.loginWithEmail returns null
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed. Please check your credentials.')),
                            );
                          }
                        } catch (e) {
                          // Show error message for any authentication failure
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Authentication failed: ${e.toString()}')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ED0C), // Button background color
                        minimumSize: const Size.fromHeight(50), // Full width button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.green.shade200,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Removed Google Sign-In section as requested
                    // const SizedBox(height: 10), // This space is no longer needed after removing Google button
                    // InkWell(
                    //   onTap: () async {
                    //     try {
                    //       final r = await auth.signInWithGoogle(role.name);
                    //       if (r != null) onSuccess(r);
                    //     } catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
                    //     }
                    //   },
                    //   child: Image.asset('assets/images/google_icon.png', height: 40),
                    // ),
                    // const SizedBox(height: 14), // This space is no longer needed

                    const SizedBox(height: 14), // Adjust spacing after button

                    // Footer text with action (e.g., "Don't have an account? Register")
                    GestureDetector(
                      onTap: onSwitch, // Switches between login/register
                      child: Text.rich(
                        TextSpan(
                          text: footerText,
                          style: const TextStyle(fontSize: 15, color: Colors.black54),
                          children: [
                            TextSpan(
                              text: footerActionText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00ED0C), // Green color for the action text
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
