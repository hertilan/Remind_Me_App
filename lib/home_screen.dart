import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final db = await DatabaseHelper().database;

    final tasks = await db.query('tasks', orderBy: 'id DESC');
    setState(() {
      _tasks = tasks;
    });
  }

  void _navigateToAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Remind Me App',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _tasks.isEmpty
              ? const Center(
                child: Text("No task yet!", style: TextStyle(fontSize: 18)),
              )
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];

                  return ListTile(
                    title: Text(task['title']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddTaskScreen(
                                taskId: task['id'],
                                existingTitle: task['title'],
                              ),
                        ),
                      ).then((_) => _loadTasks());
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await DatabaseHelper().deleteTask(task['id']);
                        _loadTasks();
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}
