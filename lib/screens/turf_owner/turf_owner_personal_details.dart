import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'turf_home_page.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final email = user?.email;

    if (uid != null && email != null) {
      try {

        await FirebaseFirestore.instance.collection('turfOwners').doc(uid).set({
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'age': _ageController.text.trim(),
          'email': email,
          'role': 'turf_owner',
        }, SetOptions(merge: true));


        await FirebaseFirestore.instance.collection('turfs').doc(uid).set({
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'email': email,
          'createdAt': Timestamp.now(),
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TurfHomePage()),
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
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: type,
          validator: validator,
          decoration: InputDecoration(
            icon: Icon(icon, color: Color(0xFF00ED0C), size: 24),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/turf_logof.png', height: 70, width: 70),
                        SizedBox(width: 6),
                        Image.asset(
                          'assets/images/TURFLY.png',
                          height: 30,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Complete your profile by providing your\npersonal and contact information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                  SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildInputField(
                            icon: Icons.person_outline,
                            hint: 'Enter your Name',
                            controller: _nameController,
                            validator: (val) => val == null || val.isEmpty ? 'Name required' : null,
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
                            validator: (val) => val == null || val.isEmpty ? 'Age required' : null,
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ED0C),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
