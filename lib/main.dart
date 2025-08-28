import 'package:edu_one/screens/admin/admin_navigation.dart';
import 'package:edu_one/screens/staff/staff_navigation.dart'; // New import for staff navigation
import 'package:edu_one/screens/student/student_navigation.dart';
import 'package:edu_one/config/font_profile.dart';
import 'package:edu_one/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'config/color_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      title: 'edu one',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          headlineLarge: FontProfile.largeText,
          bodyMedium: FontProfile.mediumText,
          labelSmall: FontProfile.caption,
        ),
        useMaterial3: true,
        colorScheme: ColorProfile.light,
      ),
      darkTheme: ThemeData(
        textTheme: TextTheme(
          headlineLarge: FontProfile.largeText,
          bodyMedium: FontProfile.mediumText,
          labelSmall: FontProfile.caption,
        ),
        useMaterial3: true,
        colorScheme: ColorProfile.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // A helper function to determine the initial screen based on user role
  Widget _getInitialScreen(User? user) {
    if (user == null) {
      // If no user is logged in, show the sign-in page
      return const SignIn();
    }

    // Use a StreamBuilder to get the user's role from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // If there's an error or no user data, assume the default view is for students
          return const StudentNavigation();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userRole =
            userData?['role'] ??
            'Student';

        switch (userRole) {
          case 'Admin':
            return const AdminNavigation();
          case 'Staff':
            return const StaffNavigation();
          case 'Student':
          default:
            return const StudentNavigation();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _getInitialScreen(snapshot.data);
      },
    );
  }
}
