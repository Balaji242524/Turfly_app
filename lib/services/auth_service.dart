import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> registerWithEmail(String email, String password, String role) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'role': role,
    });
  }

  Future<String?> loginWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final doc = await _db.collection('users').doc(cred.user!.uid).get();

    if (doc.exists) {
      return doc.data()?['role'];
    } else {
      // Optionally: create the doc or return null
      return null;
    }
  }

  Future<String?> signInWithGoogle(String roleOnFirstSignIn) async {
    final google = GoogleSignIn(
      clientId: "YOUR-WEB-CLIENT-ID.apps.googleusercontent.com", // ← Replace
    );

    final user = await google.signIn();
    if (user == null) return null;

    final auth = await user.authentication;
    final cred = await _auth.signInWithCredential(GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    ));

    final docRef = _db.collection('users').doc(cred.user!.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'email': cred.user!.email,
        'role': roleOnFirstSignIn,
      });
      return roleOnFirstSignIn;
    }
    return snapshot.data()?['role'];
  }
}
