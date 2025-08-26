import 'package:edu_one/config/font_profile.dart';
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
          colorScheme: ColorProfile.light),
      darkTheme: ThemeData(
        textTheme: TextTheme(
          headlineLarge: FontProfile.largeText,
          bodyMedium: FontProfile.mediumText,
          labelSmall: FontProfile.caption,
        ),),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'EduOne'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Text('Hello Dushan!',style: TextStyle(color:colorScheme.onSurface,fontSize: 18.0),),
      ),
    );
  }
}
