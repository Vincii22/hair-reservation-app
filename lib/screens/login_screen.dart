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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.content_cut, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 50),
                Text(
                  'Welcome back to StyleCut!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                // Reusable text fields
                MyTextField(
                  controller: usernameController,
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
                const SizedBox(height: 25),
                // Reusable Button
                MyButton(
                  text: "Sign In",
                  onTap: () {
                    // Home nav logic here
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
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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