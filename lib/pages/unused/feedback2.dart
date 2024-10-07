import 'package:flutter/material.dart';

class Feedback2Page extends StatefulWidget {
  const Feedback2Page({super.key});

  @override
  Feedback2PageState createState() => Feedback2PageState();
}

class Feedback2PageState extends State<Feedback2Page> {
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
              'Wrong answer, try again :(',
              textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              child: const Text("Retry"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
