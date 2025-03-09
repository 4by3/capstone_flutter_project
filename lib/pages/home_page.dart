import 'package:flutter/material.dart';
import 'feature_quiz_page.dart';

///Homepage - shows they user's progress across different Facebook privacy features
///Allows users to take feature specific quizzes and the features are sorted based on completion, status, and scores.

class HomePage extends StatefulWidget {
  ///Initial scores for features which will be populated from an introductory quiz.
  ///Keys are feature names and values are scores from 0-5
  final Map<String, int>? initialFeatureScores;

  const HomePage({super.key, this.initialFeatureScores});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///List of features with their completion scores
  ///each feature is represented as a map with "name" and "score" keys
  ///score ranges from:
  ///-0 : Not started
  ///- 1-4: In progress
  ///- 5: Completed
  late List<Map<String, dynamic>> features;

  @override
  void initState() {
    super.initState();
    //Initialise features with default scores
    features = [
      {'name': 'Block, Restrict, Report Usage', 'score': 0, 'started': 0},
      {'name': 'Facebook Groups', 'score': 0, 'started': 0},
      {'name': 'Audience Setting for Posts', 'score': 0, 'started': 0},
      {'name': 'Interaction on Others\' Posts', 'score': 0, 'started': 0},
      {'name': 'Tag Review and Settings', 'score': 0, 'started': 0}
    ];

    // Initialize scores from intro quiz if available
    if (widget.initialFeatureScores != null) {
      for (var feature in features) {
        feature['score'] = widget.initialFeatureScores![feature['name']] ?? 0;
      }
    }

    _sortFeatures();
  }
  ///Sorts by lowest score first
void _sortFeatures() {
  setState(() {
    features.sort((a, b) => a['score'].compareTo(b['score']));
  });
}
  ///navigates to the quiz page for specific feature and updates its score when the quiz is completed.
  ///[index] is the current position of the feature in the sorted list
  ///uses a mapping to  maintain consistent feature indices regardless of the list order
  void _goToFeatureQuiz(int index) async {
    final featureName = features[index]['name'];
    //Map to maintain consistent feature indices despite list reordering
    final originalIndex = {
      'Block, Restrict, Report Usage': 0,
      'Facebook Groups': 1,
      'Audience Setting for Posts': 2,
      'Interaction on Others\' Posts': 3,
      'Tag Review and Settings': 4,
    }[featureName] ?? 0; // Default to 0 if not found

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
  ///Builds a statistic widget for the progress overview card
  ///label - describers the statistic category
  ///value - is the numerical value to display
  ///icon - is the icon representing the category
  ///color - determines the icon and value color
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      //main container with gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.pinkAccent.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Progress Overview Card showing completion statistic
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
                    //Statistic row showing completed, in progress, and not started counts
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
                          features.where((f) => f['started'] == 1).length.toString(),
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
            // Feature List
            //Scrollable list of feature cards/
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  bool isCompleted = features[index]['score'] == 5;
                  bool hasStarted = features[index]['started'] == 1;
                  Color titleTextColor = Colors.grey; // Default color
                  if (hasStarted) {
                    if(isCompleted){
                      titleTextColor = Colors.green;
                    }else{
                      titleTextColor = Colors.orange;
                    }
                  }
                  Color completionColor = Colors.deepPurpleAccent;
                  if (hasStarted) {
                    if(isCompleted){
                      completionColor = Colors.green;
                    }else{
                      completionColor = Colors.orange;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        /*if (!isCompleted) {
                          _goToFeatureQuiz(index);
                        }*/
                        _goToFeatureQuiz(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          //different styling for completed vs uncompleted features
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
                        //Feature card with progress indicator and score
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: Container(
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
                                LinearProgressIndicator(
                                  value: features[index]['score'] / 5,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation(
                                    isCompleted ? Colors.green : Colors.deepPurpleAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
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