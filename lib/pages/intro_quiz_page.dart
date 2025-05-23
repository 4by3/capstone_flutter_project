import 'dart:convert';
import 'package:capstone_project/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'intro_summary_page.dart';
import 'intro_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:capstone_project/main.dart'; // Import main.dart for ThemeProvider

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
  // Track hover state for each option
  List<bool> _isHovered = List.generate(4, (_) => false);

  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _questionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeIn),
    )..addListener(() {
        // Debug print to confirm animation value
        print('Question Fade Animation Value: ${_questionFadeAnimation.value}');
      });

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
      )..addListener(() {
          // Debug print to confirm animation value
          print('Answer Fade Animation Value: ${controller.value}');
        });
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

    _startAnimations();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      isLoading = true;
      isOffline = false;
    });

    try {
      // Fetch from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('intro_questions').get();
      final fetchedQuestions = snapshot.docs.map((doc) => doc.data()).toList();

      if (fetchedQuestions.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_questions', jsonEncode(fetchedQuestions));
        print('Questions fetched from Firestore and cached');

        setState(() {
          questions = fetchedQuestions;
          isLoading = false;
        });
      } else {
        await _loadCachedQuestions();
      }
    } catch (e) {
      print('Error fetching questions: $e');
      await _loadCachedQuestions();
    }
  }

  Future<void> _loadCachedQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_questions');

    if (cachedData != null) {
      final cachedQuestions = jsonDecode(cachedData) as List<dynamic>;
      setState(() {
        questions = cachedQuestions.cast<Map<String, dynamic>>();
        isLoading = false;
        isOffline = true;
      });
      print('Loaded cached questions');
    } else {
      // No cached data and no Firestore data
      setState(() {
        isLoading = false;
        isOffline = true;
      });
      print('No questions available (offline and no cache)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'No internet connection and no cached questions. Please connect to the internet to load the quiz.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
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
    if (!mounted) return;
    _questionController.reset();
    _questionController.forward();
    for (var controller in _answerFadeControllers) {
      controller.reset();
      controller.forward();
    }
    for (var controller in _answerClickControllers) {
      controller.value = 0.0;
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

    for (var i = 0; i < questions.length; i++) {
      final selected = selectedAnswers[i];
      if (selected == null) continue;

      final options = questions[i]['options'] as List<dynamic>;
      final answers = questions[i]['answers'] as List<dynamic>;
      final selectedIndex = options.indexOf(selected);
      if (selectedIndex != -1) {
        final feature = featureMapping[i];
        scores[feature] =
            (scores[feature] ?? 0) + (answers[selectedIndex] as int);
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
    if (currentQuestionIndex < questions.length - 1) {
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
    if (selectedAnswers.length == questions.length) {
      final featureScores = _calculateFeatureScores();
      int totalScore = featureScores.values.reduce((a, b) => a + b);
      String quizMode = totalScore >= 9 ? 'hard' : 'easy';

      await _flagHomePage();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IntroSummaryPage(
            totalScore: totalScore,
            quizMode: quizMode,
            featureScores: featureScores,
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
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No questions available${isOffline ? ' (offline)' : ''}',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              if (isOffline)
                ElevatedButton(
                  onPressed: _fetchQuestions,
                  child: Text('Retry Connection'),
                ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    final totalQuestions = questions.length;
    final options = question['options'] as List<dynamic>;
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[50]!, Colors.blue[50]!],
                  ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: null,
            automaticallyImplyLeading: false,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 50,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: isDarkMode
                          ? LinearGradient(colors: [
                              Colors.blue,
                              Colors.blue.withOpacity(0.8)
                            ])
                          : LinearGradient(
                              colors: [Colors.grey[300]!, Colors.grey[400]!]),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: 2,
                          left: isDarkMode ? 26 : 2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
                              size: 12,
                              color:
                                  isDarkMode ? Colors.blue : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1}/$totalQuestions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / totalQuestions,
                      backgroundColor:
                          isDarkMode ? Colors.grey[800] : Colors.blue[100],
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).textTheme.bodyLarge?.color),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 24),
                        child: FadeTransition(
                          opacity: _questionFadeAnimation,
                          child: ScaleTransition(
                            scale: _questionScaleAnimation,
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight: 80,
                                maxHeight: 150,
                              ),
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Q${currentQuestionIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: Text(
                                      question['question'],
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
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
                                    SoundService.playClick();
                                    setState(() {
                                      selectedAnswers[currentQuestionIndex] =
                                          option;
                                    });
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
                                          constraints:
                                              BoxConstraints(minHeight: 65),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.95)
                                                : (isDarkMode
                                                    ? (_isHovered[index]
                                                        ? Colors.grey[850]
                                                        : Colors.grey[900])
                                                    : answerColor),
                                            border: isDarkMode
                                                ? Border.all(
                                                    color: _isHovered[index]
                                                        ? Colors.white
                                                            .withOpacity(0.7)
                                                        : Colors.white
                                                            .withOpacity(0.3),
                                                    width: 1.5,
                                                  )
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    isDarkMode ? 0.2 : 0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: AutoSizeText(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isSelected
                                                    ? Colors.black87
                                                    : (isDarkMode
                                                        ? Colors.white
                                                        : Colors.white),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              minFontSize: 12,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
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
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          SoundService.playClick();

                          if (currentQuestionIndex == 0) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const IntroPage()),
                            );
                          } else {
                            _previousQuestion();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color ??
                                  Colors.black,
                              width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          currentQuestionIndex == 0 ? 'Back' : 'Previous',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        onPressed: selectedAnswers[currentQuestionIndex] != null
                            ? () {
                                SoundService.playClick(); // 🔊 Play click sound
                                _nextQuestion();
                              }
                            : null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return textColor.withOpacity(0.5);
                              }
                              return textColor;
                            },
                          ),
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 15),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          elevation: MaterialStateProperty.all(5),
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
