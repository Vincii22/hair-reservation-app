import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';
import 'package:salonapp/components/custom_app_bar.dart';

// Note: This screen requires Admin privileges to function (handled by the Firestore rules).
class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  // Controllers for form input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // --- 1. Firestore Profile Creation Function (sets role to 'employee') ---
  Future<void> _createEmployeeProfile(String uid, String email, String name) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'role': 'employee', // <<< CRITICAL: Set Role to 'employee'
      'creation_date': Timestamp.now(),
      'appointments_assigned': 0,
      'is_active': true,
    });
  }

  // --- 2. Main Employee Creation Logic ---
  Future<void> _createEmployee() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Basic Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
        _successMessage = '';
      });
      return;
    }
    if (password.length < 6) {
       setState(() {
        _errorMessage = 'Password must be at least 6 characters.';
        _successMessage = '';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // 3. Create the user account using Firebase Auth
      // NOTE: We do NOT use the AuthService here, as the Admin is creating accounts for others.
      // We use the raw FirebaseAuth instance directly.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 4. Create the Firestore profile with 'employee' role
        await _createEmployeeProfile(user.uid, email, name);
        
        // 5. Update Auth profile (optional but good practice)
        await user.updateDisplayName(name);

        setState(() {
          _successMessage = 'Employee "${name}" created successfully!';
          // Clear form fields after success
          nameController.clear();
          emailController.clear();
          passwordController.clear();
        });
      }

    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use.';
      } else {
        message = 'Firebase Error: ${e.message}';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
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
      appBar: const CustomAppBar(title: 'Create Employee', hasBackButton: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const Text(
                  'Assign a new account for your staff.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Form Fields
                MyTextField(
                  controller: nameController,
                  hintText: 'Employee Full Name',
                  obscureText: false,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: emailController,
                  hintText: 'Employee Email',
                  obscureText: false,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Temporary Password (min 6 chars)',
                  obscureText: true,
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 30),
                
                // Success/Error Message Display
                if (_successMessage.isNotEmpty)
                  Text(
                    _successMessage,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 15),

                // Button/Loading Indicator
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                    : MyButton(
                        text: "Create Employee Account",
                        onTap: _createEmployee,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}