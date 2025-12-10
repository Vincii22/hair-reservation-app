import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED to update display name
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/services/auth_service.dart';

// CONVERTED to StatefulWidget to manage loading state and errors
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController(); // 💡 NEW: Username Controller

  // Services and State Management
  final AuthService _authService = AuthService();
  // Initialize Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  bool _isLoading = false;
  String _errorMessage = '';

  // --- ADJUSTED: Firestore Profile Creation Function with Name and Role ---
  Future<void> _createUserProfile(User user, String name) async {
    // We use the user's UID as the document ID for easy lookup.
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': name, // 💡 SAVING THE USERNAME
      'role': 'customer', // <<< CRITICAL: Default Role Assignment
      'creation_date': Timestamp.now(),
      'appointments_count': 0,
      // 'profile_picture_url': null, // Optional: Placeholder for later
    });

    // 💡 OPTIONAL: Update the display name in Firebase Auth
    await user.updateDisplayName(name);
  }
  // --------------------------------------------------------

  Future<void> _signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim(); // Get username

    // 1. Basic Validation
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }
    if (username.isEmpty) { // 💡 NEW: Check if username is provided
       setState(() {
        _errorMessage = 'Please enter your name.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
    });

    try {
      // 2. Call Firebase Auth Service
      final user = await _authService.signUp(email, password);

      if (user != null) {
        // 3. SUCCESS: Execute Step 4 - Create the Firestore profile
        await _createUserProfile(user, username); // 💡 Pass User and Username

        // 4. Navigation is handled by Auth Stream in main.dart (we will remove this soon)
        // For now, keep the navigation:
        Navigator.pushReplacementNamed(context, '/home'); 
      } else {
        // Handle case where signUp returns null (error already logged in AuthService)
        setState(() {
          _errorMessage = 'Sign up failed. Email might be in use or password too weak.';
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors (more user-friendly)
       setState(() {
        _errorMessage = e.message ?? 'An unknown authentication error occurred.';
      });
    } catch (e) {
      setState(() {
        // Fallback for Firestore errors, etc.
        _errorMessage = 'An unexpected error occurred during sign up.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Create Account', hasBackButton: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // 💡 NEW: Username Field
                MyTextField(
                  controller: usernameController,
                  hintText: 'Your Name (e.g., Jane Doe)',
                  obscureText: false,
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  icon: Icons.email,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 20),
                
                // Display Error Message
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 15),

                // Button/Loading Indicator
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                    : MyButton(
                        text: "Sign Up",
                        onTap: _signUp, // Link button to the sign-up function
                      ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}