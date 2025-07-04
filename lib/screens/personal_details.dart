import 'package:flutter/material.dart';

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final ageController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: SafeArea(
        child: Column(
          children: [
            // Green top bar with logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Color(0xFF00ED0C)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/turf_logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'TURFLY',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(0, 0),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Complete your profile by\nproviding your personal and\ncontact information.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _CustomInputField(
                    icon: Icons.person_outline,
                    hintText: 'Enter your Name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    icon: Icons.phone_android,
                    hintText: 'Enter your Mobile Number',
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    icon: Icons.numbers_outlined,
                    hintText: 'Enter your Age',
                    controller: ageController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ED0C),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Save logic
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom reusable input field widget
class _CustomInputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _CustomInputField({
    required this.icon,
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF00ED0C)),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
