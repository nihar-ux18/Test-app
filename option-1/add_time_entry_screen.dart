import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'time_entry_provider.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() =>
      _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState
    extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController hoursController =
      TextEditingController();

  DateTime selectedDate = DateTime.now();

  String? selectedProject;
  String? selectedTask;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedProject == null ||
        selectedTask == null) {
      return;
    }

    final hours = double.parse(
      hoursController.text,
    );

    final entry = TimeEntry(
      title: titleController.text.trim(),
      hours: hours,
      date:
          '${selectedDate.day}/'
          '${selectedDate.month}/'
          '${selectedDate.year}',
      project: selectedProject!,
      task: selectedTask!,
    );

    await context
        .read<TimeEntryProvider>()
        .addEntry(entry);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects =
        context.watch<ProjectProvider>().projects;

    final tasks =
        context.watch<TaskProvider>().tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedProject,
                decoration: const InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                items: projects.map((project) {
                  return DropdownMenuItem<String>(
                    value: project,
                    child: Text(project),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProject = value;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please select a project';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedTask,
                decoration: const InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(),
                ),
                items: tasks.map((task) {
                  return DropdownMenuItem<String>(
                    value: task,
                    child: Text(task),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTask = value;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please select a task';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: hoursController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please enter hours';
                  }

                  final hours =
                      double.tryParse(value);

                  if (hours == null ||
                      hours <= 0) {
                    return 'Enter a valid number of hours';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  '${selectedDate.day}/'
                  '${selectedDate.month}/'
                  '${selectedDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.calendar_month,
                  ),
                  onPressed: _selectDate,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  child: const Text(
                    'Save Entry',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
