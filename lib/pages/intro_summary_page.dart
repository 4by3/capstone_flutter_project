import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class IntroSummaryPage extends StatefulWidget {
  final int totalScore;
  final String quizMode;

  const IntroSummaryPage({
    super.key,
    required this.totalScore,
    required this.quizMode,
  });

  @override
  State<IntroSummaryPage> createState() => _IntroSummaryPageState();
}

class _IntroSummaryPageState extends State<IntroSummaryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Color backgroundColor = Colors.blue[50]!;
  final Color secondaryBackgroundColor = Colors.blue[100]!;
  final Color textColor = const Color.fromARGB(255, 24, 53, 98);
  final Color answerColor = const Color.fromARGB(255, 18, 40, 74);
  final Color lightBlue = Colors.blue[100]!;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _continueToHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goIntroPage', false);
    await prefs.setString('quizMode', widget.quizMode);

    await prefs.setBool('introCompleted', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEasy = widget.quizMode == 'easy';
    final totalPossibleScore = 15;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, secondaryBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school,
                              size: 64,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              isEasy ? "EASY MODE" : "HARD MODE",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),

                          // Main heading
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              isEasy
                                  ? "Easy Mode Activated!"
                                  : "Hard Mode Activated!",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            "Score: ${widget.totalScore}/$totalPossibleScore",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Based on your quiz results (${widget.totalScore}/$totalPossibleScore), we'll start with ${isEasy ? 'easy' : 'hard'}-friendly questions to help you build a strong foundation in Facebook privacy.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: lightBlue,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.lightbulb_outline,
                                            color: textColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          "You'll learn step by step with helpful tutorial videos and interactive questions to check your understanding.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: lightBlue,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.access_time,
                                            color: textColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          "Move through each section at a comfortable pace.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _continueToHome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: answerColor,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }
}
