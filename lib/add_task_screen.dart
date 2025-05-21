import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddTaskScreen extends StatefulWidget {
  final int? taskId;
  final String? existingTitle;

  const AddTaskScreen({super.key, this.taskId, this.existingTitle});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingTitle != null) {
      _controller.text = widget.existingTitle!;
    }
  }

  Future<void> _saveTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final db = DatabaseHelper();
    if (widget.taskId == null) {
      await db.insertTask(title);
    } else {
      await db.updateTask(widget.taskId!, title);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.taskId == null ? 'Add Task' : 'Edit Task',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Task Title', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  widget.taskId == null ? 'Add Task' : 'Update Task',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
