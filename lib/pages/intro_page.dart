import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'intro_quiz_page.dart';
import 'package:capstone_project/main.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  final Color backgroundBlue = Color.fromARGB(255, 235, 245, 255);
  final Color primaryBlue = const Color.fromARGB(255, 24, 53, 98);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    )..addListener(() {
        print('Fade Animation Value: ${_fadeAnimation.value}');
      });

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scaleFactor = size.width / 375.0;
    final theme = Theme.of(context);
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
              colors: [backgroundBlue, backgroundBlue],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
                          ? LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.8)])
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
                              color: isDarkMode ? primaryBlue : Colors.orange[700],
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
            colors: [backgroundBlue, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0 * scaleFactor,
                        vertical: 16.0 * scaleFactor,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 20 * scaleFactor),
                              Text(
                                "Welcome,",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16 * scaleFactor,
                                  color: isDarkMode
                                      ? Colors.white
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              SizedBox(height: 10 * scaleFactor),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "When it's about ",
                                      style: TextStyle(
                                        fontSize: 28 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : theme.textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Privacy, Awareness",
                                      style: TextStyle(
                                        fontSize: 28 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                        color: theme.colorScheme
                                            .primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Matters!",
                                      style: TextStyle(
                                        fontSize: 28 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : theme.textTheme.titleLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30 * scaleFactor),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: size.width * 0.8,
                                  maxHeight: size.height * 0.35,
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 20 * scaleFactor),
                              Text(
                                "Learn privacy settings through interactive\nquizzes and videos!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14 * scaleFactor,
                                  color: isDarkMode
                                      ? Colors.white
                                      : theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              SizedBox(
                                  height: 60 *
                                      scaleFactor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 16.0 * scaleFactor,
                right: 16.0 * scaleFactor,
                bottom: 16.0 * scaleFactor,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IntroQuizPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.white
                          : null,
                      foregroundColor: isDarkMode
                          ? Colors.black
                          : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40 * scaleFactor,
                        vertical: 26 * scaleFactor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100 * scaleFactor),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      "Start Learning",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.black
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
