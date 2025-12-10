// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 NEW: Import Firebase Auth
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- LOGOUT LOGIC METHOD ---
  void _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    // 💡 Access the currently authenticated user
    final User? user = FirebaseAuth.instance.currentUser;
    
    // Provide default values if user data is somehow missing
    final String userName = user?.displayName ?? "Customer User";
    final String userEmail = user?.email ?? "Email Not Found";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Profile', hasBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 15),
            // 💡 Use the live user data
            Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(userEmail, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            
            // Display the User ID (useful for development)
            const SizedBox(height: 5),
            Text(
              'UID: ${user?.uid ?? 'N/A'}', 
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Profile Options List
            _buildProfileTile(Icons.history, "Booking History", () {}),
            _buildProfileTile(Icons.edit, "Edit Account Details", () {}),
            _buildProfileTile(Icons.settings, "Settings and Preferences", () {}),
            
            const SizedBox(height: 50),

            // Logout Button
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, Function() onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}