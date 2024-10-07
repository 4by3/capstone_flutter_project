import 'package:flutter/material.dart';
import 'package:capstone_project/pages/home_page.dart';

class Feedback1Page extends StatefulWidget {
  const Feedback1Page({super.key});

  @override
  Feedback1PageState createState() => Feedback1PageState();
}

class Feedback1PageState extends State<Feedback1Page> {
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
              'Good job you passed',
              textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              child: const Text("Continue"),
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
