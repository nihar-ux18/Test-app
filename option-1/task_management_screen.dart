import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskProvider extends ChangeNotifier {
  final List<String> _tasks = [];

  List<String> get tasks =>
      List.unmodifiable(_tasks);

  void addTask(String task) {
    if (task.trim().isEmpty) {
      return;
    }

    _tasks.add(task.trim());
    notifyListeners();
  }

  void removeTask(int index) {
    if (index < 0 ||
        index >= _tasks.length) {
      return;
    }

    _tasks.removeAt(index);
    notifyListeners();
  }
}

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState
    extends State<TaskManagementScreen> {
  final List<Map<String, dynamic>> tasks = [];

  final TextEditingController taskController =
      TextEditingController();

  void _addTask() {
    final task =
        taskController.text.trim();

    if (task.isEmpty) {
      return;
    }

    setState(() {
      tasks.add({
        'title': task,
        'completed': false,
      });
    });

    taskController.clear();
    Navigator.pop(context);
  }

  void _showAddTaskDialog() {
    taskController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              labelText: 'Task name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTask(
    int index,
    bool? value,
  ) {
    setState(() {
      tasks[index]['completed'] =
          value ?? false;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks available',
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder:
                  (context, index) {
                final task =
                    tasks[index];

                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value:
                          task['completed'],
                      onChanged: (value) {
                        _toggleTask(
                          index,
                          value,
                        );
                      },
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration:
                            task['completed']
                                ? TextDecoration
                                    .lineThrough
                                : TextDecoration
                                    .none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                      ),
                      onPressed: () {
                        _deleteTask(index);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
