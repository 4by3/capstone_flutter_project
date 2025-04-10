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
  late List<AnimationController> _answerControllers;
  late List<Animation<double>> _answerFadeAnimations;

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

    _answerControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (index * 150)),
      ),
    );

    _answerFadeAnimations = _answerControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

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

              const SizedBox(height: 40),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _questionFadeAnimation,
                      child: ScaleTransition(
                        scale: _questionScaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
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

                          return FadeTransition(
                            opacity: _answerFadeAnimations[animationIndex],
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() =>
                                      selectedAnswers[currentQuestionIndex] =
                                          option);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? answerColor.withOpacity(0.9)
                                        : answerColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: option,
                                        groupValue: selectedAnswers[
                                            currentQuestionIndex],
                                        onChanged: (value) {
                                          setState(() => selectedAnswers[
                                              currentQuestionIndex] = value!);
                                        },
                                        activeColor: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                    ],
                                  ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousQuestion,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedAnswers[currentQuestionIndex] != null
                            ? _nextQuestion
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
