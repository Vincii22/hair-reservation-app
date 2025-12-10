// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. SIGN-UP FUNCTION
  // Creates a new user with email and password using Firebase Authentication.
  Future<User?> signUp(String email, String password) async {
    try {
      // Use Firebase's built-in function to create the user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Return the newly created User object
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors (e.g., weak password, email already in use)
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      // You can throw a custom exception or return the error message for the UI
      return null;
    } catch (e) {
      // Handle general errors
      print('General Sign-Up Error: $e');
      return null;
    }
  }

// 2. SIGN-IN FUNCTION (UPDATED IMPLEMENTATION)
  // Authenticates the user with email and password.
  Future<User?> signIn(String email, String password) async {
    try {
      // Use Firebase's built-in function to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Return the signed-in User object
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors (e.g., user-not-found, wrong-password)
      print('Firebase Auth Error during Sign-In: ${e.code} - ${e.message}');
      // In a real application, you might use 'e.code' to display specific messages.
      return null;
    } catch (e) {
      // Handle general errors
      print('General Sign-In Error: $e');
      return null;
    }
  }

  // 3. LOG-OUT FUNCTION
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // 4. AUTH STATE STREAM (NEW - Needed for Step 6)
  Stream<User?> get userChanges => _auth.authStateChanges();
}