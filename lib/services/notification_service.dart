import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    print('🔔 Initializing NotificationService');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(
          title: message.notification?.title ?? 'New Message',
          body: message.notification?.body ?? '',
        );
      }
    });

    // Initialize timezone
    tz.initializeTimeZones();

    // Request permission for iOS and Android
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
      announcement: true,
      carPlay: true,
    );

    // Set foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('📲 FCM Token: $token');

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('🔔 Notification clicked: ${details.payload}');
      },
    );

    // Create the notification channel for Android
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      description: 'This channel is for task reminders',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
      enableLights: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print('✅ NotificationService initialized successfully');
  }

  Future<void> scheduleTaskReminder(
    int taskId,
    String title,
    DateTime taskTime,
    BuildContext context,
  ) async {
    print(
      '📅 Scheduling notification for task: $title at ${taskTime.toString()}',
    );

    // Schedule notification 30 minutes before task time
    final scheduledTime = taskTime.subtract(const Duration(minutes: 30));

    if (scheduledTime.isBefore(DateTime.now())) {
      print(
        '⚠️ Cannot schedule notification for past time: ${scheduledTime.toString()}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot schedule reminder for past time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'This channel is for task reminders',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
          styleInformation: BigTextStyleInformation(
            'Your task "$title" is due in 30 minutes',
            htmlFormatBigText: true,
            contentTitle: 'Upcoming Task Reminder',
            htmlFormatContentTitle: true,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      // Calculate delay in seconds
      final int delayInSeconds =
          scheduledTime.difference(DateTime.now()).inSeconds;

      // Schedule using Future.delayed
      Future.delayed(Duration(seconds: delayInSeconds), () async {
        await _localNotifications.show(
          taskId,
          'Upcoming Task Reminder',
          'Your task "$title" is due in 30 minutes',
          notificationDetails,
          payload: 'task_$taskId',
        );
      });

      print(
        '✅ Notification scheduled successfully for ${scheduledTime.toString()}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder scheduled for ${scheduledTime.toString()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      print('🔔 Showing immediate notification: $title');

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'This channel is for task reminders',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
      );
      print('✅ Immediate notification sent successfully');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  Future<void> cancelTaskReminder(int taskId) async {
    print('🗑️ Cancelling notification for task ID: $taskId');
    await _localNotifications.cancel(taskId);
  }

  // For testing purposes
  Future<void> showTestNotification() async {
    print('🔔 Showing test notification');
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from RemindMe App',
    );
  }
}
