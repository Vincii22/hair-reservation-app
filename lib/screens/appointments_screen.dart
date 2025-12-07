import 'package:flutter/material.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/components/appointment_tile.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  // Dummy data for the UI
  final List<Map<String, String>> upcomingAppointments = const [
    {"stylist": "Cameron", "service": "Classic Haircut", "time": "Mon, Jan 10 @ 9:00 AM"},
    {"stylist": "Jenna", "service": "Full Color", "time": "Wed, Jan 12 @ 2:00 PM"},
  ];

  final List<Map<String, String>> pastAppointments = const [
    {"stylist": "Mark", "service": "Beard Trim", "time": "Dec 25, 2023"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'My Bookings', hasBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upcoming Appointments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            // Use AppointmentTile component
            ...upcomingAppointments.map((appt) => AppointmentTile(
                  stylistName: appt["stylist"]!,
                  service: appt["service"]!,
                  time: appt["time"]!,
                )),
            
            const SizedBox(height: 30),

            const Text("Past History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            // Use AppointmentTile component
            ...pastAppointments.map((appt) => AppointmentTile(
                  stylistName: appt["stylist"]!,
                  service: appt["service"]!,
                  time: appt["time"]!,
                )),
          ],
        ),
      ),
    );
  }
}