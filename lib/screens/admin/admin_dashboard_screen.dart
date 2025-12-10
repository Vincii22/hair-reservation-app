import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salonapp/services/auth_service.dart';
// 💡 NEW IMPORT: Import the screen we just created
import 'package:salonapp/screens/admin/create_employee_screen.dart';
import 'package:salonapp/screens/admin/manage_services_screen.dart'; 

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // --- Data Fetching Function ---
  Future<Map<String, int>> fetchDashboardData() async {
    final firestore = FirebaseFirestore.instance;

    final reservationsSnapshot = await firestore.collection('appointments').get();
    final usersSnapshot = await firestore.collection('users').get();
    
    int employeeCount = 0;
    int customerCount = 0;

    for (var doc in usersSnapshot.docs) {
      final role = doc.data()['role'];
      if (role == 'employee') {
        employeeCount++;
      } else if (role == 'customer') {
        customerCount++; 
      }
    }
    
    return {
      'reservations': reservationsSnapshot.docs.length,
      'employees': employeeCount,
      'customers': customerCount,
    };
  }

  // --- Widget Builders ---

  Widget _buildDashboardCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    Function()? onTap, // 💡 ADDED onTap parameter
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell( // 💡 WRAP IN INKWELL for tapability
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Icon(icon, color: color, size: 30), 
                ],
              ),
              const SizedBox(height: 10),
              Text(
                count,
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    // Get Admin Name for personalization
    final adminName = FirebaseAuth.instance.currentUser?.displayName ?? 'Admin';
    
    // --- Navigation Handlers ---
    void navigateToCreateEmployee() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CreateEmployeeScreen()),
      );
    }

    void navigateToManageEmployees() {
      // Placeholder for the screen that lists and allows editing of employees
      // We will create this screen next (e.g., EmployeeListScreen)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigation to Manage Employees (Not implemented yet)')),
      );
    }

void navigateToManageServices() {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const ManageServicesScreen()), // 💡 Updated navigation
  );
}
    // ---------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, int>>(
        future: fetchDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }
          
          final data = snapshot.data ?? {};
          final totalReservations = data['reservations']?.toString() ?? 'N/A';
          final totalEmployees = data['employees']?.toString() ?? 'N/A';
          final totalCustomers = data['customers']?.toString() ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Welcome Message
                Text(
                  'Welcome back, $adminName!',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  'Quick overview of your salon operations.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),

                // Dashboard Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    // Reservations Card (No navigation needed)
                    _buildDashboardCard(
                      title: 'Total Reservations',
                      count: totalReservations,
                      icon: Icons.calendar_today,
                      color: Colors.deepOrange,
                    ),
                    // Employees Card (No navigation needed)
                    _buildDashboardCard(
                      title: 'Active Employees',
                      count: totalEmployees,
                      icon: Icons.badge,
                      color: Colors.deepPurple,
                    ),
                    // Customers Card (No navigation needed)
                    _buildDashboardCard(
                      title: 'Registered Clients',
                      count: totalCustomers,
                      icon: Icons.group,
                      color: Colors.teal,
                    ),
                    // Management Button Card (Navigates to Employee List/Management)
                    _buildDashboardCard(
                      title: 'Manage Employees',
                      count: 'GO',
                      icon: Icons.person_add,
                      color: Colors.blue,
                      onTap: navigateToManageEmployees, // 💡 Link to navigation function
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                // Quick Action Section
                Text(
                  'Quick Actions',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Divider(),
                // Create New Employee Link
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1, color: Colors.blue),
                  title: const Text('Create New Employee'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: navigateToCreateEmployee, // 💡 Link to navigation function
                ),
                // Manage Services Link
                ListTile(
                  leading: const Icon(Icons.cut, color: Colors.deepPurple),
                  title: const Text('Manage Services & Prices'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: navigateToManageServices, // 💡 Link to navigation function
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}