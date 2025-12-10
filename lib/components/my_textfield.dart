// lib/components/my_textfield.dart

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  // 💡 ADDED: Parameters needed for validation and number input
  final TextInputType? keyboardType; 
  final String? Function(String?)? validator; 

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    this.keyboardType, // 💡 Initialized
    this.validator,    // 💡 Initialized
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      // 💡 CHANGED: Using TextFormField to enable the validator parameter
      child: TextFormField( 
        controller: controller,
        obscureText: obscureText,
        // 💡 PASSED: New parameters to the internal widget
        keyboardType: keyboardType, 
        validator: validator,
        
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}