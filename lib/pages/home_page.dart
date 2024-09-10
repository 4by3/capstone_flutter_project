import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Privacy Awareness"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Home page',
              style: TextStyle(fontSize: 24),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Text("Password"),
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                ),
                ElevatedButton(
                  child: const Text("Friends"),
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                ),
                ElevatedButton(
                  child: const Text("Tagging"),
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                ),
                ElevatedButton(
                  child: const Text("Audience"),
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                ),
                ElevatedButton(
                  child: const Text("Content"),
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: const Text("Tutorial"),
              onPressed: () {
                // Add your onPressed logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}
