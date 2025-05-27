import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'home_screen.dart';

// 1. Import Firebase Core and the generated options file
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this path is correct!

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed before using async DB functions

  // 2. Initialize Firebase here
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You had these commented out, keep them that way unless you specifically need them to run on app start.
  // final dbHelper = DatabaseHelper();
  // await dbHelper.resetDatabase(); // Initialize the database

  runApp(const MyApp());
}

// This function is fine as is, but it's not being called on app start in your current main.
Future<void> resetDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'tasks.db');
  await deleteDatabase(path);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RemindMe",
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
