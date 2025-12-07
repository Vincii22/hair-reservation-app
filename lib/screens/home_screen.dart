import 'package:flutter/material.dart';
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
  String selectedServiceType = 'All';

  final List<String> serviceTypes = ['All', 'Haircut', 'Color', 'Shave', 'Treatment'];

  final List<Widget> _pages = [
    HomeBody(),
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
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String selectedServiceType = 'All';
  final List<String> serviceTypes = ['All', 'Haircut', 'Color', 'Shave', 'Treatment'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      // Navigate to Profile
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

            // Search Bar
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

            // Service Filter Chips (Dynamic Feature 1)
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text("Popular Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 25.0),
                itemCount: serviceTypes.length,
                itemBuilder: (context, index) {
                  return ServiceChip(
                    label: serviceTypes[index],
                    isSelected: selectedServiceType == serviceTypes[index],
                    onTap: () {
                      setState(() {
                        selectedServiceType = serviceTypes[index];
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Stylist List (Dynamic Feature 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text("Top Rated Stylists", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StylistDetailScreen(stylistName: "Cameron")));
                    },
                    child: StylistCard(stylistName: "Cameron", specialty: "Barber", rating: "4.8", color: Colors.deepPurple[400]!),
                  ),
                  StylistCard(stylistName: "Jenna", specialty: "Colorist", rating: "4.9", color: Colors.pinkAccent[400]!),
                  StylistCard(stylistName: "Mark", specialty: "Haircuts", rating: "4.5", color: Colors.teal[400]!),
                  const SizedBox(width: 25),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}