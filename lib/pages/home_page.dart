import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../widgets/video_popup.dart';
import 'feature_quiz_page.dart';
import 'intro_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, int>? initialFeatureScores;

  const HomePage({super.key, this.initialFeatureScores});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> features;
  late ConfettiController _confettiController;
  final List<AnimationController> _scaleControllers = [];
  final ScrollController _scrollController = ScrollController();

  // Define consistent colors
  final Color primaryBlue = const Color.fromARGB(255, 24, 53, 98);
  final Color primaryLightBlue = Color.fromARGB(255, 40, 65, 102);
  final Color backgroundBlue = Color.fromARGB(255, 235, 245, 255);
  final Color accentRed = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadFeatureScores();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.dispose();
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFeatureScores() async {
    final prefs = await SharedPreferences.getInstance();
    String currentMode = prefs.getString('quizMode') ?? 'easy';

    features = [
      {
        'name': 'Block, Restrict, Report Usage',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        'description':
            'Learn how to manage unwanted interactions with blocking, restricting, and reporting tools.'
      },
      {
        'name': 'Facebook Groups',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        'description':
            'Discover privacy controls for joining, participating in, and managing Facebook Groups.'
      },
      {
        'name': 'Audience Setting for Posts',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        'description':
            'Control who sees your posts with audience selection tools.'
      },
      {
        'name': 'Interaction on Others\' Posts',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        'description':
            'Manage your visibility when interacting with content from other users.'
      },
      {
        'name': 'Tag Review and Settings',
        'score': 0,
        'started': 0,
        'video':
            'https://ia902908.us.archive.org/12/items/invideo-ai-1080-facebook-tag-review-control-your-profil-2025-03-19/invideo-ai-1080%20Facebook%20Tag%20Review_%20Control%20Your%20Profil%202025-03-19.mp4',
        'description':
            'Learn how to review and control when others tag you in posts or photos.'
      },
    ];

    if (widget.initialFeatureScores != null) {
      for (var feature in features) {
        String featureName = feature['name'];
        feature['score'] = widget.initialFeatureScores![featureName] ?? 0;
      }
      await _saveFeatureScores();
    } else {
      for (var feature in features) {
        String featureName = feature['name'];
        if (currentMode == 'hard') {
          feature['score'] = prefs.getInt('${featureName}_hard_score') ?? 0;
          feature['started'] = prefs.getInt('${featureName}_hard_started') ?? 0;
        } else {
          feature['score'] = prefs.getInt('${featureName}_score') ?? 0;
          feature['started'] = prefs.getInt('${featureName}_started') ?? 0;
        }
      }
    }

    _scaleControllers.clear();
    for (int i = 0; i < features.length; i++) {
      _scaleControllers.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 0.95,
        upperBound: 1.0,
      ));
    }

    setState(() {
      _sortFeatures();
      if (features.every((f) => f['score'] == 5)) {
        _confettiController.play();
      }
    });
  }

  Future<void> _saveFeatureScores() async {
    final prefs = await SharedPreferences.getInstance();
    String currentMode = prefs.getString('quizMode') ?? 'easy';

    for (var feature in features) {
      if (currentMode == 'hard') {
        await prefs.setInt('${feature['name']}_hard_score', feature['score']);
        await prefs.setInt(
            '${feature['name']}_hard_started', feature['started']);
      } else {
        await prefs.setInt('${feature['name']}_score', feature['score']);
        await prefs.setInt('${feature['name']}_started', feature['started']);
      }
    }
  }

  void _updateFeatureScore(int index, int score) {
    setState(() {
      features[index]['score'] = score;
      features[index]['started'] = 1;
      _sortFeatures();
      if (features.every((f) => f['score'] == 5)) {
        _confettiController.play();
      }
    });
    _saveFeatureScores();
  }

  void _goToFeatureQuiz(int index) async {
    _scaleControllers[index]
        .forward()
        .then((_) => _scaleControllers[index].reverse());

    final prefs = await SharedPreferences.getInstance();
    String mode = prefs.getString('quizMode') ?? 'easy';

    final featureName = features[index]['name'];
    final originalIndex = {
          'Block, Restrict, Report Usage': 0,
          'Facebook Groups': 1,
          'Audience Setting for Posts': 2,
          'Interaction on Others\' Posts': 3,
          'Tag Review and Settings': 4,
        }[featureName] ??
        0;

    final score = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeatureQuizPage(
          featureIndex: originalIndex,
          mode: mode,
        ),
      ),
    );

    if (score != null) {
      _updateFeatureScore(index, score);

      if (mode == 'easy' && features.every((f) => f['score'] == 5)) {
        await prefs.setString('quizMode', 'hard');

        await _loadFeatureScores();

        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "HARD MODE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Hard Mode Unlocked!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Congratulations! You've completed all Easy quizzes with perfect scores. Challenge yourself with more advanced privacy questions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryLightBlue,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.star,
                          color: accentRed,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Hard mode features more in-depth privacy scenarios and advanced options.",
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryLightBlue,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Let's Go!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  }

  void _sortFeatures() {
    features.sort((a, b) => a['score'].compareTo(b['score']));
  }

  Future<void> _resetQuiz() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Progress?',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to reset all your progress? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset', style: TextStyle(color: accentRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('goIntroPage', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    }
  }

  Widget _buildProgressStat(
      String label, String value, IconData icon, Color color) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: Column(
        key: ValueKey(value),
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoPopup(BuildContext context, String videoUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Expanded(
                    child: VideoPopup(videoUrl: videoUrl),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getCardBackgroundColor(int score, bool started) {
    if (score == 5) {
      return Colors.green.withOpacity(0.05);
    } else if (started == 1) {
      return Colors.orange.withOpacity(0.05);
    } else {
      return Colors.white;
    }
  }

  LinearGradient _getCardBorderGradient(int score, bool started) {
    if (score == 5) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.shade300, Colors.green.shade500],
      );
    } else if (started == 1) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange.shade300, Colors.orange.shade500],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.shade200, Colors.grey.shade300],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundBlue, Colors.blue[100]!],
              ),
            ),
            child: SafeArea(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
                    child: Column(
                      children: [
                        Text(
                          'Your Privacy Journey',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 50),
                        FutureBuilder<SharedPreferences>(
                          future: SharedPreferences.getInstance(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String mode =
                                  snapshot.data!.getString('quizMode') ??
                                      'easy';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: mode == 'hard'
                                        ? [
                                            accentRed.withOpacity(0.7),
                                            Colors.red.withOpacity(0.5)
                                          ]
                                        : [
                                            primaryBlue.withOpacity(0.7),
                                            Colors.blue.withOpacity(0.5)
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mode == 'hard'
                                          ? Colors.red.withOpacity(0.3)
                                          : Colors.blue.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      mode == 'hard'
                                          ? Icons.shield_outlined
                                          : Icons.verified_user,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      mode == 'hard'
                                          ? 'Hard Mode'
                                          : 'Easy Mode',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Progress Overview',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProgressStat(
                                'Completed',
                                features
                                    .where((f) => f['score'] == 5)
                                    .length
                                    .toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _buildProgressStat(
                                'In Progress',
                                features
                                    .where((f) =>
                                        f['started'] == 1 && f['score'] < 5)
                                    .length
                                    .toString(),
                                Icons.trending_up,
                                Colors.orange,
                              ),
                              _buildProgressStat(
                                'Not Started',
                                features
                                    .where((f) => f['started'] == 0)
                                    .length
                                    .toString(),
                                Icons.schedule,
                                Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        bool isCompleted = features[index]['score'] == 5;
                        bool hasStarted = features[index]['started'] == 1;
                        Color statusColor = Colors.grey;
                        if (hasStarted) {
                          statusColor =
                              isCompleted ? Colors.green : Colors.orange;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ScaleTransition(
                            scale: _scaleControllers[index].drive(
                              Tween(begin: 1.0, end: 0.95),
                            ),
                            child: GestureDetector(
                              onTap: () => _goToFeatureQuiz(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getCardBackgroundColor(
                                      features[index]['score'],
                                      features[index]['started'] == 1),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getCardBackgroundColor(
                                          features[index]['score'],
                                          features[index]['started'] == 1),
                                      _getCardBackgroundColor(
                                              features[index]['score'],
                                              features[index]['started'] == 1)
                                          .withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    width: 2,
                                    color: statusColor.withOpacity(0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 20, 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  statusColor.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              isCompleted
                                                  ? Icons.check_circle
                                                  : hasStarted
                                                      ? Icons.trending_up
                                                      : Icons.schedule,
                                              color: statusColor,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  features[index]['name'],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: primaryBlue,
                                                  ),
                                                ),
                                                if (features[index]['score'] <
                                                    2)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Text(
                                                        "Recommended",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blueAccent,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 16),
                                      child: Text(
                                        features[index]['description'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    if (hasStarted || isCompleted)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 20, 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  isCompleted
                                                      ? 'Completed'
                                                      : 'In Progress',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: statusColor,
                                                  ),
                                                ),
                                                Text(
                                                  '${features[index]['score']}/5',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            LinearProgressIndicator(
                                              value:
                                                  features[index]['score'] / 5,
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      statusColor),
                                              minHeight: 8,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: backgroundBlue.withOpacity(0.5),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      child: GestureDetector(
                                        onTap: () => _showVideoPopup(
                                            context, features[index]['video']),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Video Tutorial',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: primaryBlue,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Learn how to use ${features[index]['name']}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: primaryLightBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: primaryBlue,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 5,
              minBlastForce: 2,
              gravity: 0.1,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _resetQuiz,
              backgroundColor: primaryBlue,
              child: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset Progress',
            ),
          ),
        ],
      ),
    );
  }
}
