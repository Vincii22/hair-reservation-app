import 'package:flutter/material.dart';
import 'package:salonapp/screens/login_screen.dart';
import 'package:salonapp/screens/signup_screen.dart';
import 'package:salonapp/screens/home_screen.dart';
import 'package:salonapp/screens/appointments_screen.dart';
import 'package:salonapp/screens/profile_screen.dart';

void main() {
  // In the next step, we will add Firebase initialization here:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleCut Reservation App',
      theme: ThemeData(
        // Set a clean theme with the primary color
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // You can use Google Fonts later for style
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(secondary: Colors.pinkAccent),
      ),
      
      // 1. Initial Route
      initialRoute: '/login', 
      
      // 2. Named Routes for Clean Navigation
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/profile': (context) => const ProfileScreen(),
        // Note: StylistDetailScreen and ReservationScreen are better passed via arguments 
        // using Navigator.push, as they need specific data (e.g., stylistName).
      },
    );
  }
}