import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../data/intro_quiz_data.dart';

class IntroQuizPage extends StatefulWidget {
  const IntroQuizPage({super.key});

  @override
  State<IntroQuizPage> createState() => _IntroQuizPageState();
}

class _IntroQuizPageState extends State<IntroQuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  Map<int, String> selectedAnswers = {};
  late AnimationController _questionController;
  late Animation<Offset> _questionSlideAnimation;
  late List<AnimationController> _answerControllers;
  late List<Animation<Offset>> _answerSlideAnimations;

  @override
  void initState() {
    super.initState();
    // Question animation
    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _questionController, curve: Curves.easeInOut));

    // Initialize answer animations with increasing durations
    _answerControllers = List.generate(
      3, 
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 700 + (index * 200)),
      ),
    );
    _answerSlideAnimations = _answerControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start animations for the first question
    _startAnimations();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Trigger animations when question changes
  void _startAnimations() {
    _questionController.reset();
    _questionController.forward();
    for (var controller in _answerControllers) {
      controller.reset();
      controller.forward();
    }
  }

  Map<String, int> _calculateFeatureScores() {
    Map<String, int> scores = {
      'Facebook Groups': 0,
      'Audience Setting for Posts': 0,
      'Interaction on Others\' Posts': 0,
      'Tag Review and Settings': 0,
      'Block, Restrict, Report Usage': 0,
    };

    const featureMapping = [
      'Facebook Groups',
      'Audience Setting for Posts',
      'Block, Restrict, Report Usage',
      'Tag Review and Settings',
      'Block, Restrict, Report Usage',
    ];

    for (var i = 0; i < introQuestions.length; i++) {
      final selected = selectedAnswers[i];
      if (selected == null) continue;

      final options = introQuestions[i]['options'] as List<String>;
      final answers = introQuestions[i]['answers'] as List<int>;
      final selectedIndex = options.indexOf(selected);
      if (selectedIndex != -1) {
        final feature = featureMapping[i];
        scores[feature] = (scores[feature] ?? 0) + answers[selectedIndex];
      }
    }

    scores.updateAll((key, value) => value > 4 ? 4 : value);
    return scores;
  }

  Future<void> _flagHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goIntroPage', false);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < introQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _startAnimations(); // Trigger slide animations for question and answers
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _startAnimations(); // Trigger slide animations for question and answers
      });
    }
  }

  void _submitQuiz() async {
    if (selectedAnswers.length == introQuestions.length) {
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
          content: Text('Please answer all questions before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = introQuestions[currentQuestionIndex];
    final totalQuestions = introQuestions.length;
    final options = question['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Intro Quiz',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1}/$totalQuestions',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / totalQuestions,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),

            // Question Container with Slide Animation
            SlideTransition(
              position: _questionSlideAnimation,
              child: Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${currentQuestionIndex + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question['question'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Answers Section with Slide Animations
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: options.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = selectedAnswers[currentQuestionIndex] == option;

                    // Ensure we don't access beyond _answerSlideAnimations length
                    final animationIndex = index < _answerSlideAnimations.length ? index : _answerSlideAnimations.length - 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SlideTransition(
                        position: _answerSlideAnimations[animationIndex],
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedAnswers[currentQuestionIndex] = option);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple.withOpacity(0.15)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.deepPurple : Colors.grey[400]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: option,
                                  groupValue: selectedAnswers[currentQuestionIndex],
                                  onChanged: (value) {
                                    setState(() => selectedAnswers[currentQuestionIndex] = value!);
                                  },
                                  activeColor: Colors.deepPurple,
                                  materialTapTargetSize: MaterialTapTargetSize.padded,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Colors.deepPurple, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _previousQuestion,
                        child: const Text(
                          'Previous',
                          style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  if (currentQuestionIndex > 0) const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: selectedAnswers[currentQuestionIndex] != null ? 5 : 0,
                      ),
                      onPressed: selectedAnswers[currentQuestionIndex] != null
                          ? _nextQuestion
                          : null,
                      child: Text(
                        currentQuestionIndex == totalQuestions - 1 ? 'Submit' : 'Next',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}