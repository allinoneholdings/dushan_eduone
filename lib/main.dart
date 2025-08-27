import 'package:edu_one/screens/admin/admin_navigation.dart';
import 'package:edu_one/screens/admin/page_admin_dashboard.dart';
import 'package:edu_one/config/font_profile.dart';
import 'package:edu_one/signin.dart';
import 'package:edu_one/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/color_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      initialRoute: '/admin', // Set your starting page here
      routes: {
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/admin': (context) => const AdminNavigation(),
      },
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
      // home: const PageAdminDashboard(),

    );
  }
}
