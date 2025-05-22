import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Added for ThemeProvider
import 'home_page.dart';
import 'package:capstone_project/main.dart'; // Added to access ThemeProvider

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
  bool _isHovered = false; // Track hover state for the Continue button

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
              colors: [backgroundColor, backgroundColor],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: Text(
              'Summary',
              style: TextStyle(
                color: isDarkMode ? Colors.white : textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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
                          : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
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
                              color: isDarkMode ? Colors.blue : Colors.orange[700],
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
            colors: [backgroundColor, secondaryBackgroundColor],
          ),
        ),
        child: SafeArea(
          top: false, // Don't add extra top padding since AppBar handles it
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
                              color:
                              isDarkMode ? Colors.grey[900] : Colors.white,
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
                              color: isDarkMode ? Colors.white : textColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[800] : lightBlue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              isEasy ? "EASY MODE" : "HARD MODE",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : textColor,
                              ),
                            ),
                          ),
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
                                color: isDarkMode ? Colors.white : textColor,
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
                              color: isDarkMode ? Colors.white : textColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(isDarkMode ? 0.2 : 0.08),
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
                                      color:
                                      isDarkMode ? Colors.white : textColor,
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
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : lightBlue,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.lightbulb_outline,
                                          color: isDarkMode
                                              ? Colors.white
                                              : textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          "You'll learn step by step with helpful tutorial videos and interactive questions to check your understanding.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode
                                                ? Colors.white
                                                : textColor,
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
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : lightBlue,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.access_time,
                                          color: isDarkMode
                                              ? Colors.white
                                              : textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          "Move through each section at a comfortable pace.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDarkMode
                                                ? Colors.white
                                                : textColor,
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
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isHovered = true;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _isHovered = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isHovered = false;
                        });
                        _continueToHome(context);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? (_isHovered
                                ? Colors.grey[850]
                                : Colors.grey[900])
                                : answerColor,
                            border: isDarkMode
                                ? Border.all(
                              color: _isHovered
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.3),
                              width: 1.5,
                            )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDarkMode ? 0.2 : 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Continue",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
