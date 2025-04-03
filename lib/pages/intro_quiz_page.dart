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
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _questionScaleAnimation;
  late List<AnimationController> _answerControllers;
  late List<Animation<double>> _answerFadeAnimations;

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
      await _flagHomePage();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(initialFeatureScores: featureScores),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please answer all questions to continue'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              // Progress and Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1}/$totalQuestions',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / totalQuestions,
                      backgroundColor: Colors.blue[100],
                      valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // Question Card
              FadeTransition(
                opacity: _questionFadeAnimation,
                child: ScaleTransition(
                  scale: _questionScaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(30), 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${currentQuestionIndex + 1}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question['question'] as String,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Answers Section
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedAnswers[currentQuestionIndex] == option;
                    final animationIndex = index < _answerFadeAnimations.length ? index : _answerFadeAnimations.length - 1;

                    return FadeTransition(
                      opacity: _answerFadeAnimations[animationIndex],
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedAnswers[currentQuestionIndex] = option);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20), 
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[50] : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 6,
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
                                  activeColor: Colors.blueAccent,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isSelected ? Colors.blueAccent : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.blueAccent,
                                    size: 24,
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

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(20), 
                child: Row(
                  children: [
                    if (currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousQuestion,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            side: const BorderSide(color: Colors.blueAccent, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueAccent,
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
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentQuestionIndex == totalQuestions - 1 ? 'Submit' : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (currentQuestionIndex != totalQuestions - 1)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.arrow_forward, color: Colors.white),
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
