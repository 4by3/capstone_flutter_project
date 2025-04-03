import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../data/features_quiz_data.dart';

class FeatureQuizPage extends StatefulWidget {
  final int featureIndex;

  const FeatureQuizPage({required this.featureIndex});

  @override
  _FeatureQuizPageState createState() => _FeatureQuizPageState();
}

class _FeatureQuizPageState extends State<FeatureQuizPage> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  Map<int, String> selectedAnswers = {};
  late ConfettiController _confettiController;
  late AnimationController _questionController;
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _questionScaleAnimation;
  late List<AnimationController> _answerControllers;
  late List<Animation<double>> _answerFadeAnimations;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

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
    _confettiController.dispose();
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

  Future<bool> _onWillPop() async {
    Navigator.pop(context, score);
    return true;
  }

  String getFeatureName() {
    switch (widget.featureIndex) {
      case 0: return 'Block, Restrict, Report Usage';
      case 1: return 'Facebook Groups';
      case 2: return 'Audience Setting for Posts';
      case 3: return 'Interaction on Others\' Posts';
      case 4: return 'Tag Review and Settings';
      default: return 'Unknown Feature';
    }
  }

  void _submitAnswer() {
    final questions = featureQuestions[widget.featureIndex]!;
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = selectedAnswers[currentQuestionIndex] == currentQuestion['answer'];

    if (isCorrect) {
      setState(() => score++);
      _confettiController.play();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Stack(
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white.withOpacity(0.95),
            elevation: 10,
            contentPadding: const EdgeInsets.all(20),
            title: Column(
              children: [
                Image.asset(
                  isCorrect ? 'assets/images/happy_bee.png' : 'assets/images/sad_bee.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  isCorrect ? 'Great Job!' : 'Not Quite',
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.redAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  isCorrect
                      ? (currentQuestionIndex == questions.length - 1
                          ? 'Congratulations on finishing!'
                          : 'You nailed it! On to the next one?')
                      : 'Feedback: ${currentQuestion['feedback']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? Colors.green : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: Text(
                    isCorrect && currentQuestionIndex == questions.length - 1 ? 'Finish' : 'Next',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (isCorrect) {
                      if (currentQuestionIndex < questions.length - 1) {
                        setState(() {
                          currentQuestionIndex++;
                          _startAnimations();
                        });
                      } else {
                        _finishQuiz();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          if (isCorrect)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.yellow, Colors.blue, Colors.pink],
                numberOfParticles: 20,
                gravity: 0.2,
              ),
            ),
        ],
      ),
    );
  }

  void _finishQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 10,
        contentPadding: const EdgeInsets.all(20),
        title: Column(
          children: [
            Icon(
              score == 5 ? Icons.celebration : Icons.check,
              color: score == 5 ? Colors.amber : Colors.blueAccent,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              score == 5 ? 'Perfect Score!' : 'Well Done!',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score/${featureQuestions[widget.featureIndex]!.length}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              score == 5 ? 'You\'re a privacy expert!' : 'Nice work! Try again to improve?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, score);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = featureQuestions[widget.featureIndex] ?? [];
    final question = questions[currentQuestionIndex];
    final totalQuestions = questions.length;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getFeatureName(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, score),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
          ),
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
                        Text(
                          'Score: $score',
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
                          question['question'],
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
                  itemCount: question['options'].length,
                  itemBuilder: (context, index) {
                    final option = question['options'][index];
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
                          onPressed: () {
                            setState(() {
                              currentQuestionIndex--;
                              _startAnimations();
                            });
                          },
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
                        onPressed: selectedAnswers[currentQuestionIndex] != null ? _submitAnswer : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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