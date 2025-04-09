import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/pages/intro_page.dart';
import 'package:capstone_project/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // shared preference which changes the page on app launch
  Future<bool> _checkIntroPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('goIntroPage') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ),
        ),
      home: FutureBuilder<bool>(
        future: _checkIntroPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return const IntroPage(); 
          } else {
            return const HomePage(); 
          }
        },
      ),
    );
  }
}
