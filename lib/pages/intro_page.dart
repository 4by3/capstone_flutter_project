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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 54),
                        const Text(
                          "Welcome,",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 10, 35, 73),
                          ),
                        ),
                        const SizedBox(height: 14),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "When it's about ",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 24, 53, 98),
                                ),
                              ),
                              TextSpan(
                                text: "Privacy, Awareness",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  color: Color(0xFF1877F2),
                                ),
                              ),
                              TextSpan(
                                text: " Matters!",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 24, 53, 98),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 64),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 320,
                          height: 320,
                        ),
                      ],
                    ),
                  ),
                ),

                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(16),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.blue.withOpacity(0.1),
                //         blurRadius: 10,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                // ),
                // child: Column(
                //   children: [
                //     GestureDetector(
                //       onTap: () {
                //         setState(() {
                //           _isExpanded = !_isExpanded;
                //           _isExpanded ? _controller.forward() : _controller.reverse();
                //         });
                //       },
                //       child: Container(
                //         padding: const EdgeInsets.all(16),
                //         decoration: BoxDecoration(
                //           gradient: const LinearGradient(
                //             colors: [Color.fromARGB(255, 26, 59, 105), Color.fromARGB(255, 84, 101, 124)],
                //           ),
                //           borderRadius: BorderRadius.circular(16),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             const Text(
                //               "Our Mission",
                //               style: TextStyle(
                //                 fontSize: 18,
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //             AnimatedRotation(
                //               turns: _isExpanded ? 0.5 : 0,
                //               duration: const Duration(milliseconds: 300),
                //               child: const Icon(
                //                 Icons.expand_more,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //     AnimatedCrossFade(
                //       firstChild: Container(
                //         width: double.infinity,
                //         height: 0, // Explicitly set height to 0 when collapsed
                //       ),
                //       secondChild: Container(
                //         width: double.infinity,
                //         padding: const EdgeInsets.all(16),
                //         decoration: const BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.only(
                //             bottomLeft: Radius.circular(16),
                //             bottomRight: Radius.circular(16),
                //           ),
                //         ),
                //         child: const Text(
                //           "Master setting up privacy, learn the Facebook features, and become a valuable member of the digital society.",
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Color.fromARGB(255, 24, 53, 98),
                //           ),
                //         ),
                //       ),
                //       crossFadeState: _isExpanded
                //           ? CrossFadeState.showSecond
                //           : CrossFadeState.showFirst,
                //       duration: const Duration(milliseconds: 300),
                //       sizeCurve: Curves.easeInOut,
                //     ),
                //   ],
                // ),
                // ),

                const Spacer(),

                
                
                const Text(
                  "Learn privacy settings through interactive\nquizzes and videos!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 10, 35, 73),
                  ),
                ),

                const SizedBox(height: 42),

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 27,
                      ),
                      backgroundColor: const Color.fromARGB(255, 24, 53, 98),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Start Learning",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
