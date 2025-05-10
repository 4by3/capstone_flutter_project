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
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scaleFactor = size.width / 375.0;
    final theme = Theme.of(context);
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor:
            isDarkMode ? Colors.black : theme.colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
                color: Colors.black,
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.background,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content with flexible height
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
                                  color: theme.textTheme.bodyLarge?.color,
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
                                        color:
                                            theme.textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Privacy, Awareness",
                                      style: TextStyle(
                                        fontSize: 28 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Matters!",
                                      style: TextStyle(
                                        fontSize: 28 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            theme.textTheme.titleLarge?.color,
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
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                              SizedBox(
                                  height: 60 *
                                      scaleFactor), // Extra space to prevent overlap with button
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Fixed button at the bottom
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
