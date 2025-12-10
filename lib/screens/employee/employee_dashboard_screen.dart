import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salonapp/services/auth_service.dart';
// ⭐️ REQUIRED FIX IMPORT ⭐️
import 'package:intl/intl.dart'; 
// Import the placeholder screen for navigation
import 'package:salonapp/screens/employee/appointment_detail_screen.dart'; 
// 💡 REQUIRED IMPORT: The screen for managing employee availability
import 'package:salonapp/screens/employee/manage_schedule_screen.dart'; 
// 🚀 NEW IMPORT: The screen for managing employee services
import 'package:salonapp/screens/employee/employee_service_screen.dart'; 
// ⭐️ NEW IMPORT: The screen for managing pending approvals
import 'package:salonapp/screens/employee/pending_appointments_screen.dart'; 

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  // --- Data Fetching (REAL IMPLEMENTATION) ---
  
  // 1. Fetch Today's Approved/Booked Appointments for display
  Future<List<DocumentSnapshot>> fetchTodayAppointments(String employeeId) async {
    if (employeeId.isEmpty) return [];

    // Define the start and end of today
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    // Firestore query to get appointments for today
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('employee_id', isEqualTo: employeeId)
        // Querying by date requires using Timestamp/DateTime objects
        .where('date', isGreaterThanOrEqualTo: startOfToday)
        .where('date', isLessThan: endOfToday)
        .where('status', whereIn: ['Booked', 'Approved']) // Only show appointments that will happen
        .orderBy('date')
        .get();
        
    // Returns the list of document snapshots
    return snapshot.docs;
  }
  
  // 2. Count Pending Appointments (for the badge)
  Future<int> countPendingAppointments(String employeeId) async {
    if (employeeId.isEmpty) return 0;
    
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('employee_id', isEqualTo: employeeId)
        .where('status', isEqualTo: 'Booked') // Count only those waiting for approval
        .count()
        .get();
        
    return snapshot.count ?? 0;
  }

  // --- Widget Builders ---

  Widget _buildAppointmentTile(BuildContext context, DocumentSnapshot appointmentDoc) {
    // Convert DocumentSnapshot to a readable map
    final data = appointmentDoc.data() as Map<String, dynamic>;
    final appointmentId = appointmentDoc.id;
    
    // Convert Timestamp to DateTime and format time
    final dateTimestamp = data['date'] as Timestamp;
    // FIX APPLIED HERE: DateFormat is now available due to import
    final time = DateFormat('h:mm a').format(dateTimestamp.toDate()); 
    final statusColor = data['status'] == 'Approved' ? Colors.green.shade600 : Colors.orange.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.access_time, color: statusColor, size: 30),
        title: Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          // Assuming you store customerName and serviceName in the appointment document
          '${data['customer_name'] ?? 'Customer ID: ${data['customer_id']}'} - ${data['service_name'] ?? 'Unknown Service'}',
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: Icon(data['status'] == 'Approved' ? Icons.check_circle : Icons.pending_actions, color: statusColor),
        onTap: () {
          // Navigate to a detailed view of the appointment
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(appointmentId: appointmentId),
            ),
          );
        },
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String employeeName = user?.displayName ?? 'Stylist';
    final String employeeId = user?.uid ?? '';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Work Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Welcome Header
            Text(
              'Hello, $employeeName!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              // FIX APPLIED HERE: DateFormat is now available due to import
              'Your schedule for today, ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // 📅 Schedule Overview Card (Stylist Focus)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.indigo.withOpacity(0.1),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DashboardStat(icon: Icons.cut, label: 'Services Done', value: '5'), // Placeholder
                    _DashboardStat(icon: Icons.calendar_month, label: 'Today Bookings', value: '3'), // Placeholder
                    _DashboardStat(icon: Icons.star, label: 'Avg Rating', value: '4.8'), // Placeholder
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- Management Buttons ---
            
            // ⭐ 1. Button to Review Pending Bookings
            FutureBuilder<int>(
              future: countPendingAppointments(employeeId),
              builder: (context, snapshot) {
                final pendingCount = snapshot.data ?? 0;
                
                return Stack(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.mark_email_unread, color: Colors.white),
                      label: const Text('Review Pending Bookings', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pendingCount > 0 ? Colors.red.shade700 : Colors.indigo.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PendingAppointmentsScreen()),
                        );
                      },
                    ),
                    // Badge for pending count
                    if (pendingCount > 0)
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2)
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 15),

            // 📅 2. Button to Manage Schedule (Existing)
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_calendar, color: Colors.white),
              label: const Text('Edit My Schedule Availability', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageScheduleScreen()),
                );
              },
            ),
            
            const SizedBox(height: 15),

            // 🛠️ 3. Button to Manage Services (Existing)
            ElevatedButton.icon(
              icon: const Icon(Icons.design_services, color: Colors.white),
              label: const Text('Manage My Services', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EmployeeServiceScreen()),
                );
              },
            ),

            const SizedBox(height: 40),

            // 📋 Today's Appointments List
            const Text(
              "Today's Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Divider(),

            // FutureBuilder now uses the real Firestore fetch function
            FutureBuilder<List<DocumentSnapshot>>(
              future: fetchTodayAppointments(employeeId), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading appointments: ${snapshot.error}'));
                }
                
                final appointments = snapshot.data ?? [];

                if (appointments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text('You have no scheduled appointments for today!'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentTile(context, appointments[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widget for Stats Card (Unchanged) ---
class _DashboardStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DashboardStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}