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
  // Future<bool> _checkIntroPage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool('goIntroPage') ?? true;
  // }

  Future<bool> _checkIfShowIntro() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user has completed intro summary
    final introCompleted = prefs.getBool('introCompleted') ?? false;

    // If true => skip IntroPage
    return !introCompleted;
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
        future: _checkIfShowIntro(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show IntroPage if not completed, else go to HomePage
          return snapshot.data == true ? const IntroPage() : const HomePage();
        },
      ),
    );
  }
}
