import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../data/easyFeatures_quiz_data.dart';
import '../data/hardFeatures_quiz_data.dart';

class FeatureQuizPage extends StatefulWidget {
  final int featureIndex;
  final String mode;

  const FeatureQuizPage({
    required this.featureIndex,
    required this.mode,
    super.key,
  });

  @override
  _FeatureQuizPageState createState() => _FeatureQuizPageState();
}

class _FeatureQuizPageState extends State<FeatureQuizPage>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  Map<int, String> selectedAnswers = {};
  Map<int, bool> previouslyCorrect = {};
  late ConfettiController _confettiController;
  late AnimationController _questionController;
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _questionScaleAnimation;
  late List<AnimationController> _answerFadeControllers;
  late List<Animation<double>> _answerFadeAnimations;
  late List<AnimationController> _answerClickControllers;
  late List<Animation<double>> _answerClickOpacityAnimations;
  late AnimationController _scenarioPopupController;
  late Animation<Offset> _scenarioSlideAnimation;
  bool _isScenarioPopupVisible = false;

  final Color textColor = const Color.fromARGB(255, 24, 53, 98);
  final Color answerColor = const Color.fromARGB(255, 18, 40, 74);

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

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

    // Initialize controllers for four options
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

    _scenarioPopupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scenarioSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _scenarioPopupController, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _questionController.dispose();
    _scenarioPopupController.dispose();
    for (var controller in _answerFadeControllers) {
      controller.dispose();
    }
    for (var controller in _answerClickControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimations({bool showScenarioPopup = true}) {
    _questionController.reset();
    _questionController.forward();
    for (var controller in _answerFadeControllers) {
      controller.reset();
      controller.forward();
    }
    for (var controller in _answerClickControllers) {
      controller.value = 0.0; // Start at 0.9 opacity
    }

    // Only show scenario popup if showScenarioPopup is true
    if (showScenarioPopup) {
      final questions = widget.mode == 'hard'
          ? hardFeatureQuestions[widget.featureIndex]!
          : easyFeatureQuestions[widget.featureIndex]!;
      final question = questions[currentQuestionIndex];
      final hasScenario = question['scenario'] != null &&
          question['scenario'].toString().trim().isNotEmpty &&
          question['scenarioNumber'] != null;

      if (hasScenario && !_isScenarioPopupVisible) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showScenarioPopup(question['scenario']);
          }
        });
      }
    }
  }

  void _showScenarioPopup(String scenario) {
    setState(() {
      _isScenarioPopupVisible = true;
    });
    _scenarioPopupController.forward();
  }

  void _hideScenarioPopup() {
    _scenarioPopupController.reverse().then((_) {
      setState(() {
        _isScenarioPopupVisible = false;
      });
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, score);
    return true;
  }

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

  void _submitAnswer() {
    final questions = widget.mode == 'hard'
        ? hardFeatureQuestions[widget.featureIndex]!
        : easyFeatureQuestions[widget.featureIndex]!;
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect =
        selectedAnswers[currentQuestionIndex] == currentQuestion['answer'];
    final wasPreviouslyCorrect =
        previouslyCorrect[currentQuestionIndex] == true;

    if (isCorrect) {
      if (!wasPreviouslyCorrect) {
        setState(() => score++);
        _confettiController.play();
      }
      previouslyCorrect[currentQuestionIndex] = true;
    } else if (wasPreviouslyCorrect) {
      setState(() => score--);
      previouslyCorrect[currentQuestionIndex] = false;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Stack(
        children: [
          AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white.withOpacity(0.95),
            elevation: 10,
            contentPadding: const EdgeInsets.all(20),
            title: Column(
              children: [
                Image.asset(
                  isCorrect
                      ? 'assets/images/happy_bee.png'
                      : 'assets/images/sad_bee.png',
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
                  style: TextStyle(fontSize: 20, color: textColor),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: Text(
                    isCorrect
                        ? (currentQuestionIndex == questions.length - 1
                            ? 'Finish'
                            : 'Next')
                        : 'Try Again',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (isCorrect &&
                        currentQuestionIndex < questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        _startAnimations();
                      });
                    } else if (isCorrect &&
                        currentQuestionIndex == questions.length - 1) {
                      _finishQuiz();
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
                colors: const [
                  Colors.green,
                  Colors.yellow,
                  Colors.blue,
                  Colors.pink
                ],
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
              color: score == 5 ? Colors.amber : textColor,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              score == 5 ? 'Perfect Score!' : 'Well Done!',
              style: TextStyle(
                color: textColor,
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
              '$score/${(widget.mode == 'hard' ? hardFeatureQuestions : easyFeatureQuestions)[widget.featureIndex]!.length}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              score == 5
                  ? 'You\'re a privacy expert!'
                  : 'Nice work! Try again to improve?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: textColor),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
    final questions = widget.mode == 'hard'
        ? hardFeatureQuestions[widget.featureIndex]!
        : easyFeatureQuestions[widget.featureIndex]!;
    final question = questions[currentQuestionIndex];
    final totalQuestions = questions.length;
    final options = question['options'] as List<dynamic>;
    final hasScenario = question['scenario'] != null &&
        question['scenario'].toString().trim().isNotEmpty &&
        question['scenarioNumber'] != null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                    // Progress bar and Scenario button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${currentQuestionIndex + 1}/$totalQuestions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Score: $score',
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
                          if (hasScenario) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _showScenarioPopup(question['scenario']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: textColor, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Scenario ${question['scenarioNumber']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Question and Answers
                    Expanded(
                      child: Column(
                        children: [
                          // Question (vertically centered, left-aligned)
                          Flexible(
                            fit: FlexFit.loose,
                            child: Center(
                              child: FadeTransition(
                                opacity: _questionFadeAnimation,
                                child: ScaleTransition(
                                  scale: _questionScaleAnimation,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            question['question'],
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
                              maxHeight: 440,
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
                                    selectedAnswers[currentQuestionIndex] ==
                                        option;
                                final animationIndex =
                                    index < _answerFadeAnimations.length
                                        ? index
                                        : _answerFadeAnimations.length - 1;
                                final clickAnimationIndex = index <
                                        _answerClickOpacityAnimations.length
                                    ? index
                                    : _answerClickOpacityAnimations.length - 1;

                                return FadeTransition(
                                  opacity:
                                      _answerFadeAnimations[animationIndex],
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAnswers[
                                              currentQuestionIndex] = option;
                                        });
                                        // Trigger click animation
                                        _answerClickControllers[
                                                clickAnimationIndex]
                                            .reset();
                                        _answerClickControllers[
                                                clickAnimationIndex]
                                            .forward();
                                      },
                                      child: AnimatedBuilder(
                                        animation:
                                            _answerClickOpacityAnimations[
                                                clickAnimationIndex],
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity:
                                                _answerClickOpacityAnimations[
                                                        clickAnimationIndex]
                                                    .value,
                                            child: Container(
                                              height: 88, // For two lines
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                        .withOpacity(0.95)
                                                    : answerColor,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
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
                    // Navigation Buttons
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
                                onPressed: () {
                                  setState(() {
                                    currentQuestionIndex--;
                                    _startAnimations(
                                        showScenarioPopup: false); // Skip popup
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 26),
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
                          if (currentQuestionIndex > 0)
                            const SizedBox(width: 16),
                          SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.45, // Small, consistent width
                            child: ElevatedButton(
                              onPressed:
                                  selectedAnswers[currentQuestionIndex] != null
                                      ? _submitAnswer
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: textColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 26),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
            // Scenario Popup
            if (_isScenarioPopupVisible)
              GestureDetector(
                onTap: _hideScenarioPopup,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: SlideTransition(
                      position: _scenarioSlideAnimation,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline,
                                    color: textColor, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Scenario ${question['scenarioNumber']}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              question['scenario'],
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.4,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _hideScenarioPopup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: textColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
