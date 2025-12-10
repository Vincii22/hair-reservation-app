
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
// Note: Assuming you have a Service model, if not, this will need to be added.
// import 'package:salonapp/models/service.dart'; 

import 'package:salonapp/components/stylist_card.dart';
import 'package:salonapp/components/service_chip.dart';
import 'package:salonapp/screens/stylist_detail_screen.dart';
import 'package:salonapp/screens/appointments_screen.dart';
import 'package:salonapp/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeBody(), // HomeBody is now const
    const AppointmentsScreen(), // Page 2
    const ProfileScreen(), // Page 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Separate Widget for the actual Home content (Dynamic Feature 1 & 2)
class HomeBody extends StatefulWidget {
  const HomeBody({super.key}); // Added const constructor

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  // State for tracking the currently selected category filter
  String selectedServiceType = 'All'; 

  // --- Data Fetching Functions ---

  // Fetches unique categories from the 'services' collection
  Future<List<String>> fetchServiceCategories() async {
    // Only fetch active services
    final snapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('is_active', isEqualTo: true)
        .get();
    
    // Use a Set to store unique categories, then convert to List
    final Set<String> categories = {'All'}; // Start with 'All'
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('category') && data['category'] is String) {
        categories.add(data['category'] as String);
      }
    }
    return categories.toList();
  }

  // Fetches users with role 'employee'
  Future<List<Map<String, dynamic>>> fetchStylists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .where('is_active', isEqualTo: true) // Assuming employees have an 'is_active' flag
        .get();
    
    // Convert documents to a list of maps, INCLUDING THE DOCUMENT ID
    return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // 💡 FIX: Add the document ID as 'id'
        return data;
    }).toList();
  }
  
  // --- END Data Fetching Functions ---

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Unchanged)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "StyleCut Salon",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    },
                    child: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),

            // Search Bar (Unchanged)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    hintText: 'Search stylist or service...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Service Filter Chips (Dynamic Feature 1 - Categories)
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text("Popular Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 10),
            
            // 💡 FutureBuilder for dynamic categories
            FutureBuilder<List<String>>(
              future: fetchServiceCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple)),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text('Error loading categories: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  );
                }
                
                final dynamicCategories = snapshot.data ?? ['All'];
                
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 25.0),
                    itemCount: dynamicCategories.length,
                    itemBuilder: (context, index) {
                      final category = dynamicCategories[index];
                      return ServiceChip(
                        label: category,
                        isSelected: selectedServiceType == category,
                        onTap: () {
                          setState(() {
                            selectedServiceType = category;
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),

            // Stylist List (Dynamic Feature 2 - Employees)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Text("Top Rated Stylists", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 15),
            
            // 💡 FutureBuilder for dynamic stylists
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchStylists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('Error loading stylists: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  );
                }
                
                final stylists = snapshot.data ?? [];

                if (stylists.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text('No active stylists found.', style: TextStyle(fontStyle: FontStyle.italic)),
                  );
                }
                
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stylists.length,
                    padding: const EdgeInsets.only(left: 25.0),
                    itemBuilder: (context, index) {
                      final stylist = stylists[index];
                      
                      return GestureDetector(
                        onTap: () {
                          // Navigate to detail screen, passing the stylist's ID for data retrieval
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => StylistDetailScreen(
                                stylistName: stylist['name'] ?? 'Stylist N/A', 
                                employeeId: stylist['id'] ?? '', // Pass the fetched ID
                            ), 
                            ),
                          );
                        },
                        child: StylistCard(
                          stylistName: stylist['name'] ?? 'Stylist',
                          specialty: stylist['specialty'] ?? 'Hair Stylist', // Use actual data if available
                          rating: "4.7", // Placeholder, requires rating logic
                          color: index.isEven ? Colors.deepPurple[400]! : Colors.pinkAccent[400]!, // Alternating colors
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

