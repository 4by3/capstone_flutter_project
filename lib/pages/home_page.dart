import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_page.dart';
import 'quiz_page.dart';
import '../data/home_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  // makes next app launch go to intro page
  Future<void> _resetHomePageFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goIntroPage', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Feature'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: features.keys.map((feature) {
          return ListTile(
            title: Text(feature),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    feature: feature,
                    questions: features[feature]!,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _resetHomePageFlag();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IntroPage(),
            ),
          );
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Redo Intro Quiz',
      ),
    );
  }
}
