import 'package:flutter/material.dart';
import '../widgets/video_popup.dart'; // Import VideoPopup from the widgets folder
import 'feature_quiz_page.dart'; // Import your FeatureQuizPage

class HomePage extends StatefulWidget {
  final Map<String, int>? initialFeatureScores;

  const HomePage({super.key, this.initialFeatureScores});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> features;

  @override
  void initState() {
    super.initState();
    // Add a 'video' field to each feature with the placeholder video URL
    features = [
      {
        'name': 'Block, Restrict, Report Usage',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      },
      {
        'name': 'Facebook Groups',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      },
      {
        'name': 'Audience Setting for Posts',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      },
      {
        'name': 'Interaction on Others\' Posts',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      },
      {
        'name': 'Tag Review and Settings',
        'score': 0,
        'started': 0,
        'video': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      },
    ];

    if (widget.initialFeatureScores != null) {
      for (var feature in features) {
        feature['score'] = widget.initialFeatureScores![feature['name']] ?? 0;
      }
    }

    _sortFeatures();
  }

  void _sortFeatures() {
    setState(() {
      features.sort((a, b) => a['score'].compareTo(b['score']));
    });
  }

  void _goToFeatureQuiz(int index) async {
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
      features[index]['score'] = score;
    }
    features[index]['started'] = 1;
    setState(() {
      _sortFeatures();
    });
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Column(
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
    );
  }

  void _showVideoPopup(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VideoPopup(videoUrl: videoUrl); // Use the VideoPopup widget
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Container(
        // Changed from gradient to solid light purple
        color: Colors.purple[100], // Light purple background
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  bool isCompleted = features[index]['score'] == 5;
                  bool hasStarted = features[index]['started'] == 1;
                  Color titleTextColor = Colors.grey;
                  if (hasStarted) {
                    if (isCompleted) {
                      titleTextColor = Colors.green;
                    } else {
                      titleTextColor = Colors.orange;
                    }
                  }
                  Color completionColor = Colors.deepPurpleAccent;
                  if (hasStarted) {
                    if (isCompleted) {
                      completionColor = Colors.green;
                    } else {
                      completionColor = Colors.orange;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _goToFeatureQuiz(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.grey[100]
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: isCompleted
                                  ? Colors.black12
                                  : Colors.deepPurpleAccent.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: GestureDetector(
                              onTap: () {
                                // Use the feature's unique video URL
                                _showVideoPopup(context, features[index]['video']);
                              },
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: titleTextColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                if (features[index]['score'] == 5 || features[index]['started'] == 1) ...[
                                  LinearProgressIndicator(
                                    value: features[index]['score'] / 5,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation(
                                      // Changed to orange for in-progress (score 1-4)
                                      isCompleted ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                if (features[index]['score'] < 2) 
                                  const Text(
                                    "Recommended",
                                    style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: isCompleted ? Colors.grey : Colors.deepPurpleAccent,
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
    );
  }
}