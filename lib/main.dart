import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed before using async DB functions
  // final dbHelper = DatabaseHelper();
  // await dbHelper.resetDatabase(); // Initialize the database
  runApp(const MyApp());
}

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
