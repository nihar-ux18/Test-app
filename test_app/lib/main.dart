import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TimeTrackerApp());
}

class TimeEntry {
  final String id;
  final int minutes;
  final String project;
  final String task;
  final String notes;
  final String date;

  TimeEntry({
    required this.id,
    required this.minutes,
    required this.project,
    required this.task,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'minutes': minutes,
      'project': project,
      'task': task,
      'notes': notes,
      'date': date,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      minutes: json['minutes'],
      project: json['project'],
      task: json['task'],
      notes: json['notes'],
      date: json['date'],
    );
  }
}

class TimeTrackerApp extends StatelessWidget {
  const TimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TimeEntry> entries = [];

  List<String> projects = [
    'Website Project',
    'Mobile App',
    'Research',
  ];

  List<String> tasks = [
    'Development',
    'Testing',
    'Documentation',
  ];

  bool grouped = false;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString('time_entries');

    if (saved != null) {
      final List decoded = jsonDecode(saved);

      setState(() {
        entries = decoded
            .map((item) => TimeEntry.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      entries.map((entry) => entry.toJson()).toList(),
    );

    await prefs.setString('time_entries', encoded);
  }

  Future<void> addEntry(TimeEntry entry) async {
    setState(() {
      entries.add(entry);
    });

    await saveEntries();
  }

  Future<void> deleteEntry(String id) async {
    setState(() {
      entries.removeWhere((entry) => entry.id == id);
    });

    await saveEntries();
  }

  int get totalMinutes {
    return entries.fold(
      0,
      (total, entry) => total + entry.minutes,
    );
  }

  String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '${mins}m';
    }

    if (mins == 0) {
      return '${hours}h';
    }

    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            tooltip: 'Group by projects',
            icon: Icon(
              grouped ? Icons.view_list : Icons.folder,
            ),
            onPressed: () {
              setState(() {
                grouped = !grouped;
              });
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Time Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Projects'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectPage(
                      projects: projects,
                      onAdd: (project) {
                        setState(() {
                          projects.add(project);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskPage(
                      tasks: tasks,
                      onAdd: (task) {
                        setState(() {
                          tasks.add(task);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: entries.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No time entries yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first time entry using the + button.',
                  ),
                ],
              ),
            )
          : grouped
              ? buildGroupedEntries()
              : buildEntryList(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryPage(
                projects: projects,
                tasks: tasks,
                onAdd: addEntry,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildEntryList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Total Time'),
              trailing: Text(
                formatMinutes(totalMinutes),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              return Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) {
                  deleteEntry(entry.id);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(entry.project),
                    subtitle: Text(
                      '${entry.task}\n'
                      '${entry.notes}\n'
                      '${entry.date}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      formatMinutes(entry.minutes),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildGroupedEntries() {
    final Map<String, List<TimeEntry>> groupedEntries = {};

    for (final entry in entries) {
      groupedEntries.putIfAbsent(
        entry.project,
        () => [],
      );

      groupedEntries[entry.project]!.add(entry);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: groupedEntries.entries.map((group) {
        final projectEntries = group.value;

        final total = projectEntries.fold(
          0,
          (sum, entry) => sum + entry.minutes,
        );

        return Card(
          child: ExpansionTile(
            title: Text(
              group.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              formatMinutes(total),
            ),
            children: projectEntries.map((entry) {
              return ListTile(
                title: Text(entry.task),
                subtitle: Text(
                  '${entry.notes}\n${entry.date}',
                ),
                isThreeLine: true,
                trailing: Text(
                  formatMinutes(entry.minutes),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class AddEntryPage extends StatefulWidget {
  final List<String> projects;
  final List<String> tasks;
  final Future<void> Function(TimeEntry) onAdd;

  const AddEntryPage({
    super.key,
    required this.projects,
    required this.tasks,
    required this.onAdd,
  });

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final timeController = TextEditingController();
  final notesController = TextEditingController();

  String? selectedProject;
  String? selectedTask;
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    timeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> submit() async {
    final minutes = int.tryParse(timeController.text.trim());

    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid total time in minutes.'),
        ),
      );
      return;
    }

    if (selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a project.'),
        ),
      );
      return;
    }

    if (selectedTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a task.'),
        ),
      );
      return;
    }

    final entry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      minutes: minutes,
      project: selectedProject!,
      task: selectedTask!,
      notes: notesController.text.trim(),
      date:
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
    );

    await widget.onAdd(entry);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add TimeEntry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Time',
                hintText: 'Example: 90',
                suffixText: 'minutes',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              value: selectedProject,
              decoration: const InputDecoration(
                labelText: 'Project',
                border: OutlineInputBorder(),
              ),
              items: widget.projects.map((project) {
                return DropdownMenuItem(
                  value: project,
                  child: Text(project),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProject = value;
                });
              },
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              value: selectedTask,
              decoration: const InputDecoration(
                labelText: 'Task',
                border: OutlineInputBorder(),
              ),
              items: widget.tasks.map((task) {
                return DropdownMenuItem(
                  value: task,
                  child: Text(task),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTask = value;
                });
              },
            ),

            const SizedBox(height: 18),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter notes about this work...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${selectedDate.day}/'
                  '${selectedDate.month}/'
                  '${selectedDate.year}',
                ),
                trailing: TextButton(
                  onPressed: selectDate,
                  child: const Text('Change'),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.add),
                label: const Text('Add TimeEntry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectPage extends StatefulWidget {
  final List<String> projects;
  final void Function(String) onAdd;

  const ProjectPage({
    super.key,
    required this.projects,
    required this.onAdd,
  });

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  void showAddProjectDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Project name',
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
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isNotEmpty) {
                  widget.onAdd(name);

                  setState(() {});

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: widget.projects.isEmpty
          ? const Center(
              child: Text('No projects'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.projects.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(widget.projects[index]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskPage extends StatefulWidget {
  final List<String> tasks;
  final void Function(String) onAdd;

  const TaskPage({
    super.key,
    required this.tasks,
    required this.onAdd,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  void showAddTaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Task name',
              hintText: 'Enter task name',
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
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isNotEmpty) {
                  widget.onAdd(name);

                  setState(() {});

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: widget.tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: Text(task),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}