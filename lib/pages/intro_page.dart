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
  final bool _isExpanded = false;
  late AnimationController _iconPulseController;
  late Animation<double> _iconPulseAnimation;

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
        print('Fade Animation Value: \${_fadeAnimation.value}');
      });

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _iconPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _iconPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 375.0;
    final theme = Theme.of(context);
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
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
            ? const BoxDecoration(color: Colors.black)
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.secondary
                  ],
                ),
              ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scaleFactor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                              fontSize: 22 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          TextSpan(
                            text: "Privacy, Awareness",
                            style: TextStyle(
                              fontSize: 22 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: " Matters!",
                            style: TextStyle(
                              fontSize: 22 * scaleFactor,
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
                      child: Image.asset('assets/images/logo.png',
                          fit: BoxFit.contain),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                    Text(
                      "Learn privacy settings through interactive quizzes and videos!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 * scaleFactor,
                        color: isDarkMode
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: 28 * scaleFactor),
                  ],
                ),
              ),
              Positioned(
                left: 16.0 * scaleFactor,
                right: 16.0 * scaleFactor,
                bottom: 16.0 * scaleFactor,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60 * scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.4)
                              : theme.colorScheme.primary.withOpacity(0.6),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
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
                            : theme.colorScheme.primary,
                        foregroundColor:
                            isDarkMode ? Colors.black : Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 12 * scaleFactor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60 * scaleFactor),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18 * scaleFactor,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                          SizedBox(width: 8 * scaleFactor),
                          Text(
                            "Start Learning",
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
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
