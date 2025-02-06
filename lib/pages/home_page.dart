import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_page.dart';
import 'quiz_page.dart';
import '../data/home_features_data.dart';

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
        title: const Text('Choose a Subject'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: subjects.keys.map((subject) {
          return ListTile(
            title: Text(subject),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    subject: subject,
                    questions: subjects[subject]!,
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
