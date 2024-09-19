import 'package:flutter/material.dart';
import 'package:capstone_project/pages/home_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Intro"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center,
              child: Text(
              'This application will familiarize Facebook users with privacy settings. \rFacebook users can learn about these settings through audio-visual tutorials and test their knowledge with quizzes. \rThe goal of this application is to raise awareness about privacy among Facebook users.',
              textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              child: const Text("Start"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
