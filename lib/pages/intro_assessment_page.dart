import 'package:flutter/material.dart';
import 'intro_completion_page.dart';
import '../models/question.dart';
import '../data/intro_data.dart';
import 'intro_page.dart';

class IntroAssessmentQuizPage extends StatefulWidget {
  final String intro;
  final List<Question> questions;

  const IntroAssessmentQuizPage({super.key, required this.intro, required this.questions});

  @override
  State<IntroAssessmentQuizPage> createState() => _IntroAssessmentQuizPageState();
}

class _IntroAssessmentQuizPageState extends State<IntroAssessmentQuizPage> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = []; // list to store answers for each question (nullable integers)
  List<int> questionScores = []; // list to store individual question scores
  int totalScore = 0;
  List<int> scores = [];

  // method for next button
  void checkAnswer() {
    final correctAnswers = widget.questions[currentQuestionIndex].correctness;
    int questionScore = 0;

    if (correctAnswers[selectedAnswers[currentQuestionIndex] ?? -1] == 1) {
      questionScore++;
    }

    // update the individual question score
    questionScores[currentQuestionIndex] = questionScore;

    // update total score by adding the current question score
    scores.add(questionScore);

    setState(() {
      if (currentQuestionIndex < widget.questions.length - 1) { // if it isn't the last question
        currentQuestionIndex++;
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => IntroCompletionPage(),
            ),
          );
        });
      }
    });
  }

  // method for back button
  void goBackOneQuestion() {
    final correctAnswers = widget.questions[currentQuestionIndex - 1].correctness;
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        totalScore -= correctAnswers[selectedAnswers[currentQuestionIndex] ?? 0]; // deletes previous answer from total score
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    if (selectedAnswers.length < widget.questions.length) {
      selectedAnswers.add(null); // add null for questions not yet answered
      questionScores.add(0); // add 0 for questions not yet scored
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.intro} - Question ${currentQuestionIndex + 1}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const IntroPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...List.generate(question.answers.length, (index) {
            return RadioListTile<int>(
              title: Text(question.answers[index]),
              value: index,
              groupValue: selectedAnswers[currentQuestionIndex],
              onChanged: (int? value) {
                setState(() {
                  selectedAnswers[currentQuestionIndex] = value; // stores the selected answer
                });
              },
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentQuestionIndex == 0 // if first question, disable back button
                    ? null
                    : goBackOneQuestion,
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: selectedAnswers[currentQuestionIndex] == null
                    ? null
                    : checkAnswer, 
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
