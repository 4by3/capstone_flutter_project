import 'package:flutter/material.dart';
import 'package:capstone_project/pages/feedback1.dart';
import 'package:capstone_project/pages/feedback2.dart';

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
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'You see an advertisement on Facebook that promises a free gift if you click the link. \rWhat should you do?',
                textAlign: TextAlign.center,
              ),
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
                // if no selection
                if (_selectedOption == 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Please select an option before proceeding"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  // correct answer
                } else if (_selectedOption == 2 || _selectedOption == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Feedback1Page()),
                  );
                  // wrong answer
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Feedback2Page()),
                  );
                }
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

