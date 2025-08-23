import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'turf_home_page.dart';
import 'turf_owner_personal_details.dart';

class TurfOwnerCheckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _checkIfDetailsExist(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Scaffold(body: Center(child: CircularProgressIndicator()));

        if (snapshot.hasError)
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));

        final doc = snapshot.data;
        if (doc != null && doc.exists) {
          return TurfHomePage();
        } else {
          return TurfOwnerPersonalDetailsPage();
        }
      },
    );
  }

  Future<DocumentSnapshot> _checkIfDetailsExist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    final docRef = FirebaseFirestore.instance.collection('turfOwners').doc(user.uid);
    return await docRef.get();
  }
}
