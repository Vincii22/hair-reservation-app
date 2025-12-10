import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salonapp/screens/home_screen.dart'; // Customer Home
// Placeholder screens for other roles
import 'package:salonapp/screens/admin/admin_dashboard_screen.dart'; 
import 'package:salonapp/screens/employee/employee_dashboard_screen.dart'; 

class RoleRedirectScreen extends StatelessWidget {
  const RoleRedirectScreen({super.key});

  // Function to fetch the user's role from Firestore
  Future<String> _fetchUserRole(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    // Check if the document exists and has the 'role' field
    if (userDoc.exists && userDoc.data()!.containsKey('role')) {
      return userDoc.get('role');
    }
    // Default to customer if data is missing or incomplete
    return 'customer'; 
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // User should not be null here if navigating from main.dart's StreamBuilder (Step 6)
    if (user == null) {
      // Should not happen, but return a safe state just in case
      return const Center(child: Text("Error: User not found.")); 
    }

    return FutureBuilder<String>(
      future: _fetchUserRole(user.uid),
      builder: (context, snapshot) {
        // Show loading indicator while fetching the role
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
          );
        }

        // Handle error state
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Error loading user role. Please restart.")),
          );
        }

        // Get the determined role
        final role = snapshot.data;

        // Redirect based on the role
        if (role == 'admin') {
          return const AdminDashboardScreen();
        } else if (role == 'employee') {
          return const EmployeeDashboardScreen();
        } else {
          // Default to Customer Home
          return const HomeScreen();
        }
      },
    );
  }
}