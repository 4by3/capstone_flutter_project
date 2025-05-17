import 'dart:async';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
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
  StreamSubscription<QuerySnapshot>? _firestoreListener;
  DateTime? _lastNotificationTime;

  bool get isInitialized => _isInitialized;

  Future<bool> canScheduleExactAlarms() async {
    final androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final canSchedule = await androidPlugin?.canScheduleExactNotifications();
    print('Can schedule exact alarms: $canSchedule');
    return canSchedule ?? false;
  }

  Future<void> requestExactAlarmPermission() async {
    final androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestExactAlarmsPermission();
    print('Exact alarm permission granted: $granted');
  }

  Future<void> initNotifications() async {
    if (_isInitialized) {
      print('Notifications already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      print('Timezone initialized: $currentTimeZone');

      // Android initialization settings
      const initSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const initSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );

      // Request permissions for Android
      if (Platform.isAndroid) {
        final androidPlugin =
            notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        // Request POST_NOTIFICATIONS permission (Android 13+)
        final notificationGranted =
            await androidPlugin?.requestNotificationsPermission();
        print('Notification permission granted: $notificationGranted');
        if (notificationGranted != true) {
          print('Notification permission denied. Notifications may not work.');
        }

        // Check and request exact alarm permission
        if (!await canScheduleExactAlarms()) {
          print('Requesting exact alarm permission');
          await requestExactAlarmPermission();
        }
      }

      // Request iOS permissions
      if (Platform.isIOS) {
        final iosPlugin =
            notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final iosGranted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('iOS notification permissions granted: $iosGranted');
      }

      // Initialize the plugin
      final initialized = await notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
        },
      );

      if (initialized == true) {
        print('Notification initialization completed successfully');
        _isInitialized = true;
      } else {
        print('Failed to initialize notifications');
      }

      // Start Firestore listener if enabled
      final prefs = await SharedPreferences.getInstance();
      final databaseNotificationsEnabled =
          prefs.getBool('database_notifications_enabled') ?? false;
      if (databaseNotificationsEnabled) {
        startFirestoreListener();
      }
    } catch (e) {
      print('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  void startFirestoreListener() {
    // Cancel any existing listener to avoid duplicates
    _firestoreListener?.cancel();

    // Listen to changes in the 'features' collection
    // Listen to changes in the 'intro_questions' collection
    _firestoreListener = FirebaseFirestore.instance
        .collection('intro_questions')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var change in snapshot.docChanges) {
        // Only trigger notifications for edits (modified documents)
        if (change.type != DocumentChangeType.modified) {
          continue;
        }
        final now = DateTime.now();
        if (_lastNotificationTime != null &&
            now.difference(_lastNotificationTime!).inSeconds < 5) {
          print('Skipping notification: too soon');
          continue;
        }
        _lastNotificationTime = now;
        _showNotificationForFirestoreChange(
          id: change.doc.id.hashCode,
          title: 'Question Updated',
          body:
              'The question "${change.doc['question']}" was updated in Firestore.',
          payload: 'updated_${change.doc.id}',
        );
      }
    }, onError: (error) {
      print('Error listening to Firestore changes: $error');
    });
    print('Started Firestore listener for intro_questions collection');
  }

  void stopFirestoreListener() {
    _firestoreListener?.cancel();
    _firestoreListener = null;
    print('Stopped Firestore listener');
  }

  Future<void> _showNotificationForFirestoreChange({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      await notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails(),
        payload: payload,
      );
      print('Notification shown for Firestore change: id=$id, title=$title');
    } catch (e) {
      print('Error showing Firestore notification: $e');
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'privacy_reminders',
        'Privacy Reminders',
        channelDescription: 'Reminders about Facebook privacy settings',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    try {
      await notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails(),
        payload: payload,
      );
      print('Immediate notification shown: id=$id, title=$title');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
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
      print('Daily reminder scheduled: id=$id');
    } catch (e) {
      print('Error scheduling daily reminder: $e');
    }
  }

  Future<void> scheduleMonthlyReminder({
    required int id,
    required String title,
    required String body,
    required int day,
    required int hour,
    required int minute,
  }) async {
    try {
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
          scheduledDate = tz.TZDateTime(
              tz.local, now.year, now.month + 1, day, hour, minute);
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
      print('Monthly reminder scheduled: id=$id');
    } catch (e) {
      print('Error scheduling monthly reminder: $e');
    }
  }

  Future<void> scheduleQuizReminder({
    required int days,
    required String title,
    required String body,
  }) async {
    try {
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
        payload: 'retake_quiz_reminder',
      );
      print('Quiz reminder scheduled: days=$days');
    } catch (e) {
      print('Error scheduling quiz reminder: $e');
    }
  }

  Future<void> scheduleTestNotification({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {
    try {
      if (!_isInitialized) {
        print('Notifications not initialized. Initializing now...');
        await initNotifications();
      }

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(Duration(seconds: seconds));
      print('Current time: $now');
      print('Scheduled time: $scheduledDate');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'test_notification_channel',
        'Test Notifications',
        channelDescription: 'Channel for testing notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        visibility: NotificationVisibility.public,
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
      print('Scheduling test notification with mode: $scheduleMode');

      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        testNotificationDetails,
        androidScheduleMode: scheduleMode,
        payload: 'test_notification',
      );

      print('Test notification scheduled successfully: id=$id');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('test_notification_sent', true);
    } catch (e) {
      print('Error scheduling test notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleFeatureReminder({
    required int id,
    required String featureName,
    required int days,
  }) async {
    try {
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
        payload: 'feature_reminder_$id',
      );
      print('Feature reminder scheduled: id=${id + 200}');
    } catch (e) {
      print('Error scheduling feature reminder: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await notificationsPlugin.cancelAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      await prefs.setBool('monthly_notifications_enabled', false);
      await prefs.setBool('quiz_reminder_enabled', false);
      await prefs.setBool('database_notifications_enabled', false);
      stopFirestoreListener();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await notificationsPlugin.cancel(id);
      print('Notification cancelled: id=$id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  Future<bool> areMonthlyNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('monthly_notifications_enabled') ?? false;
  }
}
