import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/pages/intro_page.dart';
import 'package:capstone_project/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ThemeProvider class to manage theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Load the saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if the intro page should be shown
  Future<bool> _checkIntroPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('goIntroPage') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.blue[50],
            textTheme: GoogleFonts.dmSansTextTheme(
              Theme.of(context).textTheme,
            ),
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 24, 53, 98),
              onPrimary: Colors.white,
              secondary: Colors.blue[100]!,
              background: Colors.blue[50]!,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 53, 98),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
            textTheme: GoogleFonts.dmSansTextTheme(
              Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white70,
                    displayColor: Colors.white,
                  ),
            ),
            colorScheme: ColorScheme.dark(
              primary: const Color.fromARGB(255, 24, 53, 98),
              onPrimary: Colors.white,
              secondary: Colors.grey[800]!,
              background: Colors.grey[900]!,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 53, 98),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
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
      },
    );
  }
}
