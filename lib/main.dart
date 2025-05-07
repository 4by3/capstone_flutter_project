import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/pages/intro_page.dart';
import 'package:capstone_project/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase initialized successfully');

  // Upload questions to Firestore
  await uploadQuestionsToFirestore();

  runApp(const MyApp());
}

Future<void> uploadQuestionsToFirestore() async {
  print('Starting uploadQuestionsToFirestore');
  try {
    final snapshot = await FirebaseFirestore.instance.collection('questions').get();
    print('Snapshot docs count: ${snapshot.docs.length}');
    if (snapshot.docs.isNotEmpty) {
      print('Questions already exist in Firestore.');
      return;
    }

    final List<Map<String, dynamic>> introQuestions = [
      {
        'question': 'How do you respond to unwanted interactions from strangers on Facebook?',
        'options': [
          'I ignore them completely',
          'I restrict their ability to contact me',
          'I use block or report tools when needed',
          'I don’t know what options are available'
        ],
        'answers': [1, 2, 3, 0]
      },
      {
        'question': 'How do you evaluate a Facebook group before joining?',
        'options': [
          'I check the group’s privacy level and rules',
          'I see if it’s active and matches my interests',
          'I join based on a friend’s recommendation',
          'I don’t think much about it, I just join'
        ],
        'answers': [3, 2, 1, 0]
      },
      {
        'question': 'How do you decide who can see your Facebook posts?',
        'options': [
          'I set a custom audience for sensitive posts',
          'I stick to “Friends” for most posts',
          'I leave it as “Public” for simplicity',
          'I don’t adjust it, I use the default setting'
        ],
        'answers': [3, 2, 0, 1]
      },
      {
        'question': 'How cautious are you when engaging with posts from people you don’t know well?',
        'options': [
          'I often like or comment without much thought',
          'I engage if it’s public and seems safe',
          'I rarely interact unless I trust the person',
          'I avoid it entirely to protect my privacy'
        ],
        'answers': [0, 1, 2, 3]
      },
      {
        'question': 'How do you handle tags from others on your Facebook timeline?',
        'options': [
          'I don’t manage tags, they show up as is',
          'I remove tags if I don’t like them',
          'I review tags occasionally but not always',
          'I enable tag review so I approve them first'
        ],
        'answers': [0, 2, 1, 3]
      },
    ];

    final CollectionReference questionsCollection =
        FirebaseFirestore.instance.collection('questions');

    for (var question in introQuestions) {
      print('Uploading question: ${question['question']}');
      await questionsCollection.add({
        'question': question['question'],
        'options': question['options'],
        'answers': question['answers'],
      });
    }
    print('Questions uploaded successfully!');
  } catch (e) {
    print('Error uploading questions: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkIntroPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('goIntroPage') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkIntroPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return const IntroPage();
          } else {
            return const HomePage();
          }
        },
      ),
    );
  }
}