import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyNotificationService {
  static final PrivacyNotificationService _instance = PrivacyNotificationService._internal();

  factory PrivacyNotificationService() {
    return _instance;
  }

  PrivacyNotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize notifications
  Future<void> initNotifications() async {
    if (_isInitialized) return; // Prevent re-initialization

    // Initialize timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Prepare Android init settings
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Prepare iOS init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // Initialize the plugin
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  // Notification details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'privacy_reminders',
        'Privacy Reminders',
        channelDescription: 'Reminders about Facebook privacy settings',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/notification_icon',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Show immediate notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
      payload: payload,
    );
  }

  // Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);

    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    // Create a date/time for today at the specified hour/min
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past for today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_privacy_reminder',
    );
  }


  Future<void> scheduleMonthlyReminder({
    required int id,
    required String title,
    required String body,
    required int day,  // Day of month (1-31)
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monthly_notifications_enabled', true);
    await prefs.setInt('notification_day', day);
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);

    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    // Create a date/time for this month on the specified day at the specified hour/min
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,  // Specified day of month
      hour,
      minute,
    );

    // If the scheduled day is in the past for this month, schedule for next month
    if (scheduledDate.isBefore(now)) {
      // Move to next month
      if (now.month == 12) {
        scheduledDate = tz.TZDateTime(tz.local, now.year + 1, 1, day, hour, minute);
      } else {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month + 1, day, hour, minute);
      }
    }

    // Handle invalid day of month (e.g., Feb 30)
    while (scheduledDate.day != day) {
      // If we scheduled day 31 but month only has 30 days, go to next month
      if (scheduledDate.month == 12) {
        scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year + 1, 1, day, hour, minute);
      } else {
        scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month + 1, day, hour, minute);
      }
    }


    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'monthly_privacy_reminder',
    );
  }


  Future<void> scheduleQuizReminder({
    required int days,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_reminder_enabled', true);
    await prefs.setInt('quiz_reminder_days', days);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(days: days));

    await notificationsPlugin.zonedSchedule(
      100, // Different ID from daily/monthly reminders
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'retake_quiz_reminder',
    );
  }


  Future<void> scheduleTestNotification({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {

    final now = tz.TZDateTime.now(tz.local);


    final scheduledDate = now.add(Duration(seconds: seconds));


    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_notification_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails testNotificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );


    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      testNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'test_notification',
    );


    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_notification_sent', true);
  }


  Future<void> scheduleFeatureReminder({
    required int id,
    required String featureName,
    required int days,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(days: days));

    await notificationsPlugin.zonedSchedule(
      id + 200, // Using a different range of IDs for feature reminders
      'Review $featureName',
      'It\'s time to check your $featureName settings on Facebook again!',
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'feature_reminder_$id',
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();

    // Clear daily preferences (keep for backward compatibility)
    await prefs.setBool('notifications_enabled', false);

    // Clear monthly preferences
    await prefs.setBool('monthly_notifications_enabled', false);

    // Clear quiz reminder preferences
    await prefs.setBool('quiz_reminder_enabled', false);
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  // Check if notifications are enabled (daily)
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  // Check if monthly notifications are enabled
  Future<bool> areMonthlyNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('monthly_notifications_enabled') ?? false;
  }
}