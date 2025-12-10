import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/models/service.dart'; // IMPORTANT: Ensure your Service model is accessible

class EmployeeServiceScreen extends StatefulWidget {
  const EmployeeServiceScreen({super.key});

  @override
  State<EmployeeServiceScreen> createState() => _EmployeeServiceScreenState();
}

class _EmployeeServiceScreenState extends State<EmployeeServiceScreen> {
  final _firestore = FirebaseFirestore.instance;
  // Get the currently authenticated employee's ID
  final String? _employeeId = FirebaseAuth.instance.currentUser?.uid;
  
  // Stores the list of master services (defined by Admin)
  List<Service> _masterServices = [];
  
  // Stores a map of {serviceId: isEnabledByEmployee}
  Map<String, bool> _employeeServiceStatus = {};
  
  // Controls loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (_employeeId != null) {
      _fetchMasterServices();
    } else {
      // Handle case where user is not logged in
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 1. Fetches all active services from the master list (admin-defined)
  Future<void> _fetchMasterServices() async {
    try {
      final masterSnapshot = await _firestore
          .collection('services')
          .where('is_active', isEqualTo: true) // Only show services the business has active
          .orderBy('name')
          .get();

      _masterServices = masterSnapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();

      // 2. After fetching master services, fetch the employee's status for them
      await _fetchEmployeeServiceStatus();

    } catch (e) {
      print('Error loading master services: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading master services.')),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  // 3. Fetches the employee's current enabled/disabled status for each service
  Future<void> _fetchEmployeeServiceStatus() async {
    if (_employeeId == null) return;

    try {
      final employeeServicesSnapshot = await _firestore
          .collection('users')
          .doc(_employeeId)
          .collection('services')
          .get();

      final Map<String, bool> statusMap = {};
      for (var doc in employeeServicesSnapshot.docs) {
        // Map service ID to the employee's current 'is_active' status
        statusMap[doc.id] = doc.data()['is_active'] ?? false;
      }

      setState(() {
        _employeeServiceStatus = statusMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading employee services status: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading your service selections.')),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  // 4. Toggles the service status for the employee and saves it to Firestore
  void _toggleServiceStatus(Service service, bool newValue) async {
    if (_employeeId == null) return;

    // Optimistic update for better UX
    setState(() {
      _employeeServiceStatus[service.id] = newValue;
    });

    try {
      final serviceRef = _firestore
          .collection('users')
          .doc(_employeeId)
          .collection('services')
          .doc(service.id);

      // Save the employee's choice along with master data for easy lookup by customers
      await serviceRef.set({
        'is_active': newValue,
        'name': service.name,
        'price': service.price,
        'durationMinutes': service.durationMinutes,
        'category': service.category,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${service.name} ${newValue ? 'enabled' : 'disabled'} successfully!')),
      );

    } catch (e) {
      print('Failed to update status for ${service.name}: $e'); // Debug print
      // Rollback the change on error
      setState(() {
        _employeeServiceStatus[service.id] = !newValue;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Manage My Services'),
      body: _employeeId == null
          ? const Center(child: Text('Error: Please log in again.'))
          : _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
              : _masterServices.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'The Admin has not created any active services yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _masterServices.length,
                      itemBuilder: (context, index) {
                        final service = _masterServices[index];
                        // Default to false if the employee has never touched the toggle
                        final isEnabled = _employeeServiceStatus[service.id] ?? false;
                        
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              service.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isEnabled ? Colors.deepPurple : Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                                '${service.durationMinutes} mins | \$${service.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: isEnabled ? Colors.black54 : Colors.grey.shade400,
                                ),
                              ),
                            trailing: Switch(
                              value: isEnabled,
                              onChanged: (newValue) => _toggleServiceStatus(service, newValue),
                              activeColor: Colors.deepPurple,
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.shade200,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}