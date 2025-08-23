import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // No longer needed if Google Sign-In is removed

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Registers a new user with email and password and stores their role in Firestore.
  Future<void> registerWithEmail(String email, String password, String role) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(), // Add timestamp for creation
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors (e.g., email-already-in-use, weak-password)
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      // Handle other potential errors
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  /// Logs in a user with email and password and returns their role.
  /// Returns null if login fails or user document doesn't exist.
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        final doc = await _db.collection('users').doc(cred.user!.uid).get();

        if (doc.exists) {
          return doc.data()?['role'];
        } else {
          // This case might happen if a user signs in via email/password
          // but their user document wasn't created for some reason.
          // You might want to create it here or handle this as an error.
          throw Exception('User data not found in Firestore.');
        }
      }
      return null; // Should not reach here if cred.user is null, but for completeness.
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors (e.g., user-not-found, wrong-password)
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      // Handle other potential errors
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  /// Provides user-friendly error messages for FirebaseAuthException codes.
  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please enable them in Firebase Console.';
      default:
        return 'An unknown error occurred: $errorCode';
    }
  }

// The signInWithGoogle method is completely removed/commented out as requested.
// Future<String?> signInWithGoogle(String roleOnFirstSignIn) async {
//   // ... (original Google Sign-In code was here)
//   return null;
// }
}
