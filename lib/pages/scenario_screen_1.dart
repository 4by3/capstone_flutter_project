import 'package:flutter/material.dart';
import 'quiz_screen_1.dart';
import 'menu.dart';

class ScenarioScreen1 extends StatelessWidget {
  const ScenarioScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q1 Scenario'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: const Color.fromARGB(255, 238, 179, 69),
            );
          },
        ),
      ),
      drawer: Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: const Color(0xFFEECC97),
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      '/Users/jaanane/development/quiz1/img/privacy(1).png',
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Below are various types of personal information. Consider each carefully and decide which information you feel comfortable sharing and which you prefer to keep confidential. Select your answer from the provided choices.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const QuizScreen1()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0B46F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
