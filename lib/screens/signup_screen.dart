import 'package:flutter/material.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';
import 'package:salonapp/components/custom_app_bar.dart';

class SignupScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Create Account', hasBackButton: true), // Use Custom AppBar
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                const SizedBox(height: 15),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 35),
                MyButton(
                  text: "Sign Up",
                  onTap: () {
                    // Logic later
                  },
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