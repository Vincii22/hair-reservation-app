import 'package:flutter/material.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';

class SignupScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0), // Simple Back button
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  icon: Icons.email,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Sign Up",
                  onTap: () {
                    // Logic later
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}