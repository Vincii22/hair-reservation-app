import 'package:flutter/material.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/components/my_button.dart';

class ReservationScreen extends StatefulWidget {
  final String stylistName;
  const ReservationScreen({super.key, required this.stylistName});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  // Placeholders for date and time selection
  String? selectedTimeSlot;
  DateTime selectedDate = DateTime.now();

  final List<String> timeSlots = ["9:00 AM", "10:30 AM", "12:00 PM", "2:00 PM", "3:30 PM", "5:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Book with ${widget.stylistName}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            // Placeholder for a Calendar Widget
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(
                "Calendar Widget Placeholder (Selected: ${selectedDate.day}/${selectedDate.month})",
                style: const TextStyle(color: Colors.deepPurple),
              )),
            ),
            const SizedBox(height: 30),
            
            const Text("2. Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: timeSlots.map((time) {
                bool isSelected = selectedTimeSlot == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeSlot = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey[300]!),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            const Text("3. Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Example of dynamic data integration
            _buildSummaryRow("Stylist:", widget.stylistName),
            _buildSummaryRow("Date:", "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
            _buildSummaryRow("Time:", selectedTimeSlot ?? "Please select a time"),
            _buildSummaryRow("Total Price:", "\$25.00", isTotal: true),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MyButton(
          text: "Confirm Booking",
          onTap: () {
            if (selectedTimeSlot != null) {
              // Confirmation Logic (will involve Firestore write later)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking Confirmed! (UI Placeholder)")),
              );
              Navigator.popUntil(context, (route) => route.isFirst); // Go back to Home
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a time slot.")),
              );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}