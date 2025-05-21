import 'package:capstone_project/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../widgets/video_popup.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:capstone_project/main.dart';

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
  late Future<List<Map<String, dynamic>>> _questionsFuture;
  late Future<Map<String, dynamic>> _featureFuture;
  final Set<int> _seenScenarioNumbers = {};
  List<bool> _isHovered = List.generate(4, (_) => false);
  bool _isPlayButtonHovered = false;
  bool _isScenarioButtonHovered = false;
  bool _isSubmitButtonHovered = false;
  bool _isBackButtonHovered = false;

  final Color textColor = const Color.fromARGB(255, 24, 53, 98);
  final Color answerColor = const Color.fromARGB(255, 18, 40, 74);

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProgress =
        prefs.getInt('feature_${widget.featureIndex}_progress') ?? 0;

    if (currentQuestionIndex > savedProgress) {
      await prefs.setInt(
          'feature_${widget.featureIndex}_progress', currentQuestionIndex);
    }

    selectedAnswers.forEach((index, answer) {
      prefs.setString('feature_${widget.featureIndex}_answer_$index', answer);
      prefs.setBool('feature_${widget.featureIndex}_correct_$index',
          previouslyCorrect[index] ?? false);
    });
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex =
        prefs.getInt('feature_${widget.featureIndex}_progress') ?? 0;

    final questions = await _questionsFuture;

    if (questions.isEmpty) {
      print('No questions available for loading progress');
      return;
    }

    int tempScore = 0;
    for (int i = 0; i < questions.length; i++) {
      final key = 'feature_${widget.featureIndex}_answer_$i';
      final correctKey = 'feature_${widget.featureIndex}_correct_$i';

      if (prefs.containsKey(key)) {
        selectedAnswers[i] = prefs.getString(key)!;
      }

      if (prefs.getBool(correctKey) == true) {
        previouslyCorrect[i] = true;
        tempScore++;
      }
    }

    setState(() {
      currentQuestionIndex = savedIndex < questions.length ? savedIndex : 0;
      score = tempScore;
    });
  }

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
    _featureFuture = _fetchFeature();
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

    _loadSavedProgress().then((_) {
      _startAnimations();
    });

    AudioService.startBackgroundMusic().catchError((e) {
      print('Failed to start background music: $e');
    });
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
      controller.value = 0.0;
    }

    if (showScenarioPopup) {
      _questionsFuture.then((questions) {
        if (questions.isNotEmpty && currentQuestionIndex < questions.length) {
          final question = questions[currentQuestionIndex];
          final hasScenario = question['scenario'] != null &&
              question['scenario'].toString().trim().isNotEmpty &&
              question['scenarioNumber'] != null;
          if (hasScenario &&
              !_seenScenarioNumbers.contains(question['scenarioNumber']) &&
              !_isScenarioPopupVisible &&
              mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _showScenarioPopup(question['scenario']);
                _seenScenarioNumbers.add(question['scenarioNumber']);
              }
            });
          }
        }
      });
    }
  }

  void _showScenarioPopup(String scenario) {
    if (mounted && !_isScenarioPopupVisible) {
      setState(() {
        _isScenarioPopupVisible = true;
      });
      _scenarioPopupController.forward();
    }
  }

  void _showVideoPopup(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VideoPopup(videoUrl: videoUrl);
      },
    );
  }

  void _hideScenarioPopup() {
    _scenarioPopupController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isScenarioPopupVisible = false;
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    await _saveProgress();
    await AudioService.stopBackgroundMusic().catchError((e) {
      print('Failed to stop background music on pop: $e');
    });
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

  void _submitAnswer(List<Map<String, dynamic>> questions) {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect =
        selectedAnswers[currentQuestionIndex] == currentQuestion['answer'];
    final wasPreviouslyCorrect =
        previouslyCorrect[currentQuestionIndex] == true;
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    if (isCorrect) {
      AudioService.playCorrect();
      if (!wasPreviouslyCorrect) {
        setState(() => score++);
        _confettiController.play();
      }
      previouslyCorrect[currentQuestionIndex] = true;
      _saveProgress();
    } else {
      AudioService.playWrong();
      if (wasPreviouslyCorrect) {
        setState(() => score--);
        previouslyCorrect[currentQuestionIndex] = false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Stack(
        children: [
          AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor:
                isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.95),
            elevation: 10,
            contentPadding: const EdgeInsets.all(20),
            content: SizedBox(
              width: 200,
              height: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30), // Increased top padding
                    child: Icon(
                      isCorrect
                          ? Icons.check_circle
                          : Icons
                              .cancel, // Changed to Icons.cancel for a bolder style
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            isCorrect
                                ? (currentQuestionIndex == questions.length - 1
                                    ? 'Congratulations on finishing!'
                                    : 'On to the next one?')
                                : 'Feedback: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : textColor,
                            ),
                          ),
                          if (!isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: AutoSizeText(
                                currentQuestion['feedback'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode ? Colors.white : textColor,
                                ),
                                maxLines: 10,
                                minFontSize: 14,
                                stepGranularity: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _isSubmitButtonHovered = true;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isSubmitButtonHovered = false;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _isSubmitButtonHovered = false;
                    });
                    Navigator.pop(context);
                    if (isCorrect &&
                        currentQuestionIndex < questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        _startAnimations();
                      });
                    } else if (isCorrect &&
                        currentQuestionIndex == questions.length - 1) {
                      _finishQuiz(questions.length);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? (_isSubmitButtonHovered
                              ? Colors.grey[850]
                              : Colors.grey[900])
                          : textColor,
                      border: isDarkMode
                          ? Border.all(
                              color: _isSubmitButtonHovered
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.3),
                              width: 1.5,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isCorrect
                            ? (currentQuestionIndex == questions.length - 1
                                ? 'Finish'
                                : 'Next')
                            : 'Try Again',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
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

  void _finishQuiz(int totalQuestions) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
            isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.95),
        elevation: 10,
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: 200,
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                score == totalQuestions ? Icons.celebration : Icons.check,
                color: score == totalQuestions
                    ? Colors.amber
                    : (isDarkMode ? Colors.white : textColor),
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                score == totalQuestions ? 'Perfect Score!' : 'Well Done!',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$score/$totalQuestions',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : textColor,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Text(
                  score == totalQuestions
                      ? 'You\'re a privacy expert!'
                      : 'Nice work! Try again to improve?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isBackButtonHovered = true;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isBackButtonHovered = false;
                });
              },
              onTapUp: (_) async {
                setState(() {
                  _isBackButtonHovered = false;
                });
                Navigator.pop(context);
                await AudioService.stopBackgroundMusic().catchError((e) {
                  print('Failed to stop background music on pop: $e');
                });
                Navigator.pop(context, score);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? (_isBackButtonHovered
                          ? Colors.grey[850]
                          : Colors.grey[900])
                      : textColor,
                  border: isDarkMode
                      ? Border.all(
                          color: _isBackButtonHovered
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchQuestions() async {
    try {
      final collection = widget.mode == 'hard'
          ? 'hard_intro_questions'
          : 'easy_intro_questions';
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('featureIndex', isEqualTo: widget.featureIndex)
          .get();
      final questions = snapshot.docs.map((doc) => doc.data()).toList();
      questions.sort((a, b) {
        final aOrder = a['questionOrder'] ?? 0;
        final bOrder = b['questionOrder'] ?? 0;
        return aOrder.compareTo(bOrder);
      });
      print('Fetched questions: $questions');
      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchFeature() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('features')
          .where('index', isEqualTo: widget.featureIndex)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        print('No feature found for index ${widget.featureIndex}');
        return {};
      }
    } catch (e) {
      print('Error fetching feature: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Feature Quiz'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _onWillPop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.white : textColor,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _questionsFuture,
          builder: (context, questionSnapshot) {
            if (questionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (questionSnapshot.hasError ||
                !questionSnapshot.hasData ||
                questionSnapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  questionSnapshot.hasError
                      ? 'Error loading questions: ${questionSnapshot.error}'
                      : 'No questions found for this feature.',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : textColor,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final questions = questionSnapshot.data!;
            if (currentQuestionIndex >= questions.length) {
              return const Center(
                child: Text(
                  'Invalid question index.',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            }

            final question = questions[currentQuestionIndex];
            final totalQuestions = questions.length;
            final options = question['options'] as List<dynamic>;
            final hasScenario = question['scenario'] != null &&
                question['scenario'].toString().trim().isNotEmpty &&
                question['scenarioNumber'] != null;

            return FutureBuilder<Map<String, dynamic>>(
              future: _featureFuture,
              builder: (context, featureSnapshot) {
                if (featureSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (featureSnapshot.hasError || !featureSnapshot.hasData) {
                  return Center(
                    child: Text(
                      featureSnapshot.hasError
                          ? 'Error loading feature: ${featureSnapshot.error}'
                          : 'No feature data found.',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : textColor,
                          fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final feature = featureSnapshot.data!;
                final videoUrl = feature['video'] ?? '';

                return Stack(
                  children: [
                    Container(
                      decoration: isDarkMode
                          ? const BoxDecoration(color: Colors.black)
                          : BoxDecoration(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Question ${currentQuestionIndex + 1}/$totalQuestions',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : textColor,
                                        ),
                                      ),
                                      Text(
                                        'Score: $score',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    value: (currentQuestionIndex + 1) /
                                        totalQuestions,
                                    backgroundColor: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.blue[100],
                                    valueColor: AlwaysStoppedAnimation(
                                        isDarkMode ? Colors.white : textColor),
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTapDown: videoUrl.isNotEmpty
                                            ? (_) {
                                                setState(() {
                                                  _isPlayButtonHovered = true;
                                                });
                                              }
                                            : null,
                                        onTapCancel: videoUrl.isNotEmpty
                                            ? () {
                                                setState(() {
                                                  _isPlayButtonHovered = false;
                                                });
                                              }
                                            : null,
                                        onTapUp: videoUrl.isNotEmpty
                                            ? (_) {
                                                setState(() {
                                                  _isPlayButtonHovered = false;
                                                });
                                                _showVideoPopup(
                                                    context, videoUrl);
                                              }
                                            : null,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? (_isPlayButtonHovered
                                                    ? Colors.grey[850]
                                                    : Colors.grey[900])
                                                : (videoUrl.isNotEmpty
                                                    ? textColor
                                                    : Colors.grey),
                                            border: isDarkMode
                                                ? Border.all(
                                                    color: _isPlayButtonHovered
                                                        ? Colors.white
                                                            .withOpacity(0.7)
                                                        : Colors.white
                                                            .withOpacity(0.3),
                                                    width: 1.5,
                                                  )
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    isDarkMode ? 0.2 : 0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      if (hasScenario)
                                        GestureDetector(
                                          onTapDown: (_) {
                                            setState(() {
                                              _isScenarioButtonHovered = true;
                                            });
                                          },
                                          onTapCancel: () {
                                            setState(() {
                                              _isScenarioButtonHovered = false;
                                            });
                                          },
                                          onTapUp: (_) {
                                            setState(() {
                                              _isScenarioButtonHovered = false;
                                            });
                                            _showScenarioPopup(
                                                question['scenario']);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.grey[900]
                                                  : Colors.white,
                                              border: isDarkMode
                                                  ? Border.all(
                                                      color:
                                                          _isScenarioButtonHovered
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.7)
                                                              : Colors.white
                                                                  .withOpacity(
                                                                      0.3),
                                                      width: 1.5,
                                                    )
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(isDarkMode
                                                          ? 0.2
                                                          : 0.1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : textColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Scenario ${question['scenarioNumber']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : textColor,
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
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
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
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 9),
                                                  AutoSizeText(
                                                    question['question'],
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.4,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : textColor,
                                                    ),
                                                    maxLines: 5,
                                                    minFontSize: 16,
                                                    stepGranularity: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.left,
                                                    wrapWords: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 340,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 20),
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options[index];
                                        final isSelected = selectedAnswers[
                                                currentQuestionIndex] ==
                                            option;
                                        final animationIndex = index <
                                                _answerFadeAnimations.length
                                            ? index
                                            : _answerFadeAnimations.length - 1;
                                        final clickAnimationIndex = index <
                                                _answerClickOpacityAnimations
                                                    .length
                                            ? index
                                            : _answerClickOpacityAnimations
                                                    .length -
                                                1;

                                        return FadeTransition(
                                          opacity: _answerFadeAnimations[
                                              animationIndex],
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: GestureDetector(
                                              onTapDown: (_) {
                                                setState(() {
                                                  _isHovered[index] = true;
                                                });
                                              },
                                              onTapCancel: () {
                                                setState(() {
                                                  _isHovered[index] = false;
                                                });
                                              },
                                              onTapUp: (_) {
                                                setState(() {
                                                  _isHovered[index] = false;
                                                });
                                              },
                                              onTap: () {
                                                setState(() {
                                                  selectedAnswers[
                                                          currentQuestionIndex] =
                                                      option;
                                                });
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
                                                      height: 70,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.95)
                                                            : (isDarkMode
                                                                ? (_isHovered[index]
                                                                    ? Colors.grey[
                                                                        850]
                                                                    : Colors.grey[
                                                                        900])
                                                                : answerColor),
                                                        border: isDarkMode
                                                            ? Border.all(
                                                                color: _isHovered[
                                                                        index]
                                                                    ? Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.7)
                                                                    : Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.3),
                                                                width: 1.5,
                                                              )
                                                            : null,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    isDarkMode
                                                                        ? 0.2
                                                                        : 0.1),
                                                            blurRadius: 6,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: AutoSizeText(
                                                          option,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: isSelected
                                                                ? Colors.black87
                                                                : Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines: 2,
                                                          minFontSize: 14,
                                                          stepGranularity: 1,
                                                          wrapWords: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.left,
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
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTapDown: (_) {
                                        setState(() {
                                          _isBackButtonHovered = true;
                                        });
                                      },
                                      onTapCancel: () {
                                        setState(() {
                                          _isBackButtonHovered = false;
                                        });
                                      },
                                      onTapUp: (_) {
                                        setState(() {
                                          _isBackButtonHovered = false;
                                        });
                                        if (currentQuestionIndex == 0) {
                                          Navigator.pop(context, score);
                                        } else {
                                          setState(() {
                                            currentQuestionIndex--;
                                            _startAnimations(
                                                showScenarioPopup: false);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? (_isBackButtonHovered
                                                  ? Colors.grey[850]
                                                  : Colors.grey[900])
                                              : null,
                                          border: Border.all(
                                            color: isDarkMode
                                                ? (_isBackButtonHovered
                                                    ? Colors.white
                                                        .withOpacity(0.7)
                                                    : Colors.white
                                                        .withOpacity(0.3))
                                                : textColor,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            currentQuestionIndex == 0
                                                ? 'Back'
                                                : 'Previous',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: GestureDetector(
                                      onTapDown: (_) {
                                        setState(() {
                                          _isSubmitButtonHovered = true;
                                        });
                                      },
                                      onTapCancel: () {
                                        setState(() {
                                          _isSubmitButtonHovered = false;
                                        });
                                      },
                                      onTapUp: (_) {
                                        setState(() {
                                          _isSubmitButtonHovered = false;
                                        });
                                        if (selectedAnswers[
                                                currentQuestionIndex] !=
                                            null) {
                                          _submitAnswer(questions);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? (_isSubmitButtonHovered
                                                  ? Colors.grey[850]
                                                  : Colors.grey[900])
                                              : textColor,
                                          border: isDarkMode
                                              ? Border.all(
                                                  color: _isSubmitButtonHovered
                                                      ? Colors.white
                                                          .withOpacity(0.7)
                                                      : Colors.white
                                                          .withOpacity(0.3),
                                                  width: 1.5,
                                                )
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  isDarkMode ? 0.2 : 0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Submit',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                                  color: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(isDarkMode ? 0.2 : 0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color:
                                          isDarkMode ? Colors.white : textColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question['scenario'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        height: 1.4,
                                        color: isDarkMode
                                            ? Colors.white
                                            : textColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTapDown: (_) {
                                        setState(() {
                                          _isBackButtonHovered = true;
                                        });
                                      },
                                      onTapCancel: () {
                                        setState(() {
                                          _isBackButtonHovered = false;
                                        });
                                      },
                                      onTapUp: (_) {
                                        setState(() {
                                          _isBackButtonHovered = false;
                                        });
                                        _hideScenarioPopup();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 15),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? (_isBackButtonHovered
                                                  ? Colors.grey[850]
                                                  : Colors.grey[900])
                                              : textColor,
                                          border: isDarkMode
                                              ? Border.all(
                                                  color: _isBackButtonHovered
                                                      ? Colors.white
                                                          .withOpacity(0.7)
                                                      : Colors.white
                                                          .withOpacity(0.3),
                                                  width: 1.5,
                                                )
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  isDarkMode ? 0.2 : 0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Close',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
