import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final String category;
  final double price;
  final int durationMinutes; // How long the service takes
  final bool isActive;

  const Service({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    this.isActive = true, // Defaulting to true is fine for the model layer
  });

  // Factory constructor to create a Service from a Firestore document
  factory Service.fromFirestore(DocumentSnapshot doc) {
    // 1. Safely cast the document data to a Map
    final data = doc.data() as Map<String, dynamic>? ?? {}; 
    
    // 2. Extract data safely, handling potential nulls and type differences (num to double/int)
    final priceData = data['price'];
    
    return Service(
      id: doc.id,
      name: data['name'] as String? ?? 'Service Name Missing',
      category: data['category'] as String? ?? 'Uncategorized',
      
      // CRITICAL FIX for Price: Handles int, double, or null safely
      price: (priceData is num) ? priceData.toDouble() : 0.0,
      
      // CRITICAL FIX for Duration: Uses 'duration_minutes' (which is in your toMap)
      // and safely retrieves as int.
      durationMinutes: data['duration_minutes'] as int? ?? 30,
      
      // CRITICAL FIX for isActive: Uses 'is_active' and defaults to false if missing, 
      // preventing unexpected display if the field was never set.
      isActive: data['is_active'] as bool? ?? false, 
    );
  }

  // Convert Service object to a map for Firestore 
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      // Ensure key matches the read key in fromFirestore
      'duration_minutes': durationMinutes, 
      // Ensure key matches the read key and the query in EmployeeServiceScreen
      'is_active': isActive, 
    };
  }
}