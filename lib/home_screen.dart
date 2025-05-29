import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_task_screen.dart';
import 'services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = [];
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final db = await DatabaseHelper().database;

    final tasks = await db.query(
      'tasks',
      orderBy:
          'CASE WHEN dueDate IS NULL THEN 1 ELSE 0 END, datetime(dueDate) ASC',
    );
    setState(() {
      _tasks = tasks;
    });
  }

  void _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (result == true) {
      await _loadTasks();
    }
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
        backgroundColor: Colors.blueAccent[200],
        centerTitle: true,
        toolbarHeight: 70,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_active, color: Colors.white),
        //     onPressed: () async {
        //       await _notificationService.showTestNotification();
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('Test notification sent!'),
        //           backgroundColor: Colors.green,
        //         ),
        //       );
        //     },
        //   ),
        // ],
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
                  final dueDate =
                      task['dueDate'] != null
                          ? DateTime.parse(
                            task['dueDate'],
                          ).toLocal().toString().substring(0, 16)
                          : null;

                  final isDone = task['isDone'] == 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddTaskScreen(
                                    taskId: task['id'],
                                    existingTitle: task['title'],
                                  ),
                            ),
                          );

                          if (result == true) {
                            await _loadTasks();
                          }
                        },
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.red,
                            decorationThickness: 3,
                          ),
                        ),
                        subtitle:
                            dueDate != null
                                ? Text(
                                  'Due: $dueDate',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    decoration:
                                        isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                    decorationColor: Colors.red,
                                    decorationThickness: 3,
                                  ),
                                )
                                : const Text('No due date'),
                        leading: Checkbox(
                          value: isDone,
                          onChanged: (newValue) async {
                            await DatabaseHelper().toggleTask(
                              task['id'],
                              newValue!,
                            );
                            _loadTasks();
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: const Text(
                                      'Are you sure you want to delete this task?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (shouldDelete == true) {
                              await DatabaseHelper().deleteTask(task['id']);
                              _loadTasks();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task deleted Successful'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                        ),
                      ),
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
