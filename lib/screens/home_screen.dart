import 'package:flutter/material.dart';
import 'package:your_project_name/components/stylist_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Find the best\nStylist for you",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 25),

          // 2. Search Bar (Using Container directly as an example of basic widgets)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: 'Search for services...',
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // 3. Horizontal List of Stylists (Dynamic Feature 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text("Top Stylists", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                StylistCard(stylistName: "Cameron", specialty: "Barber", rating: "4.8", color: Colors.deepPurple[400]!),
                StylistCard(stylistName: "Jenna", specialty: "Colorist", rating: "4.9", color: Colors.blue[400]!),
                StylistCard(stylistName: "Mark", specialty: "Haircuts", rating: "4.5", color: Colors.orange[400]!),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // 4. Vertical List of Services (Dynamic Feature 2)
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text("Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              children: [
                _buildServiceTile("Haircut", "45 mins", "\$25.00"),
                _buildServiceTile("Beard Trim", "20 mins", "\$15.00"),
                _buildServiceTile("Full Color", "120 mins", "\$80.00"),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper widget for list items (Simple local component)
  Widget _buildServiceTile(String name, String duration, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(duration, style: TextStyle(color: Colors.grey[500])),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}