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
      ),
      themeMode: ThemeMode.system,
      home: const SignUp(),
    );
  }
}


