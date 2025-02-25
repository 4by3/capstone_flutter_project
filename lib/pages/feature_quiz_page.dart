import 'package:flutter/material.dart';

///quiz page that test users knowledge on specific facebook feature
///jaanane - for testing
///each feature has its own set of questions and tracks user's progress
class FeatureQuizPage extends StatefulWidget {
  ///index representing which feature's quiz to display
  ///0: Block, Restrict, Report Usage
  ///1: Facebook groups
  ///2: Audience Settings for Posts
  ///3: Interaction on Other's Posts
  ///4: Tag Review and Settings
  final int featureIndex;

  FeatureQuizPage({required this.featureIndex});

  @override
  _FeatureQuizPageState createState() => _FeatureQuizPageState();
}

class _FeatureQuizPageState extends State<FeatureQuizPage> {
  ///tracks the user's current score in the quiz
  int score = 0;

  ///Maps questions indices to the user's selected answers
  Map<int, String> selectedAnswers = {};

  ///indicates whether the quiz has been submitted
  bool isSubmitted = false;

  ///comprehensice question bank for all features
  ///organized by feature index containing questions, options and correct answers
  final Map<int, List<Map<String, dynamic>>> featureQuestions = {
    0: [
      // Block, Restrict, Report Usage Question
      {
        'question': 'What actions can you take when you want to block someone?',
        'options': [
          'A) Report their profile',
          'B) Restrict their access',
          'C) Both A and B',
          'D) None of the above'
        ],
        'answer': 'C) Both A and B'
      },
      {
        'question': 'How can you report inappropriate content on Facebook?',
        'options': [
          'A) By clicking the three dots on the post',
          'B) By unfriending the user',
          'C) By liking the post',
          'D) By sharing the post'
        ],
        'answer': 'A) By clicking the three dots on the post'
      },
      {
        'question':
            'What is the difference between blocking and restricting on Facebook?',
        'options': [
          'A) Blocking prevents the user from seeing your profile, restricting limits their interaction',
          'B) Blocking restricts only posts',
          'C) Restricting blocks everything',
          'D) There is no difference'
        ],
        'answer':
            'A) Blocking prevents the user from seeing your profile, restricting limits their interaction'
      },
      {
        'question': 'What can you report on Facebook?',
        'options': [
          'A) A post',
          'B) A comment',
          'C) A profile',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question':
            'What should you consider before reporting something on Facebook?',
        'options': [
          'A) Whether it violates Facebook\'s community standards',
          'B) Whether it involves someone you know personally',
          'C) Whether it is offensive',
          'D) All of the above'
        ],
        'answer': 'A) Whether it violates Facebook\'s community standards'
      },
    ],
    1: [
      // Facebook Groups Question
      {
        'question': 'What is the main purpose of Facebook groups?',
        'options': [
          'A) To share photos',
          'B) To organize events',
          'C) To connect people with shared interests',
          'D) To advertise products'
        ],
        'answer': 'C) To connect people with shared interests'
      },
      {
        'question':
            'What type of Facebook group is best for a local community?',
        'options': [
          'A) Public group',
          'B) Closed group',
          'C) Secret group',
          'D) None of the above'
        ],
        'answer': 'B) Closed group'
      },
      {
        'question': 'How do you ensure safety in a Facebook group as an admin?',
        'options': [
          'A) Screen member requests',
          'B) Set clear group rules',
          'C) Monitor post content',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question': 'What features are available to group administrators?',
        'options': [
          'A) Post approval',
          'B) Member management',
          'C) Content moderation',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question': 'How do you participate effectively in a Facebook group?',
        'options': [
          'A) Read group rules first',
          'B) Engage respectfully with others',
          'C) Share relevant content',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
    ],
    2: [
      // Audience Setting for Posts Question
      {
        'question': 'What does the audience setting for posts control?',
        'options': [
          'A) Who can see your posts',
          'B) Who can comment on your posts',
          'C) Who can like your posts',
          'D) None of the above'
        ],
        'answer': 'A) Who can see your posts'
      },
      {
        'question': 'When should you review your post\'s audience settings?',
        'options': [
          'A) Before posting',
          'B) After posting',
          'C) Never',
          'D) Only for photos'
        ],
        'answer': 'A) Before posting'
      },
      {
        'question': 'What is the most private audience setting for a post?',
        'options': [
          'A) Friends',
          'B) Only Me',
          'C) Public',
          'D) Friends of Friends'
        ],
        'answer': 'B) Only Me'
      },
      {
        'question': 'Can you change a post\'s audience setting after posting?',
        'options': [
          'A) Yes, anytime',
          'B) No, never',
          'C) Only within 24 hours',
          'D) Only for photos'
        ],
        'answer': 'A) Yes, anytime'
      },
      {
        'question': 'What happens when you set a post to "Friends except..."?',
        'options': [
          'A) Selected friends won\'t see the post',
          'B) Only selected friends see the post',
          'C) Everyone sees the post',
          'D) No one sees the post'
        ],
        'answer': 'A) Selected friends won\'t see the post'
      },
    ],
    3: [
      // Interaction on Others' Posts Question
      {
        'question':
            'What is a key aspect of interacting with posts on Facebook?',
        'options': [
          'A) Liking',
          'B) Commenting',
          'C) Sharing',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question': 'What should you consider before commenting on a post?',
        'options': [
          'A) The post\'s privacy settings',
          'B) Your audience',
          'C) The content appropriateness',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question': 'How can you ensure respectful interaction on posts?',
        'options': [
          'A) Read before commenting',
          'B) Be polite and considerate',
          'C) Avoid offensive language',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question':
            'What should you do if you see harmful content in comments?',
        'options': [
          'A) Ignore it',
          'B) Report it',
          'C) Engage with it',
          'D) Share it'
        ],
        'answer': 'B) Report it'
      },
      {
        'question': 'How can you control who interacts with your posts?',
        'options': [
          'A) Audience settings',
          'B) Comment controls',
          'C) Blocking users',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
    ],
    4: [
      // Tag and Review Settings Question
      {
        'question': 'What is the purpose of tag review settings?',
        'options': [
          'A) Control who can tag you',
          'B) Review tags before they appear',
          'C) Manage timeline posts',
          'D) All of the above'
        ],
        'answer': 'D) All of the above'
      },
      {
        'question': 'How do you enable tag review?',
        'options': [
          'A) Privacy Settings',
          'B) Timeline Settings',
          'C) Profile Settings',
          'D) Account Settings'
        ],
        'answer': 'A) Privacy Settings'
      },
      {
        'question': 'What happens when someone tags you with tag review on?',
        'options': [
          'A) Tag appears immediately',
          'B) You must approve the tag',
          'C) Tag is automatically rejected',
          'D) Tag is hidden'
        ],
        'answer': 'B) You must approve the tag'
      },
      {
        'question': 'Who can see posts you\'re tagged in?',
        'options': [
          'A) Everyone',
          'B) Only you',
          'C) Depends on the post\'s privacy settings',
          'D) Your friends only'
        ],
        'answer': 'C) Depends on the post\'s privacy settings'
      },
      {
        'question': 'How can you remove a tag from a post?',
        'options': [
          'A) Report the post',
          'B) Delete the post',
          'C) Remove tag through options',
          'D) Block the person'
        ],
        'answer': 'C) Remove tag through options'
      },
    ],
  };

  ///COnverts the feature index to a human readable feature name
  ///returns the name of the feature being tested
  String getFeatureName() {
    switch (widget.featureIndex) {
      case 0:
        return 'Block, Restrict, Report Usage';
      case 1:
        return 'Facebook Groups';
      case 2:
        return 'Audience Setting for Posts';
      case 3:
        return 'Interaction on Others\' Posts';
      case 4:
        return 'Tag Review and Settings';
      default:
        return 'Unknown Feature';
    }
  }

  ///calculates the final score and displays the results dialog
  ///- compares selected answer with the correct answer
  ///- updates the score state
  ///- shows a completion dialog with the score and options to review or return
  void _submitQuiz() {
    int newScore = 0;
    selectedAnswers.forEach((index, answer) {
      final correctAnswer =
          featureQuestions[widget.featureIndex]![index]['answer'];
      if (answer == correctAnswer) newScore++;
    });

    setState(() {
      score = newScore;
      isSubmitted = true;
    });
    //show completion dialog with score and option
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Icon(
                score == 5 ? Icons.stars : Icons.school,
                color: score == 5 ? Colors.amber : Colors.deepPurpleAccent,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                score == 5 ? 'Congratulations!' : 'Quiz Complete',
                style: const TextStyle(color: Colors.deepPurple),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You scored $score out of 5',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                score == 5
                    ? 'Perfect score! You\'ve mastered this feature!'
                    : 'Keep practicing to improve your score!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Review Answers'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
                child: const Text(
                'Return to Home',
                style: TextStyle(color: Colors.black),
                ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, score);
              },
            ),
          ],
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      score = 0;
      selectedAnswers.clear();
      isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = featureQuestions[widget.featureIndex] ?? [];
    final questionsAnswered = selectedAnswers.length;
    final totalQuestions = questions.length;

    //saves submission on back button
    return PopScope(
      canPop: !isSubmitted,
      onPopInvoked: (didPop) {
        if (!didPop && !isSubmitted) {
          Navigator.pop(context);
        } else if (!didPop && isSubmitted) {
          Navigator.pop(context, score);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getFeatureName(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent.withOpacity(0.3), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          '$questionsAnswered/$totalQuestions',
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: questionsAnswered / totalQuestions,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.deepPurpleAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    // final isAnswered = selectedAnswers.containsKey(index);
                    final isCorrect = isSubmitted &&
                        selectedAnswers[index] == question['answer'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Q${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    question['question'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isSubmitted)
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...question['options'].map<Widget>((option) {
                              final isSelected =
                                  selectedAnswers[index] == option;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.deepPurpleAccent
                                        : Colors.grey[300]!,
                                  ),
                                  color: isSelected
                                      ? Colors.deepPurpleAccent.withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: RadioListTile<String>(
                                  title: Text(option),
                                  value: option,
                                  groupValue: selectedAnswers[index],
                                  onChanged: isSubmitted
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedAnswers[index] = value!;
                                          });
                                        },
                                  activeColor: Colors.deepPurpleAccent,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isSubmitted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: questionsAnswered == totalQuestions
                        ? _submitQuiz
                        : null,
                    child: const Text(
                      'Submit Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              if (isSubmitted) // Show Redo Quiz button after submission
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                    onPressed: _resetQuiz, // Call reset function
                    child: const Text(
                      'Redo Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.black),
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
