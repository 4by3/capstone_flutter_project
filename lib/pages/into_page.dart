import 'package:flutter/material.dart';
import 'home_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

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
              "This application will familiarize Facebook users with privacy settings.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "The goal of this application is to raise awareness about privacy among Facebook users through quizzes and videos.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
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
