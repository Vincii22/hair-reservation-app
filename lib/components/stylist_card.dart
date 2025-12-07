import 'package:flutter/material.dart';

class StylistCard extends StatelessWidget {
  final String stylistName;
  final String specialty;
  final String rating;
  final Color color;

  const StylistCard({
    super.key,
    required this.stylistName,
    required this.specialty,
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 25),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            stylistName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            specialty,
            style: TextStyle(color: Colors.grey[200]),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 15),
              Text(rating, style: const TextStyle(color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }
}