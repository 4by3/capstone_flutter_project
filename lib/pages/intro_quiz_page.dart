import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'intro_summary_page.dart';

import '../data/intro_quiz_data.dart';

class IntroQuizPage extends StatefulWidget {
  const IntroQuizPage({super.key});

  @override
  State<IntroQuizPage> createState() => _IntroQuizPageState();
}

class _IntroQuizPageState extends State<IntroQuizPage>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  Map<int, String> selectedAnswers = {};
  late AnimationController _questionController;
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _questionScaleAnimation;
  late List<AnimationController> _answerFadeControllers;
  late List<Animation<double>> _answerFadeAnimations;
  late List<AnimationController> _answerClickControllers;
  late List<Animation<double>> _answerClickOpacityAnimations;

  final Color textColor = const Color.fromARGB(255, 24, 53, 98);
  final Color answerColor = const Color.fromARGB(255, 18, 40, 74);

  @override
  void initState() {
    super.initState();

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _questionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeIn),
    );

    _questionScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOutBack),
    );

    // Initialize controllers for fade-in animations (4 options)
    _answerFadeControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (index * 150)),
      ),
    );

    _answerFadeAnimations = _answerFadeControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Initialize controllers for click opacity animations (4 options)
    _answerClickControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _answerClickOpacityAnimations = _answerClickControllers.map((controller) {
      return Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerFadeControllers) {
      controller.dispose();
    }
    for (var controller in _answerClickControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimations() {
    _questionController.reset();
    _questionController.forward();
    for (var controller in _answerFadeControllers) {
      controller.reset();
      controller.forward();
    }
    // Reset click animations to initial state
    for (var controller in _answerClickControllers) {
      controller.value = 0.0; // Start at 0.9 opacity
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
      'Block, Restrict, Report Usage',
      'Facebook Groups',
      'Audience Setting for Posts',
      'Interaction on Others\' Posts',
      'Tag Review and Settings',
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
        _startAnimations();
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _startAnimations();
      });
    }
  }

  void _submitQuiz() async {
    if (selectedAnswers.length == introQuestions.length) {
      final featureScores = _calculateFeatureScores();
      int totalScore = featureScores.values.reduce((a, b) => a + b);
      String quizMode = totalScore >= 9 ? 'hard' : 'easy';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IntroSummaryPage(
            totalScore: totalScore,
            quizMode: quizMode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please answer all questions to continue'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1}/$totalQuestions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / totalQuestions,
                      backgroundColor: Colors.blue[100],
                      valueColor: AlwaysStoppedAnimation(textColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              // Question and Answers
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Question (centered vertically)
                    Flexible(
                      fit: FlexFit.loose,
                      child: Center(
                        child: FadeTransition(
                          opacity: _questionFadeAnimation,
                          child: ScaleTransition(
                            scale: _questionScaleAnimation,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Q${currentQuestionIndex + 1}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      question['question'] as String,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Answers
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 370, // For pushing the questions up
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected =
                              selectedAnswers[currentQuestionIndex] == option;
                          final animationIndex =
                              index < _answerFadeAnimations.length
                                  ? index
                                  : _answerFadeAnimations.length - 1;
                          final clickAnimationIndex =
                              index < _answerClickOpacityAnimations.length
                                  ? index
                                  : _answerClickOpacityAnimations.length - 1;

                          return FadeTransition(
                            opacity: _answerFadeAnimations[animationIndex],
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswers[currentQuestionIndex] =
                                        option;
                                  });
                                  // Trigger click animation
                                  _answerClickControllers[clickAnimationIndex]
                                      .reset();
                                  _answerClickControllers[clickAnimationIndex]
                                      .forward();
                                },
                                child: AnimatedBuilder(
                                  animation: _answerClickOpacityAnimations[
                                      clickAnimationIndex],
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _answerClickOpacityAnimations[
                                              clickAnimationIndex]
                                          .value,
                                      child: Container(
                                        height: 77, // For two lines
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.95)
                                              : answerColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: isSelected
                                                  ? Colors.black87
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: currentQuestionIndex == 0
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
                  children: [
                    if (currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousQuestion,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            side: BorderSide(color: textColor, width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (currentQuestionIndex > 0) const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        onPressed: selectedAnswers[currentQuestionIndex] != null
                            ? _nextQuestion
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentQuestionIndex == totalQuestions - 1
                                  ? 'Submit'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (currentQuestionIndex != totalQuestions - 1)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
