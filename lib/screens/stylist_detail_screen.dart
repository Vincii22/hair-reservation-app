import 'package:flutter/material.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/components/my_button.dart';
import 'package:salonapp/screens/reservation_screen.dart';

class StylistDetailScreen extends StatelessWidget {
  final String stylistName;

  const StylistDetailScreen({super.key, required this.stylistName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: stylistName),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stylist Image & Rating
            Container(
              height: 250,
              color: Colors.deepPurple[50],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_pin, size: 100, color: Colors.deepPurple),
                    Text(stylistName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(" 4.8 | 120 Reviews", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "Expert barber specializing in modern fades and classic men's styling. Over 8 years of experience in the industry. I believe in giving every client a clean, confident look tailored to their personal style.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  const Text("Services Offered", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // Simple list of services
                  _buildServiceItem("Classic Haircut", "45 mins", "\$25.00"),
                  _buildServiceItem("Full Beard Trim", "20 mins", "\$15.00"),
                  _buildServiceItem("Fade & Style", "60 mins", "\$35.00"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MyButton(
          text: "Book Appointment",
          onTap: () {
            // Navigate to Reservation Screen
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationScreen(stylistName: stylistName)));
          },
        ),
      ),
    );
  }

  Widget _buildServiceItem(String name, String duration, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("$duration | $price", style: const TextStyle(color: Colors.deepPurple)),
        ],
      ),
    );
  }
}