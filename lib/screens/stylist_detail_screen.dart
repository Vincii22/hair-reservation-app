import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salonapp/components/custom_app_bar.dart';
import 'package:salonapp/screens/reservation_screen.dart';
import 'package:salonapp/models/service.dart';

// Convert to StatefulWidget to handle asynchronous data loading
class StylistDetailScreen extends StatefulWidget {
  final String stylistName;
  final String employeeId; 

  const StylistDetailScreen({
    super.key, 
    required this.stylistName,
    // Ensure the employeeId is used instead of a placeholder
    required this.employeeId, 
  });

  @override
  State<StylistDetailScreen> createState() => _StylistDetailScreenState();
}

class _StylistDetailScreenState extends State<StylistDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  
  // List to hold the services fetched from the employee's subcollection
  List<Service> _stylistServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeServices();
  }

  // Function to fetch the services the employee has activated
  Future<void> _fetchEmployeeServices() async {
    try {
      // Query the employee's personal 'services' subcollection
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.employeeId)
          .collection('services')
          .where('is_active', isEqualTo: true) // Only fetch services the employee has toggled ON
          .get();

      final List<Service> loadedServices = snapshot.docs.map((doc) {
        // Use Service.fromFirestore. The fields (name, price, etc.) 
        // were saved in the employee's subcollection by the EmployeeServiceScreen.
        return Service.fromFirestore(doc);
      }).toList();

      setState(() {
        _stylistServices = loadedServices;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error fetching employee services: $e'); // Debug print
      setState(() {
        _isLoading = false;
        // Optionally show an error message
      });
    }
  }

  // Helper Widget for clickable and aesthetic services (Moved inside State)
  Widget _buildClickableServiceItem(
    BuildContext context, 
    Service service, 
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to Reservation Screen, passing the specific selected service
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ReservationScreen(
              stylistName: widget.stylistName,
              employeeId: widget.employeeId,
              selectedService: service, // CRUCIAL: Pass the selected service
            )
          )
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.deepPurple.shade100, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Colors.deepPurple
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.durationMinutes} minutes',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}', 
                  style: const TextStyle(
                    color: Colors.deepPurple, 
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.deepPurple, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: widget.stylistName),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stylist Image & Rating (Unchanged)
            Container(
              height: 250,
              color: Colors.deepPurple[50],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_pin, size: 100, color: Colors.deepPurple),
                    Text(widget.stylistName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  // About Me (Unchanged)
                  const Text("About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "Expert barber specializing in modern fades and classic men's styling. Over 8 years of experience in the industry. I believe in giving every client a clean, confident look tailored to their personal style.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // Services Offered 
                  const Text("Services Offered (Tap to Book)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 🛑 Conditional rendering for loading, empty, or data
                  _isLoading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.deepPurple),
                        ))
                      : _stylistServices.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("This stylist has not enabled any services yet.", style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _stylistServices.map((service) => 
                                _buildClickableServiceItem(context, service)
                              ).toList(),
                            ),
                            
                  const SizedBox(height: 50), // Padding for bottom of scroll
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}