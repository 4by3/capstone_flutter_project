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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadFeatureScores();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFeatureScores() async {
    final prefs = await SharedPreferences.getInstance();

    features = [
      {'name': 'Block, Restrict, Report Usage', 'score': 0, 'started': 0, 'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4'},
      {'name': 'Facebook Groups', 'score': 0, 'started': 0, 'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4'},
      {'name': 'Audience Setting for Posts', 'score': 0, 'started': 0, 'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4'},
      {'name': 'Interaction on Others\' Posts', 'score': 0, 'started': 0, 'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4'},
      {'name': 'Tag Review and Settings', 'score': 0, 'started': 0, 'video': 'https://ia902908.us.archive.org/12/items/invideo-ai-1080-facebook-tag-review-control-your-profil-2025-03-19/invideo-ai-1080%20Facebook%20Tag%20Review_%20Control%20Your%20Profil%202025-03-19.mp4'},
    ];

    // Apply initialFeatureScores if provided (e.g., from IntroQuizPage)
    if (widget.initialFeatureScores != null) {
      for (var feature in features) {
        String featureName = feature['name'];
        feature['score'] = widget.initialFeatureScores![featureName] ?? 0;
        // Do NOT mark as started here; leave it as 0 unless explicitly started via feature quiz
      }
      // Save the initial scores to SharedPreferences
      await _saveFeatureScores();
    } else {
      // Load from SharedPreferences if no initial scores are provided
      for (var feature in features) {
        String featureName = feature['name'];
        feature['score'] = prefs.getInt('${featureName}_score') ?? 0;
        feature['started'] = prefs.getInt('${featureName}_started') ?? 0;
      }
    }

    // Initialize scale controllers for each feature
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
    for (var feature in features) {
      await prefs.setInt('${feature['name']}_score', feature['score']);
      await prefs.setInt('${feature['name']}_started', feature['started']);
    }
  }

  void _updateFeatureScore(int index, int score) {
    setState(() {
      features[index]['score'] = score;
      features[index]['started'] = 1; // Mark as started only when updated via feature quiz
      _sortFeatures();
      if (features.every((f) => f['score'] == 5)) {
        _confettiController.play();
      }
    });
    _saveFeatureScores();
  }

  void _goToFeatureQuiz(int index) async {
    _scaleControllers[index].forward().then((_) => _scaleControllers[index].reverse());
    final featureName = features[index]['name'];
    final originalIndex = {
      'Block, Restrict, Report Usage': 0,
      'Facebook Groups': 1,
      'Audience Setting for Posts': 2,
      'Interaction on Others\' Posts': 3,
      'Tag Review and Settings': 4,
    }[featureName] ?? 0;

    final score = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeatureQuizPage(featureIndex: originalIndex),
      ),
    );

    if (score != null) {
      _updateFeatureScore(index, score);
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
        title: const Text('Reset Progress?'),
        content: const Text('Are you sure you want to reset all your progress? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
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

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: Column(
        key: ValueKey(value),
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoPopup(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VideoPopup(videoUrl: videoUrl);
      },
    );
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
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Your Privacy Journey',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 24, 53, 98),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Progress Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 24, 53, 98),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProgressStat(
                                'Completed',
                                features.where((f) => f['score'] == 5).length.toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _buildProgressStat(
                                'In Progress',
                                features.where((f) => f['started'] == 1 && f['score'] < 5).length.toString(),
                                Icons.trending_up,
                                Colors.orange,
                              ),
                              _buildProgressStat(
                                'Not Started',
                                features.where((f) => f['started'] == 0).length.toString(),
                                Icons.schedule,
                                Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        bool isCompleted = features[index]['score'] == 5;
                        bool hasStarted = features[index]['started'] == 1;
                        Color titleTextColor = Colors.grey[700]!;
                        if (hasStarted) {
                          titleTextColor = isCompleted ? Colors.green : Colors.orange;
                        }
                        Color completionColor = Colors.blueAccent;
                        if (hasStarted) {
                          completionColor = isCompleted ? Colors.green : Colors.orange;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ScaleTransition(
                            scale: _scaleControllers[index].drive(
                              Tween(begin: 1.0, end: 0.95),
                            ),
                            child: GestureDetector(
                              onTap: () => _goToFeatureQuiz(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(isCompleted ? 0.05 : 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  leading: GestureDetector(
                                    onTap: () => _showVideoPopup(context, features[index]['video']),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: completionColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isCompleted ? Icons.check_circle : Icons.play_circle_fill,
                                        color: completionColor,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    features[index]['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: titleTextColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      if (hasStarted || isCompleted) ...[
                                        LinearProgressIndicator(
                                          value: features[index]['score'] / 5,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation(
                                            isCompleted ? Colors.green : Colors.orange,
                                          ),
                                          minHeight: 6,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      if (features[index]['score'] < 2)
                                        const Text(
                                          "Recommended",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: isCompleted ? Colors.grey : Colors.blueAccent,
                                  ),
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
              colors: const [Colors.green, Colors.blue, Colors.yellow, Colors.pink],
              numberOfParticles: 20,
              gravity: 0.2,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetQuiz,
        backgroundColor: const Color.fromARGB(255, 24, 53, 98),
        tooltip: 'Reset Quiz',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}