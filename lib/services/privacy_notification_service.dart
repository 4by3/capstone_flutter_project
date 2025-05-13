import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyNotificationService {
  static final PrivacyNotificationService _instance =
      PrivacyNotificationService._internal();

  factory PrivacyNotificationService() {
    return _instance;
  }

  PrivacyNotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<bool> canScheduleExactAlarms() async {
    // FlutterLocalNotificationsPlugin does not support checking exact alarm permission directly.

    return true; // assume permission granted for now
  }

  // Request exact alarm permission
  Future<void> requestExactAlarmPermission() async {
    final androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // Initialize notifications
  Future<void> initNotifications() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      if (!await canScheduleExactAlarms()) {
        print('Requesting exact alarm permission');
        await requestExactAlarmPermission();
      }
    }

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
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
        icon: '@mipmap/ic_launcher',
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

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    print(
        'Scheduling daily reminder with mode: $scheduleMode at $scheduledDate');

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_privacy_reminder',
    );
  }

  // Schedule monthly reminder
  Future<void> scheduleMonthlyReminder({
    required int id,
    required String title,
    required String body,
    required int day,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monthly_notifications_enabled', true);
    await prefs.setInt('notification_day', day);
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      if (now.month == 12) {
        scheduledDate =
            tz.TZDateTime(tz.local, now.year + 1, 1, day, hour, minute);
      } else {
        scheduledDate =
            tz.TZDateTime(tz.local, now.year, now.month + 1, day, hour, minute);
      }
    }

    while (scheduledDate.day != day) {
      if (scheduledDate.month == 12) {
        scheduledDate = tz.TZDateTime(
            tz.local, scheduledDate.year + 1, 1, day, hour, minute);
      } else {
        scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year,
            scheduledDate.month + 1, day, hour, minute);
      }
    }

    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    print(
        'Scheduling monthly reminder with mode: $scheduleMode at $scheduledDate');

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'monthly_privacy_reminder',
    );
  }

  // Schedule quiz reminder
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

    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    print(
        'Scheduling quiz reminder with mode: $scheduleMode at $scheduledDate');

    await notificationsPlugin.zonedSchedule(
      100,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'retake_quiz_reminder',
    );
  }

  // Schedule test notification
  Future<void> scheduleTestNotification({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(seconds: seconds));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_notification_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
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

    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    print(
        'Scheduling test notification with mode: $scheduleMode at $scheduledDate');

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      testNotificationDetails,
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'test_notification',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('test_notification_sent', true);
  }

  // Schedule feature reminder
  Future<void> scheduleFeatureReminder({
    required int id,
    required String featureName,
    required int days,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(days: days));

    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    print(
        'Scheduling feature reminder with mode: $scheduleMode at $scheduledDate');

    await notificationsPlugin.zonedSchedule(
      id + 200,
      'Review $featureName',
      'It\'s time to check your $featureName settings on Facebook again!',
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'feature_reminder_$id',
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
    await prefs.setBool('monthly_notifications_enabled', false);
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
