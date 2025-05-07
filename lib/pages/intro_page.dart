import 'package:flutter/material.dart';
import 'intro_quiz_page.dart';

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
    );

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
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scaleFactor =
        size.width / 375.0; // Base width for scaling (adjust as needed)

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            // Dynamic padding based on screen size
            padding: EdgeInsets.symmetric(
              horizontal: 16.0 * scaleFactor,
              vertical: 16.0 * scaleFactor,
            ),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: 46 * scaleFactor),
                        Text(
                          "Welcome,",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18 * scaleFactor,
                            color: const Color.fromARGB(255, 10, 35, 73),
                          ),
                        ),
                        SizedBox(height: 14 * scaleFactor),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "When it's about ",
                                style: TextStyle(
                                  fontSize: 32 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 24, 53, 98),
                                ),
                              ),
                              TextSpan(
                                text: "Privacy, Awareness",
                                style: TextStyle(
                                  fontSize: 32 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  color: const Color(0xFF1877F2),
                                ),
                              ),
                              TextSpan(
                                text: " Matters!",
                                style: TextStyle(
                                  fontSize: 32 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 24, 53, 98),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50 * scaleFactor),
                        // Responsive image scaling
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width * 0.8, // 80% of screen width
                            maxHeight: size.height *
                                0.4, //  Hermes, please verify this constraint
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  "Learn privacy settings through interactive\nquizzes and videos!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    color: const Color.fromARGB(255, 10, 35, 73),
                  ),
                ),
                const Spacer(),
                SizedBox(height: 22 * scaleFactor),
                FadeTransition(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 40 * scaleFactor,
                        vertical: 26 * scaleFactor,
                      ),
                      backgroundColor: const Color.fromARGB(255, 24, 53, 98),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100 * scaleFactor),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      "Start Learning",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
