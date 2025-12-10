import 'package:flutter/material.dart';

class AppointmentTile extends StatelessWidget {
  final String stylistName;
  final String service;
  final String time;

  const AppointmentTile({
    super.key,
    required this.stylistName,
    required this.service,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 15),
            
            // ⭐️ FIX: Wrapped the main content Column in Expanded ⭐️
            // This forces the Column to take up all remaining space, 
            // pushing the Spacer and Time to the end without overflowing.
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stylistName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    service,
                    // Added softWrap to prevent overflow on very long service names within the Expanded space
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    softWrap: true, 
                  ),
                ],
              ),
            ),
            
            // The Spacer() is now redundant because Expanded takes up the extra room.
            // We can remove it or keep it for fine-tuning, but removing it simplifies the logic.
            // Removed: const Spacer(), 
            
            const SizedBox(width: 10), // Add a small space before the time
            
            // The time text stays outside the Expanded widget.
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}