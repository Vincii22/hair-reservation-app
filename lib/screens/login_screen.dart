// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';
import 'package:salonapp/services/auth_service.dart'; // Import the service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
    });

    try {
      // Call the Firebase Auth service
      final user = await _authService.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // Success: Navigate to the home screen
        // This navigation will be properly handled by the Auth Stream in Step 6.
        // For now, we use pushReplacementNamed to fulfill the UI flow.
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Failure: Show error message
        setState(() {
          // General message for security purposes
          _errorMessage = 'Invalid email or password.'; 
        });
      }
    } catch (e) {
      // General error handling
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.content_cut, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  'Welcome back to StyleCut!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 20),
                
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
                        text: "Sign In",
                        onTap: _signIn, // Linked to the Firebase sign-in function
                      ),
                const SizedBox(height: 50),
                
                GestureDetector(
                  onTap: () {
                     Navigator.pushNamed(context, '/signup');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not a member?', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 4),
                      const Text(
                        'Register now',
                        style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}