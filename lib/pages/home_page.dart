import 'package:flutter/material.dart';
import 'package:capstone_project/pages/tutorial_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Quizzes and Learning Videos"),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Interactive Quizzes and Learning Videos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  HomePageCard(
                    title: 'The Privacy Game',
                    // Update the icon and color for "The Privacy Game"
                    icon: Icons.privacy_tip_outlined, // Changed icon
                    color: Colors.amber[200]!, // Cream-yellow color
                    onTap: () =>
                        _showDialog(context, 'The Privacy Game', 'Test'),
                  ),
                  HomePageCard(
                    title: 'Secure Passwords',
                    icon: Icons.lock,
                    color: Colors.orange[300]!,
                    onTap: () =>
                        _showDialog(context, 'Secure Passwords', 'Test'),
                  ),
                  HomePageCard(
                    title: 'Legit or Scam?',
                    icon: Icons.security,
                    color: Colors.orange[400]!,
                    onTap: () => _showDialog(context, 'Legit or Scam?', 'Test'),
                  ),
                  HomePageCard(
                    title: 'Filter Tags!',
                    icon: Icons.filter_alt,
                    color: Colors.orange[500]!,
                    onTap: () => _showDialog(context, 'Filter Tags!', 'Test'),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () {
                    // Navigate to home
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.orange),
                  onPressed: () {
                    // Add share functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class HomePageCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomePageCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
