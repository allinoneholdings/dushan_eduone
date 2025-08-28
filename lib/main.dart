import 'package:edu_one/screens/admin/admin_navigation.dart';
import 'package:edu_one/config/font_profile.dart';
import 'package:edu_one/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

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

        if (snapshot.hasData) {
          // User is signed in, show the AdminNavigation page
          return const AdminNavigation();
        } else {
          // User is not signed in, show the SignIn page
          return const SignIn();
        }
      },
    );
  }
}
