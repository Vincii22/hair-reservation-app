import 'package:flutter/material.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/components/appointment_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: For Firestore access
import 'package:firebase_auth/firebase_auth.dart'; // NEW: For getting customer ID
import 'package:intl/intl.dart'; // NEW: For date formatting

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  // Helper function to determine status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Booked': // Pending Approval
        return Colors.orange; 
      case 'Rejected':
        return Colors.red;
      case 'Completed':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  // Helper to check if two dates are the same day (used for filtering upcoming vs past)
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String customerId = user?.uid ?? 'unknown_id';

    if (customerId == 'unknown_id') {
      return const Scaffold(
        appBar: CustomAppBar(title: 'My Bookings', hasBackButton: false),
        body: Center(child: Text('Please log in to view your appointments.')),
      );
    }
    
    // Stream appointments for the current customer, ordered by date
    final Stream<QuerySnapshot> appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('customer_id', isEqualTo: customerId)
        .orderBy('date', descending: true) // Fetches most recent first
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'My Bookings', hasBackButton: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading appointments: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no appointments yet. Start booking!'));
          }

          final appointments = snapshot.data!.docs;
          final DateTime now = DateTime.now();

          // Separate appointments into upcoming and past
          final List<DocumentSnapshot> upcomingAppointments = [];
          final List<DocumentSnapshot> pastAppointments = [];

          for (var doc in appointments) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp dateTimestamp = data['date'] as Timestamp;
            final DateTime appointmentDateTime = dateTimestamp.toDate();
            
            // Appointment is "Upcoming" if the date is in the future or today
            if (appointmentDateTime.isAfter(now) || isSameDay(appointmentDateTime, now)) {
              upcomingAppointments.add(doc);
            } else {
              // Appointment is "Past" if the date is before today
              pastAppointments.add(doc);
            }
          }
          
          // Sort upcoming appointments ascending (so the next one is first)
          upcomingAppointments.sort((a, b) => 
            (a['date'] as Timestamp).compareTo(b['date'] as Timestamp));
          
          // Sort past appointments descending (most recent first)
          pastAppointments.sort((a, b) => 
            (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));


          return SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Upcoming Appointments ---
                const Text("Upcoming Appointments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(height: 20, thickness: 1),
                
                if (upcomingAppointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                    child: Text('No upcoming appointments scheduled.'),
                  ),

                ...upcomingAppointments.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final appointmentDateTime = (data['date'] as Timestamp).toDate();
                  final status = data['status'] ?? 'N/A';
                  
                  // Format the date/time string for upcoming appointments
                  final timeString = DateFormat('EEE, MMM d @ h:mm a').format(appointmentDateTime);

                  return Column(
                    children: [
                      AppointmentTile(
                        stylistName: data['employee_name'] ?? 'Stylist N/A',
                        service: data['service_name'] ?? 'Service N/A',
                        time: timeString,
                        // Assuming AppointmentTile is passive, you may wrap it in GestureDetector for details
                      ),
                      // Status indicator below the tile
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // NOTE: You can add a Cancellation button here based on status
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                
                const SizedBox(height: 30),

                // --- Past History ---
                const Text("Past History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(height: 20, thickness: 1),

                if (pastAppointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                    child: Text('No past appointments found.'),
                  ),

                ...pastAppointments.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final appointmentDateTime = (data['date'] as Timestamp).toDate();
                  
                  // Format the date for past history (usually just date)
                  final timeString = DateFormat('MMM d, yyyy @ h:mm a').format(appointmentDateTime);
                  
                  return AppointmentTile(
                    stylistName: data['employee_name'] ?? 'Stylist N/A',
                    service: data['service_name'] ?? 'Service N/A',
                    time: timeString,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}