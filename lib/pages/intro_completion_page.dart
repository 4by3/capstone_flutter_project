import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class IntroCompletionPage extends StatelessWidget {
  const IntroCompletionPage({super.key});

// flag that makes next app open go to home page. This should activate on final page of quiz but here temporarily
  Future<void> _flagHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goIntroCompletionPage', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Insert feedback here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "Insert feedback here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // saves the home page
                await _flagHomePage();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 238, 179, 69),
                foregroundColor: Colors.black,
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
