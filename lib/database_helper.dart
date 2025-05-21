import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      dueDate TEXT,
      isDone INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    await deleteDatabase(path);
  }

  Future<void> toggleTask(int id, bool isDone) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertTask(String title, {DateTime? dueDate}) async {
    final db = await database;
    await db.insert('tasks', {
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTask(int id, String newTitle, {DateTime? dueDate}) async {
    final db = await database;
    await db.update(
      'tasks',
      {'title': newTitle, 'dueDate': dueDate?.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
