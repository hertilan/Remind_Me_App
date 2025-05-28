import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If app is in background or terminated and receives a notification
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔕 Handling background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Init Local Notifications
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    initFirebaseMessaging();
  }

  void initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔐 Request notification permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 User granted permission');

      // 🔑 Get device token (send this to your backend if needed)
      String? token = await messaging.getToken();
      print("📲 FCM Token: $token");

      // 🔔 Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          '📩 Foreground message: ${message.notification?.title} - ${message.notification?.body}',
        );
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'reminder_channel', // channel ID
                'Reminders', // channel name
                channelDescription:
                    'This channel is for reminder notifications',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });

      // 💭 App opened from background via notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📬 Notification clicked!');
        // You can navigate to specific screen here
      });
    } else {
      print('❌ User declined permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RemindMe",
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: const HomeScreen(),
    );
  }
}
