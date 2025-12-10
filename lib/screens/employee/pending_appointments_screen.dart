// lib/screens/employee/pending_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// You might need to import your Appointment model here if you have one.
// For this example, we'll work directly with DocumentSnapshot.

class PendingAppointmentsScreen extends StatefulWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  State<PendingAppointmentsScreen> createState() => _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  final String _employeeId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_id';
  
  // Reference to the Firestore collection for appointments
  final CollectionReference _appointmentsCollection = 
      FirebaseFirestore.instance.collection('appointments');

  @override
  Widget build(BuildContext context) {
    if (_employeeId == 'unknown_id') {
      return const Center(child: Text('Error: Employee ID not found.'));
    }

    // StreamBuilder listens for real-time updates to the list of 'Booked' appointments
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Appointments'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentsCollection
            .where('employee_id', isEqualTo: _employeeId)
            .where('status', isEqualTo: 'Booked') // Filter for pending requests
            .orderBy('date', descending: false) // Show oldest requests first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pendingAppointments = snapshot.data?.docs ?? [];

          if (pendingAppointments.isEmpty) {
            return const Center(
              child: Text(
                'No pending appointments currently.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pendingAppointments.length,
            itemBuilder: (context, index) {
              final appointmentDoc = pendingAppointments[index];
              final data = appointmentDoc.data() as Map<String, dynamic>;
              
              // Extract necessary data
              final dateTimestamp = data['date'] as Timestamp;
              final appointmentTime = dateTimestamp.toDate();
              final serviceName = data['service_name'] ?? 'Unknown Service';
              final customerId = data['customer_id'] as String;
              
              // Helper to fetch customer name based on ID (optional but recommended)
              // NOTE: This will require a separate function/future builder to display the name
              // For simplicity now, we display the ID.

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time: ${DateFormat('MMM d, h:mm a').format(appointmentTime)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Service: $serviceName',
                        style: const TextStyle(fontSize: 15),
                      ),
                      // NOTE: Fetching the user name is recommended for production.
                      Text(
                        'Customer ID: $customerId',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 2. Reject Button
                          TextButton(
                            onPressed: () => _updateAppointmentStatus(appointmentDoc.id, 'Rejected'),
                            child: const Text('Reject', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 10),
                          // 1. Approve Button
                          ElevatedButton.icon(
                            onPressed: () => _updateAppointmentStatus(appointmentDoc.id, 'Approved'),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Firestore Update Logic ---

  Future<void> _updateAppointmentStatus(String docId, String newStatus) async {
    try {
      await _appointmentsCollection.doc(docId).update({
        'status': newStatus,
        // Optional: Add a timestamp for when the status was updated
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $docId ${newStatus.toLowerCase()}.')),
      );

      // You might also trigger a notification to the customer here.

    } catch (e) {
      print('Error updating appointment status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }
}