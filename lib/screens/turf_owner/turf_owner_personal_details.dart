import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TurfOwnerPersonalDetailsPage extends StatefulWidget {
  @override
  _TurfOwnerPersonalDetailsPageState createState() =>
      _TurfOwnerPersonalDetailsPageState();
}

class _TurfOwnerPersonalDetailsPageState
    extends State<TurfOwnerPersonalDetailsPage> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;

    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('turfOwners').doc(uid).set({
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'age': _ageController.text.trim(),
          'email': email,
          'role': 'turf_owner',
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  Widget buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon, color: Color(0xFF00ED0C)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Header
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00ED0C), Color(0xFF008B05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/turf_logof.png',
                          height: 55,
                          width: 55,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'TURFLY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Sansista One', // Make sure font is set up
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // ✅ Subtitle
                  Text(
                    'Complete your profile by providing your personal and contact information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),

                  SizedBox(height: 20),

                  // ✅ Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildInputField(
                          icon: Icons.person_outline,
                          hint: 'Enter your Name',
                          controller: _nameController,
                          validator: (val) =>
                          val == null || val.isEmpty ? 'Name required' : null,
                        ),
                        buildInputField(
                          icon: Icons.phone_android,
                          hint: 'Enter your Mobile Number',
                          controller: _mobileController,
                          type: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Mobile required';
                            if (val.length != 10) return 'Enter 10 digit mobile';
                            return null;
                          },
                        ),
                        buildInputField(
                          icon: Icons.calendar_today_outlined,
                          hint: 'Enter your Age',
                          controller: _ageController,
                          type: TextInputType.number,
                          validator: (val) =>
                          val == null || val.isEmpty ? 'Age required' : null,
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Bottom-right Save Button
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: saveDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00ED0C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text('Save', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
