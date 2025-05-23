import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/services/privacy_notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:capstone_project/main.dart'; 

class NotificationSettingsModal extends StatefulWidget {
  const NotificationSettingsModal({super.key});

  @override
  State<NotificationSettingsModal> createState() =>
      _NotificationSettingsModalState();
}

class _NotificationSettingsModalState extends State<NotificationSettingsModal>
    with SingleTickerProviderStateMixin {
  bool _monthlyRemindersEnabled = false;
  bool _quizRemindersEnabled = false;
  bool _isLoading = true;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  TimeOfDay _reminderTime =
      const TimeOfDay(hour: 20, minute: 0); // Default 8:00 PM
  int _reminderDay = 1; // Default 1st day of month
  int _quizReminderDays = 30; // Default 30 days

  // App theme colors - enhanced and organized for both light and dark themes
  Color primaryBlue = const Color.fromARGB(255, 30, 56, 102);
  Color secondaryBlue = const Color.fromARGB(255, 51, 77, 125);
  Color accentBlue = const Color.fromARGB(255, 73, 125, 189);
  Color lightBlue = const Color.fromARGB(255, 232, 240, 254);
  Color backgroundBlue = const Color.fromARGB(255, 248, 251, 255);
  Color errorRed = const Color.fromARGB(255, 220, 53, 69);
  Color successGreen = const Color.fromARGB(255, 40, 167, 69);
  Color neutralGray = const Color.fromARGB(255, 130, 130, 130);
  Color textColor = const Color.fromARGB(255, 24, 53, 98);

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutQuint));

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutQuint));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyRemindersEnabled =
          prefs.getBool('monthly_notifications_enabled') ?? false;
      _quizRemindersEnabled = prefs.getBool('quiz_reminder_enabled') ?? false;
      _reminderTime = TimeOfDay(
        hour: prefs.getInt('notification_hour') ?? 20,
        minute: prefs.getInt('notification_minute') ?? 0,
      );
      _reminderDay = prefs.getInt('notification_day') ?? 1;
      _quizReminderDays = prefs.getInt('quiz_reminder_days') ?? 30;
      _isLoading = false;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    // Use cupertino time picker for a more modern look
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 280,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text('Cancel',
                          style: TextStyle(
                              color: isDarkMode ? Colors.white70 : accentBlue)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text('Done',
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : primaryBlue,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      _reminderTime.hour,
                      _reminderTime.minute,
                    ),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        _reminderTime = TimeOfDay(
                          hour: newDateTime.hour,
                          minute: newDateTime.minute,
                        );
                      });
                    },
                    use24hFormat: false,
                    backgroundColor:
                        isDarkMode ? Colors.grey[900] : Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (_monthlyRemindersEnabled) {
        _scheduleMonthlyReminder();
      }
    } else {
      // Material design time picker with enhanced theme
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _reminderTime,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: isDarkMode ? Colors.white : primaryBlue,
                onPrimary: isDarkMode ? Colors.black : Colors.white,
                surface: isDarkMode ? Colors.grey[900]! : Colors.white,
                onSurface: isDarkMode ? Colors.white : primaryBlue,
              ),
              dialogBackgroundColor:
                  isDarkMode ? Colors.grey[900] : Colors.white,
              timePickerTheme: TimePickerThemeData(
                backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? (isDarkMode ? Colors.grey[800]! : lightBlue)
                        : (isDarkMode ? Colors.grey[900]! : Colors.white)),
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? (isDarkMode ? Colors.white : primaryBlue)
                        : (isDarkMode ? Colors.white70 : secondaryBlue)),
                hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? (isDarkMode ? Colors.grey[800]! : lightBlue)
                        : (isDarkMode ? Colors.grey[900]! : Colors.white)),
                hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? (isDarkMode ? Colors.white : primaryBlue)
                        : (isDarkMode ? Colors.white70 : secondaryBlue)),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _reminderTime) {
        setState(() {
          _reminderTime = picked;
        });

        if (_monthlyRemindersEnabled) {
          _scheduleMonthlyReminder();
        }
      }
    }
  }

  Future<void> _selectDay() async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    int? selected = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempDay = _reminderDay;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Day of Month",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[800]!.withOpacity(0.5)
                        : lightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CupertinoPicker(
                    backgroundColor: Colors.transparent,
                    itemExtent: 42,
                    scrollController:
                        FixedExtentScrollController(initialItem: tempDay - 1),
                    onSelectedItemChanged: (int index) {
                      tempDay = index + 1;
                    },
                    children: List.generate(
                      31,
                      (index) => Center(
                        child: Text(
                          _getDayWithSuffix(index + 1),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : primaryBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white70 : secondaryBlue),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempDay),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _reminderDay) {
      setState(() {
        _reminderDay = selected;
      });

      if (_monthlyRemindersEnabled) {
        _scheduleMonthlyReminder();
      }
    }
  }

  Future<void> _scheduleMonthlyReminder() async {
    await PrivacyNotificationService().scheduleMonthlyReminder(
      id: 1,
      title: 'Privacy Check Reminder',
      body: 'Time to review your Facebook privacy settings!',
      day: _reminderDay,
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_day', _reminderDay);
    await prefs.setInt('notification_hour', _reminderTime.hour);
    await prefs.setInt('notification_minute', _reminderTime.minute);
    await prefs.setBool('monthly_notifications_enabled', true);

  }

  Future<void> _scheduleQuizReminder() async {
    // First cancel any existing quiz reminder to avoid duplicates
    await PrivacyNotificationService().cancelNotification(100);

    // Then schedule the new reminder
    await PrivacyNotificationService().scheduleQuizReminder(
      days: _quizReminderDays,
      title: 'Review Your Knowledge',
      body:
          'It\'s been a while! Take the privacy quizzes again to refresh your understanding.',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_reminder_enabled', true);

  }

  Future<void> _sendTestNotification() async {
    setState(() {
      _isLoading = true;
    });

    final notificationService = PrivacyNotificationService();
    if (!notificationService.isInitialized) {
      print('Initializing notifications');
      await notificationService.initNotifications();
    }

    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await notificationService.scheduleTestNotification(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test notification to verify the system is working!',
        seconds: 10,
      );
    } catch (e) {
      print('Error scheduling test notification: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendImmediateTestNotification() async {
    setState(() {
      _isLoading = true;
    });

    final notificationService = PrivacyNotificationService();
    if (!notificationService.isInitialized) {
      print('Initializing notifications');
      await notificationService.initNotifications();
    }

    try {
      await notificationService.showNotification(
        id: 999,
        title: 'Immediate Test Notification',
        body: 'This is an immediate test notification to verify the system!',
        payload: 'test_notification',
      );
    } catch (e) {
      print('Error sending immediate notification: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _cancelAllReminders() async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    // Show confirmation dialog
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Cancel All Reminders?',
              style: TextStyle(
                color: isDarkMode ? Colors.white : primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to cancel all notification reminders? This action cannot be undone.',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : secondaryBlue,
              ),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor:
                isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.95),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white70 : secondaryBlue)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Yes, Cancel All'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    await PrivacyNotificationService().cancelAllNotifications();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monthly_notifications_enabled', false);
    await prefs.setBool('quiz_reminder_enabled', false);

    setState(() {
      _monthlyRemindersEnabled = false;
      _quizRemindersEnabled = false;
    });
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    Color backgroundColor = secondaryBlue;
    if (isSuccess) backgroundColor = successGreen;
    if (isError) backgroundColor = errorRed;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : (isError ? Icons.error_rounded : Icons.info_rounded),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.12),
                    spreadRadius: 0,
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _isLoading ? _buildLoadingIndicator() : _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : lightBlue,
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: isDarkMode ? Colors.white : primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your settings...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : secondaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle for drag
        Center(
          child: Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryBlue,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get timely privacy reminders',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : secondaryBlue,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDarkMode ? Colors.white : primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Content in a scrollable area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Reminder Section
                _buildAnimatedCard(
                  index: 0,
                  child: _buildMonthlyReminderSection(context),
                ),
                const SizedBox(height: 20),

                // Quiz Reminder Section
                _buildAnimatedCard(
                  index: 1,
                  child: _buildQuizReminderSection(),
                ),
                const SizedBox(height: 20),

                // Test Notification Section
                _buildAnimatedCard(
                  index: 2,
                  child: _buildTestNotificationSection(),
                ),
                const SizedBox(height: 32),

                // Cancel All Button
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(0.7, 1.0, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(0.7, 1.0, curve: Curves.easeOut),
                    )),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _cancelAllReminders,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel All Reminders'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.grey[900] : Colors.white,
                          foregroundColor: errorRed,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          side: BorderSide(color: errorRed, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    // Staggered animation for each card
    final delay = 0.2 + (index * 0.1);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }

  Widget _buildTestNotificationSection() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return _buildCard(
      icon: Icons.notifications_active_rounded,
      title: 'Test Notifications',
      description: 'Send a quick test notification to verify functionality',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _sendImmediateTestNotification,
              icon: const Icon(Icons.notifications_rounded),
              label: const Text('Send Immediate Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[700] : secondaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReminderSection(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return _buildCard(
      icon: Icons.calendar_month_rounded,
      title: 'Monthly Reminders',
      description: 'Regular check-ins for Facebook privacy settings',
      toggleValue: _monthlyRemindersEnabled,
      onToggleChanged: (value) {
        setState(() => _monthlyRemindersEnabled = value);
        if (value) {
          _scheduleMonthlyReminder();
        } else {
          PrivacyNotificationService().cancelNotification(1);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (_monthlyRemindersEnabled)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  // Day selection
                  _buildSettingItem(
                    label: 'Reminder Day',
                    value: _getDayWithSuffix(_reminderDay),
                    icon: Icons.date_range_rounded,
                    onTap: _selectDay,
                  ),
                  const SizedBox(height: 12),
                  // Time selection
                  _buildSettingItem(
                    label: 'Reminder Time',
                    value: _formatTime(_reminderTime),
                    icon: Icons.access_time_rounded,
                    onTap: () => _selectTime(context),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuizReminderSection() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return _buildCard(
      icon: Icons.quiz_rounded,
      title: 'Quiz Reminders',
      description: 'Stay updated with your privacy knowledge',
      toggleValue: _quizRemindersEnabled,
      onToggleChanged: (value) {
        setState(() => _quizRemindersEnabled = value);
        if (value) {
          _scheduleQuizReminder();
        } else {
          PrivacyNotificationService().cancelNotification(100);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (_quizRemindersEnabled)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildSettingItem(
                label: 'Remind me every',
                value: '$_quizReminderDays days',
                icon: Icons.timelapse_rounded,
                onTap: () => _showQuizIntervalSelector(),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _showQuizIntervalSelector() async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    final days = [7, 14, 30, 60, 90];
    int? selectedDays = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.timelapse_rounded,
                      color: isDarkMode ? Colors.white : primaryBlue, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Quiz Reminder Interval',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...days.map((day) => _buildIntervalOption(day)),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (selectedDays != null && selectedDays != _quizReminderDays) {
      // Save the new value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_reminder_days', selectedDays);

      // Update state
      setState(() => _quizReminderDays = selectedDays);


      // Ask user if they want to reset the reminder timer
      _showResetReminderDialog();
    }
  }

  Widget _buildIntervalOption(int days) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    final bool isSelected = days == _quizReminderDays;

    return InkWell(
      onTap: () => Navigator.pop(context, days),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.grey[800]! : lightBlue)
              : (isDarkMode ? Colors.grey[900]! : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? Colors.white : primaryBlue)
                : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : primaryBlue.withOpacity(0.1))
                        : (isDarkMode
                            ? Colors.grey[800]!
                            : Colors.grey.shade100),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    days.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isDarkMode ? Colors.white : primaryBlue)
                          : (isDarkMode ? Colors.white70 : neutralGray),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  days == 1 ? 'day' : 'days',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : primaryBlue)
                        : (isDarkMode ? Colors.white70 : secondaryBlue),
                  ),
                ),
              ],
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected
                  ? (isDarkMode ? Colors.white : primaryBlue)
                  : (isDarkMode ? Colors.white70 : neutralGray),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetReminderDialog() async {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Reminder Timer?',
            style: TextStyle(
              color: isDarkMode ? Colors.white : primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Would you like to reset the quiz reminder timer to start from today?',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : secondaryBlue,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor:
              isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.95),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Keep Current',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white70 : secondaryBlue)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Reset Timer'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      // Cancel and reschedule the quiz reminder
      _scheduleQuizReminder();
    }
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
    bool? toggleValue,
    Function(bool)? onToggleChanged,
    required Widget child,
  }) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : lightBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isDarkMode ? Colors.white : primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                if (toggleValue != null && onToggleChanged != null)
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: toggleValue,
                      onChanged: onToggleChanged,
                      activeColor: isDarkMode ? Colors.white : primaryBlue,
                      activeTrackColor:
                          isDarkMode ? Colors.grey[800] : lightBlue,
                      inactiveThumbColor:
                          isDarkMode ? Colors.grey[700] : Colors.white,
                      inactiveTrackColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey[800]!.withOpacity(0.5)
              : lightBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white : primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white70 : secondaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white : primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.white70 : secondaryBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }

    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}