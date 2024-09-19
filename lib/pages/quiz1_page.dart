import 'package:flutter/material.dart';

class Quiz1Page extends StatefulWidget {
  const Quiz1Page({super.key});

  @override
  Quiz1PageState createState() => Quiz1PageState();
}

class Quiz1PageState extends State<Quiz1Page> {
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Quiz 1"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Lorem impsum',
            ),
            Image.asset(
              'assets/images/test.png',
              width: 250,
              height: 250,
            ),
            Column(
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Click the Link'),
                  value: 1,
                  groupValue: _selectedOption,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Ignore the ad'),
                  value: 2,
                  groupValue: _selectedOption,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Share the link with friends'),
                  value: 3,
                  groupValue: _selectedOption,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Report the ad'),
                  value: 4,
                  groupValue: _selectedOption,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: const Text("Feedback"),
              onPressed: () {
                // go to feedback
              },
            ),
            ElevatedButton(
              child: const Text("Tutorial"),
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
