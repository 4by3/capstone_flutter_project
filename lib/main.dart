import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/pages/intro_page.dart';
import 'package:capstone_project/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:capstone_project/services/privacy_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await PrivacyNotificationService().initNotifications();

  // Optionally, schedule a daily reminder for privacy settings
  await PrivacyNotificationService().scheduleDailyReminder(
    id: 1,
    title: 'Reminder to Update Privacy Settings',
    body: 'Don\'t forget to check and update your privacy settings on Facebook.',
    hour: 9,  // Example: 9 AM reminder
    minute: 0,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Shared preference which changes the page on app launch
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
