import 'package:flutter/material.dart';
import 'package:salonapp/components/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Placeholder User Data (to be replaced by Firestore data)
  final String userName = "Alex Johnson";
  final String userEmail = "alex.johnson@example.com";

  @override
  Widget build(BuildContext context) {
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
            Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(userEmail, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            
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
                // Firebase Auth Logout logic here
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