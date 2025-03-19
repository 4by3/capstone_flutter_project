import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../data/features_quiz_data.dart';

class FeatureQuizPage extends StatefulWidget {
  final int featureIndex;

  const FeatureQuizPage({required this.featureIndex});

  @override
  _FeatureQuizPageState createState() => _FeatureQuizPageState();
}

class _FeatureQuizPageState extends State<FeatureQuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  Map<int, String> selectedAnswers = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
      _confettiController.play(); // Trigger confetti for correct answers
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Stack(
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: Colors.white.withOpacity(0.95),
            elevation: 10,
            contentPadding: const EdgeInsets.all(20),
            title: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      isCorrect ? 'assets/images/happy_bee.png' : 'assets/images/sad_bee.png',
                      height: 120,
                      width: 120,
                    ),
                  ],
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
                      ? 'You nailed it! On to the next one?'
                      : 'Feedback: ${currentQuestion['feedback']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? Colors.green : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: Text(
                    isCorrect && currentQuestionIndex == questions.length - 1 
                        ? 'Finish' 
                        : 'Next',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (isCorrect) {
                      if (currentQuestionIndex < questions.length - 1) {
                        setState(() => currentQuestionIndex++);
                      } else {
                        _finishQuiz();
                      }
                    }
                  },
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.only(bottom: 20),
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
              color: score == 5 ? Colors.amber : Colors.deepPurple,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              score == 5 ? 'Perfect Score!' : 'Well Done!',
              style: const TextStyle(
                color: Colors.deepPurple,
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
            Text(
              '$score/${featureQuestions[widget.featureIndex]!.length}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              score == 5 
                  ? 'You\'re a privacy expert!' 
                  : 'Nice work! Try again to improve?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, score);
              },
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = featureQuestions[widget.featureIndex] ?? [];
    final question = questions[currentQuestionIndex];
    final totalQuestions = questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getFeatureName(),
          style: const TextStyle(
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
                      Text(
                        'Score: $score',
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
            
            // Question Container with Fixed Height
            Container(
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
                      question['question'],
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Answers Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: question['options'].map<Widget>((option) {
                    final isSelected = selectedAnswers[currentQuestionIndex] == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
                        onPressed: () => setState(() => currentQuestionIndex--),
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
                          ? _submitAnswer 
                          : null,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 20, color: Colors.white),
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