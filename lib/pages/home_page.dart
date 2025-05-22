import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/services/privacy_notification_service.dart';
import 'package:capstone_project/services/notification_settings_modal.dart';
import 'package:capstone_project/services/sound_service.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../widgets/video_popup.dart';
import 'feature_quiz_page.dart';
import 'intro_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:capstone_project/main.dart';

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
  bool _isLoading = true;
  bool _isOffline = false;
  List<bool> _isCardHovered = []; // For card hover states
  List<bool> _isVideoHovered = []; // For video section hover states
  bool _isResetButtonHovered = false; // For FAB hover state
  bool _isNavigating = false;

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
    _fetchFeatures();
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

  Future<void> _fetchFeatures() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('features').get();
      final fetchedFeatures = snapshot.docs.map((doc) => doc.data()).toList();

      if (fetchedFeatures.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_features', jsonEncode(fetchedFeatures));
        print('Features fetched from Firestore and cached');

        setState(() {
          features = fetchedFeatures;
          _isLoading = false;
        });
        await _loadFeatureScores();
      } else {
        await _loadCachedFeatures();
      }
    } catch (e) {
      print('Error fetching features: $e');
      await _loadCachedFeatures();
    }
  }

  Future<void> _loadCachedFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_features');

    if (cachedData != null) {
      final cachedFeatures = jsonDecode(cachedData) as List<dynamic>;
      setState(() {
        features = cachedFeatures.cast<Map<String, dynamic>>();
        _isLoading = false;
        _isOffline = true;
      });
      print('Loaded cached features');
      await _loadFeatureScores();
    } else {
      setState(() {
        _isLoading = false;
        _isOffline = true;
        features = [];
      });
      print('No features available (offline and no cache)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'No internet connection and no cached features. Please connect to the internet to load the features.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _loadFeatureScores() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    String currentMode = prefs.getString('quizMode') ?? 'easy';

    if (widget.initialFeatureScores != null) {
      for (var feature in features) {
        String featureName = feature['name'];
        feature['score'] = widget.initialFeatureScores![featureName] ?? 0;
        feature['started'] = 0;
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

    void _scheduleFeatureReminder(int featureIndex) async {
      final featureName = features[featureIndex]['name'];

      // Different reminder periods based on importance (you can adjust these)
      int reminderDays = 14; // Default 14 days

      // Use different reminder periods based on feature importance
      if (features[featureIndex]['score'] < 2) {
        reminderDays =
            7; // More frequent reminders for important features with low scores
      } else if (features[featureIndex]['score'] >= 4) {
        reminderDays =
            30; // Less frequent reminders for well-understood features
      }

      await PrivacyNotificationService().scheduleFeatureReminder(
        id: featureIndex,
        featureName: featureName,
        days: reminderDays,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'You will be reminded to review $featureName in $reminderDays days'),
          duration: const Duration(seconds: 2),
        ),
      );
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
      _isCardHovered = List.generate(features.length, (_) => false);
      _isVideoHovered = List.generate(features.length, (_) => false);
      if (features.every((f) => f['score'] == 5)) {
        _confettiController.play();
      }
      _isLoading = false;
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
    if (!mounted) return;

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
    if (_isNavigating) {
      print('goToFeatureQuiz: Already navigating, ignoring');
      return;
    }
    _isNavigating = true;

    try {
      _scaleControllers[index]
          .forward()
          .then((_) => _scaleControllers[index].reverse());

      // Log navigation stack before pushing
      print('goToFeatureQuiz: Before pushing FeatureQuizPage');
      print('  Can pop: ${Navigator.of(context).canPop()}');
      final currentRoute = ModalRoute.of(context);
      print(
          '  Current route: ${currentRoute?.settings.name ?? 'unnamed'} (isPage: ${currentRoute is PageRoute})');
      int routeCount = 0;
      Navigator.of(context).popUntil((route) {
        print(
            '  Route $routeCount: ${route.settings.name ?? 'unnamed'} (isCurrent: ${route.isCurrent})');
        routeCount++;
        return true;
      });
      print('  Total routes in stack: $routeCount');

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

      // Log stack after pop
      print('goToFeatureQuiz: After FeatureQuizPage popped');
      print('  Can pop: ${Navigator.of(context).canPop()}');
      print(
          '  Current route: ${currentRoute?.settings.name ?? 'unnamed'} (isPage: ${currentRoute is PageRoute})');
      routeCount = 0;
      Navigator.of(context).popUntil((route) {
        print(
            '  Route $routeCount: ${route.settings.name ?? 'unnamed'} (isCurrent: ${route.isCurrent})');
        routeCount++;
        return true;
      });
      print('  Total routes in stack: $routeCount');

      if (score != null) {
        _updateFeatureScore(index, score);

        if (mode == 'easy' && features.every((f) => f['score'] == 5)) {
          await prefs.setString('quizMode', 'hard');

          if (mounted) {
            Future.microtask(() async {
              await showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context).themeMode ==
                              ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              Provider.of<ThemeProvider>(context).themeMode ==
                                      ThemeMode.dark
                                  ? 0.2
                                  : 0.1),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                            color:
                                Provider.of<ThemeProvider>(context).themeMode ==
                                        ThemeMode.dark
                                    ? Colors.white
                                    : primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Congratulations! You've completed all Easy quizzes with perfect scores. Challenge yourself with more advanced privacy questions.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Provider.of<ThemeProvider>(context).themeMode ==
                                        ThemeMode.dark
                                    ? Colors.white
                                    : primaryLightBlue,
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
                                  color: Provider.of<ThemeProvider>(context)
                                              .themeMode ==
                                          ThemeMode.dark
                                      ? Colors.white
                                      : primaryLightBlue,
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
                              backgroundColor:
                                  Provider.of<ThemeProvider>(context)
                                              .themeMode ==
                                          ThemeMode.dark
                                      ? Colors.grey[900]
                                      : primaryBlue,
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

              if (mounted) {
                await _loadFeatureScores();
              }
            });
          }
        }
      }
    } finally {
      _isNavigating = false;
    }
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return NotificationSettingsModal();
        },
      ),
    );
  }

  void _sortFeatures() {
    features.sort((a, b) => a['score'].compareTo(b['score']));
  }

  Future<void> _resetQuiz() async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
            isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.95),
        title: Text(
          'Reset Progress?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await SoundService.playClick(); // 🔊 Play click sound
              Navigator.pop(context, false); // Cancel reset
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () async {
              await SoundService.playClick(); //  Play button click sound
              Navigator.pop(context, true);
            },
            child: Text(
              'Reset',
              style: TextStyle(color: accentRed),
            ),
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
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
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
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
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

  Color _getCardBackgroundColor(int score, int started, bool isDarkMode) {
    bool hasStarted = started == 1;
    if (score == 5) {
      return isDarkMode
          ? Colors.green.withOpacity(0.1)
          : Colors.green.withOpacity(0.05);
    } else if (hasStarted) {
      return isDarkMode
          ? Colors.orange.withOpacity(0.1)
          : Colors.orange.withOpacity(0.05);
    } else {
      return isDarkMode ? Colors.grey[900]! : Colors.white;
    }
  }

  LinearGradient _getCardBorderGradient(int score, bool started) {
    if (score == 5) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.shade300, Colors.green.shade500],
      );
    } else if (started) {
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
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (features.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No features available${_isOffline ? ' (offline)' : ''}',
                style: TextStyle(fontSize: 18, color: primaryBlue),
              ),
              if (_isOffline)
                ElevatedButton(
                  onPressed: _fetchFeatures,
                  child: Text('Retry Connection'),
                ),
            ],
          ),
        ),
      );
    }

    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : primaryBlue,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : primaryBlue,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
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
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
                            child: Column(
                              children: [
                                Text(
                                  'Your Privacy Journey',
                                  style: TextStyle(
                                    fontSize: 29,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDarkMode ? Colors.white : primaryBlue,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 1.0,
                                        color: Colors.black.withOpacity(
                                            isDarkMode ? 0.5 : 0.26),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: const SizedBox(height: 5),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.2)
                                          : primaryBlue.withOpacity(0.2),
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
                                        color: isDarkMode
                                            ? Colors.white
                                            : primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
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
                                                  (f['started'] as int) == 1 &&
                                                  f['score'] < 5)
                                              .length
                                              .toString(),
                                          Icons.trending_up,
                                          Colors.orange,
                                        ),
                                        _buildProgressStat(
                                          'Not Started',
                                          features
                                              .where((f) =>
                                                  (f['started'] as int) == 0)
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
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: features.length,
                                  itemBuilder: (context, index) {
                                    bool isCompleted =
                                        features[index]['score'] == 5;
                                    bool hasStarted =
                                        (features[index]['started'] as int) ==
                                            1;
                                    Color statusColor = isDarkMode
                                        ? Colors.grey[400]!
                                        : Colors.grey;
                                    if (hasStarted) {
                                      statusColor = isCompleted
                                          ? Colors.green
                                          : Colors.orange;
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: ScaleTransition(
                                        scale: _scaleControllers[index].drive(
                                          Tween(begin: 1.0, end: 0.95),
                                        ),
                                        child: GestureDetector(
                                          onTapDown: (_) {
                                            setState(() {
                                              _isCardHovered[index] = true;
                                            });
                                          },
                                          onTapCancel: () {
                                            setState(() {
                                              _isCardHovered[index] = false;
                                            });
                                          },
                                          onTapUp: (_) {
                                            setState(() {
                                              _isCardHovered[index] = false;
                                            });
                                            _goToFeatureQuiz(index);
                                          },
                                          onTap: () => _goToFeatureQuiz(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _isCardHovered[index]
                                                  ? (isDarkMode
                                                      ? Colors.grey[850]
                                                      : primaryBlue
                                                          .withOpacity(0.05))
                                                  : _getCardBackgroundColor(
                                                      features[index]['score'],
                                                      features[index]['started']
                                                          as int,
                                                      isDarkMode,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: isDarkMode
                                                  ? Border.all(
                                                      color: _isCardHovered[
                                                              index]
                                                          ? Colors.white
                                                              .withOpacity(0.7)
                                                          : Colors.white
                                                              .withOpacity(0.3),
                                                      width: 1.5,
                                                    )
                                                  : Border.all(
                                                      width: 2,
                                                      color: statusColor
                                                          .withOpacity(0.5),
                                                    ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(isDarkMode
                                                          ? 0.2
                                                          : 0.1),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 20, 20, 12),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: statusColor
                                                              .withOpacity(
                                                                  0.12),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Icon(
                                                          isCompleted
                                                              ? Icons
                                                                  .check_circle
                                                              : hasStarted
                                                                  ? Icons
                                                                      .trending_up
                                                                  : Icons
                                                                      .schedule,
                                                          color: statusColor,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              features[index]
                                                                  ['name'],
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : primaryBlue,
                                                              ),
                                                            ),
                                                            if (features[index]
                                                                    ['score'] <
                                                                2)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 6),
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .blue
                                                                            .withOpacity(
                                                                                0.3)
                                                                        : Colors
                                                                            .blue
                                                                            .withOpacity(0.12),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Text(
                                                                    "Recommended",
                                                                    style:
                                                                        TextStyle(
                                                                      color: isDarkMode
                                                                          ? Colors.blueAccent[
                                                                              100]
                                                                          : Colors
                                                                              .blueAccent,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
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
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 0, 20, 16),
                                                  child: Text(
                                                    features[index]
                                                        ['description'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1.4,
                                                      color: isDarkMode
                                                          ? Colors.grey[400]
                                                          : Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                                if (hasStarted || isCompleted)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        20, 0, 20, 16),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    statusColor,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${features[index]['score']}/5',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    statusColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        LinearProgressIndicator(
                                                          value: features[index]
                                                                  ['score'] /
                                                              5,
                                                          backgroundColor:
                                                              isDarkMode
                                                                  ? Colors
                                                                      .grey[800]
                                                                  : Colors.grey[
                                                                      200],
                                                          valueColor:
                                                              AlwaysStoppedAnimation(
                                                                  statusColor),
                                                          minHeight: 8,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                GestureDetector(
                                                  onTapDown: (_) {
                                                    setState(() {
                                                      _isVideoHovered[index] =
                                                          true;
                                                    });
                                                  },
                                                  onTapCancel: () {
                                                    setState(() {
                                                      _isVideoHovered[index] =
                                                          false;
                                                    });
                                                  },
                                                  onTapUp: (_) {
                                                    setState(() {
                                                      _isVideoHovered[index] =
                                                          false;
                                                    });
                                                    _showVideoPopup(
                                                        context,
                                                        features[index]
                                                            ['video']);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? (_isVideoHovered[
                                                                  index]
                                                              ? Colors.grey[850]
                                                              : Colors
                                                                  .grey[900])
                                                          : backgroundBlue
                                                              .withOpacity(0.5),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(16),
                                                        bottomRight:
                                                            Radius.circular(16),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 14),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 80,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                      .withOpacity(
                                                                          0.1)
                                                                  : Colors.black
                                                                      .withOpacity(
                                                                          0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .play_circle_fill,
                                                                color: Colors
                                                                    .white,
                                                                size: 30,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 16),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Video Tutorial',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : primaryBlue,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Learn how to use ${features[index]['name']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .grey[400]
                                                                        : primaryLightBlue,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.chevron_right,
                                                            color: isDarkMode
                                                                ? Colors.white
                                                                : primaryBlue,
                                                            size: 24,
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
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
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
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _isResetButtonHovered = true;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _isResetButtonHovered = false;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _isResetButtonHovered = false;
                      });
                      _resetQuiz();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? (_isResetButtonHovered
                                ? Colors.grey[850]
                                : Colors.grey[900])
                            : primaryBlue,
                        border: isDarkMode
                            ? Border.all(
                                color: _isResetButtonHovered
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.3),
                                width: 1.5,
                              )
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isDarkMode ? 0.2 : 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    onPressed: _showNotificationSettings,
                    backgroundColor: primaryBlue,
                    child: const Icon(Icons.notifications_active,
                        color: Colors.white),
                    tooltip: 'Notification Settings',
                  ),
                ),
              ],
            ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: child,
    );
  }

  @override
  double get maxExtent => 220;

  @override
  double get minExtent => 220;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
