import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type

import 'firebase_options.dart';
import 'package:salonapp/services/auth_service.dart'; // Provides userChanges stream

// Screens for navigation
import 'package:salonapp/screens/login_screen.dart';
import 'package:salonapp/screens/signup_screen.dart';
import 'package:salonapp/screens/appointments_screen.dart';
import 'package:salonapp/screens/profile_screen.dart';
// The new screen that checks the user's role (Admin, Employee, or Customer)
import 'package:salonapp/screens/role_redirect_screen.dart'; 

// Make main function asynchronous and add Firebase initialization
void main() async {
  // 1. Must be called first for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

// --- NEW CORE COMPONENT: Auth Listener (AuthWrapper) ---
// This widget is the entry point that checks the user's login status.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the user's authentication state (signed in or signed out)
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {
        // Show loading screen while connecting to Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        // If the user data is present (User is logged in)
        if (snapshot.hasData && snapshot.data != null) {
          // Redirect to the screen that fetches and handles the user's role.
          return const RoleRedirectScreen();
        } else {
          // User is NOT logged in. Show the login screen.
          return const LoginScreen();
        }
      },
    );
  }
}
// ---------------------------------------------------------


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleCut Reservation App',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(secondary: Colors.pinkAccent),
      ),
      
      // CRITICAL CHANGE: AuthWrapper is the home screen, handling all startup navigation
      home: const AuthWrapper(),
      
      // IMPORTANT: Routes map (fixes compilation errors by removing incorrect 'const')
      routes: {
        // Removed 'const' before the widget constructor in the non-const function
        '/signup': (context) => const SignupScreen(), // SignupScreen must be const if possible
        // Note: LoginScreen is now handled by AuthWrapper
        // Note: HomeScreen is now handled by RoleRedirectScreen
        
        // Corrected remaining routes (assuming these screens are Stateless or use const constructors)
        '/appointments': (context) => const AppointmentsScreen(), 
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}