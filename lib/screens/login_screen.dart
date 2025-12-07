import 'package:flutter/material.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/components/my_textfield.dart';
import 'package:salonapp/screens/signup_screen.dart';
import 'package:salonapp/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cleaner background
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
                  controller: usernameController,
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
                const SizedBox(height: 35),
                MyButton(
                  text: "Sign In",
                  onTap: () {
                    // Placeholder: Navigate to Home
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
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