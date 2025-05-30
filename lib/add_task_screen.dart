import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  final int? taskId;
  final String? existingTitle;

  const AddTaskScreen({super.key, this.taskId, this.existingTitle});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _controller = TextEditingController();
  DateTime? _selectedDateTime;
  final _notificationService = NotificationService();

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
    int taskId;

    if (widget.taskId == null) {
      taskId = await db.insertTask(title, dueDate: _selectedDateTime);
    } else {
      taskId = widget.taskId!;
      await db.updateTask(taskId, title, dueDate: _selectedDateTime);
      // Cancel existing notification before scheduling new one
      await _notificationService.cancelTaskReminder(taskId);
    }

    // Schedule notification if date is selected
    if (_selectedDateTime != null) {
      await _notificationService.scheduleTaskReminder(
        taskId,
        title,
        _selectedDateTime!,
        context,
      );
    }

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.taskId == null ? 'Task added successfully' : 'Task updated successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Pop and refresh
    if (mounted) {
      Navigator.pop(context, true);  // Return true to indicate success
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _selectedDateTime = combined;
    });
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
            Text(
              _selectedDateTime == null
                  ? 'No date selected'
                  : 'Selected: ${_selectedDateTime!.toString().substring(0, 16)}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Select Date & Time'),
            ),
            const SizedBox(height: 10),

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
