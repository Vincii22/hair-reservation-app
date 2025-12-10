// lib/screens/admin/manage_services_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salonapp/models/service.dart';
// 💡 CORRECTED: Uncommented the actual screen import
import 'package:salonapp/screens/admin/add_edit_service_screen.dart'; 

class ManageServicesScreen extends StatelessWidget {
  const ManageServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services & Pricing'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the 'services' collection in real-time
        stream: FirebaseFirestore.instance.collection('services').orderBy('category').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No services found. Tap the "+" to add one!'),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading services: ${snapshot.error}'));
          }

          final services = snapshot.data!.docs.map((doc) => Service.fromFirestore(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                leading: Icon(
                  service.isActive ? Icons.check_circle : Icons.visibility_off,
                  color: service.isActive ? Colors.teal : Colors.grey,
                ),
                title: Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${service.category} • ${service.durationMinutes} mins'),
                trailing: Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // 💡 FIX APPLIED: Navigate to Add/Edit screen for the selected service (EDIT mode)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditServiceScreen(service: service)
                    )
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // 💡 FIX APPLIED: Navigate to Add/Edit screen to create a new service (ADD mode)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditServiceScreen()
            )
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}