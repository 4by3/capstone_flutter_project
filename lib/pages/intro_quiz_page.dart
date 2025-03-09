import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

///quiz page that assess user;s facebook usage patterns and privacy awareness to personalise their learning experience
///Jaanane - for testing only
class IntroQuizPage extends StatefulWidget {
  const IntroQuizPage({super.key});

  @override
  State<IntroQuizPage> createState() => _IntroQuizPageState();
}



class _IntroQuizPageState extends State<IntroQuizPage> {
  ///questions to assess user's facebook usage patterns and behaviours
  ///each question contains text, available options and selected answer
  final List<Map<String, dynamic>> profilingQuestions = [
    {
      'question': 'How often do you post on Facebook?',
      'options': ['Daily', 'Weekly', 'Rarely', 'Never'],
      'selected': null,
    },
    {
      'question': 'How often do you check your privacy settings on social media?',
      'options': ['Frequently', 'Occasionally', 'Rarely', 'Never'],
      'selected': null,
    },
    {
      'question': 'Which of the following is your preferred audience for sharing personal updates?',
      'options': ['Friends', 'Family', 'Public', 'Only Me'],
      'selected': null,
    },
    {
      'question': 'How often do you use the Facebook Marketplace?',
      'options': ['Daily', 'Weekly', 'Rarely', 'Never'],
      'selected': null,
    },
    {
      'question': 'Do you typically engage with posts in a Facebook group or just observe?',
      'options': ['Engage', 'Observe', 'Rarely', 'Never'],
      'selected': null,
    },
  ];

  final List<Map<String, dynamic>> skillLevelQuestions = [
    {
      'question': 'What is the most important thing to look out for before joining a Facebook group?',
      'options': [
        'Familiarity of group members',
        'Frequency of uninteresting and spammy posts',
        'Privacy settings, whether it is open or closed group',
        'Group size'
      ],
      'selected': null,
    },
    {
      'question': 'Which privacy setting do you use the most for posts on your timeline?',
      'options': ['Friends', 'Friends of Friends', 'Public', 'Only Me'],
      'selected': null,
    },
    {
      'question': 'What is your understanding of Facebook\'s privacy settings?',
      'options': ['I understand them well', 'Somewhat', 'I rarely adjust them', 'I don\'t know about them'],
      'selected': null,
    },
    {
      'question': 'How often do you review your Facebook account\'s privacy settings?',
      'options': ['Regularly', 'Occasionally', 'Rarely', 'Never'],
      'selected': null,
    },
  ];

  ///calculates features scores based on user's answers to determine their proficiency
  ///in different aspects of facebook privacy and proficiency
  ///returns a map with feature name as keys and scores (0-4) as values

  Map<String, int> _calculateFeatureScores() {
    //initialise scores for each feature topic
    Map<String, int> scores = {
      'Block, Restrict, Report Usage': 0,
      'Facebook Groups': 0,
      'Audience Setting for Posts': 0,
      'Interaction on Others\' Posts': 0,
      'Tag Review and Settings': 0,
    };

    // Analyze profiling questions to calculate initial scores
    for (var question in profilingQuestions) {
      final selected = question['selected'] as String?;
      if (selected == null) continue;

      final questionText = question['question'] as String;

      switch (questionText) {
        case 'How often do you post on Facebook?':
          if (selected == 'Daily' || selected == 'Weekly') {
            scores['Audience Setting for Posts'] = (scores['Audience Setting for Posts'] ?? 0) + 2;
            scores['Interaction on Others\' Posts'] = (scores['Interaction on Others\' Posts'] ?? 0) + 1;
          }
          break;
        case 'How often do you check your privacy settings on social media?':
          if (selected == 'Frequently' || selected == 'Occasionally') {
            scores['Block, Restrict, Report Usage'] = (scores['Block, Restrict, Report Usage'] ?? 0) + 2;
            scores['Tag Review and Settings'] = (scores['Tag Review and Settings'] ?? 0) + 2;
          }
          break;
        case 'Which of the following is your preferred audience for sharing personal updates?':
          if (selected == 'Only Me' || selected == 'Friends') {
            scores['Audience Setting for Posts'] = (scores['Audience Setting for Posts'] ?? 0) + 2;
          }
          break;
        case 'How often do you use the Facebook Marketplace?':
          if (selected == 'Daily' || selected == 'Weekly') {
            scores['Block, Restrict, Report Usage'] = (scores['Block, Restrict, Report Usage'] ?? 0) + 1;
          }
          break;
        case 'Do you typically engage with posts in a Facebook group or just observe?':
          if (selected == 'Engage') {
            scores['Facebook Groups'] = (scores['Facebook Groups'] ?? 0) + 2;
            scores['Interaction on Others\' Posts'] = (scores['Interaction on Others\' Posts'] ?? 0) + 2;
          }
          break;
      }
    }

    // Analyze skill level questions
    for (var question in skillLevelQuestions) {
      final selected = question['selected'] as String?;
      if (selected == null) continue;

      final questionText = question['question'] as String;

      switch (questionText) {
        case 'What is the most important thing to look out for before joining a Facebook group?':
          if (selected == 'Privacy settings, whether it is open or closed group') {
            scores['Facebook Groups'] = (scores['Facebook Groups'] ?? 0) + 2;
          }
          break;
        case 'Which privacy setting do you use the most for posts on your timeline?':
          if (selected == 'Friends' || selected == 'Only Me') {
            scores['Audience Setting for Posts'] = (scores['Audience Setting for Posts'] ?? 0) + 2;
          }
          break;
        case 'What is your understanding of Facebook\'s privacy settings?':
          if (selected == 'I understand them well') {
            scores['Block, Restrict, Report Usage'] = (scores['Block, Restrict, Report Usage'] ?? 0) + 1;
            scores['Tag Review and Settings'] = (scores['Tag Review and Settings'] ?? 0) + 1;
          }
          break;
        case 'How often do you review your Facebook account\'s privacy settings?':
          if (selected == 'Regularly' || selected == 'Occasionally') {
            scores['Tag Review and Settings'] = (scores['Tag Review and Settings'] ?? 0) + 2;
          }
          break;
      }
    }

    // Normalize scores to be between 0 and 4
    scores.updateAll((key, value) => value > 4 ? 4 : value);

    return scores;
  }

  bool _areAllQuestionsAnswered() {
    return [...profilingQuestions, ...skillLevelQuestions]
        .every((q) => q['selected'] != null);
  }
  // flag that makes next app open go to home page. This should activate on final page of quiz but here temporarily
  Future<void> _flagHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goIntroPage', false);
  }

  void _nextPage() async {
    if (_areAllQuestionsAnswered()) {
      final featureScores = _calculateFeatureScores();

      await _flagHomePage(); 
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(initialFeatureScores: featureScores),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before proceeding.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intro Quiz'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent.withOpacity(0.3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to the Intro Quiz!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please answer these questions to help us personalize your learning experience.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...profilingQuestions.map((questionData) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questionData['question'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(questionData['options'] as List<String>).map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: questionData['selected'] as String?,
                            onChanged: (value) {
                              setState(() {
                                questionData['selected'] = value;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ...skillLevelQuestions.map((questionData) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questionData['question'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(questionData['options'] as List<String>).map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: questionData['selected'] as String?,
                            onChanged: (value) {
                              setState(() {
                                questionData['selected'] = value;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _areAllQuestionsAnswered() ? _nextPage : null,
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}