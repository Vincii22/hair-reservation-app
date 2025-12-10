// lib/screens/employee/appointment_detail_screen.dart

import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text(
          'Details for Appointment ID: $appointmentId\n(Screen under development)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}