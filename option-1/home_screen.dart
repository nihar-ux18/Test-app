import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'time_entry_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time Tracker'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Entries'),
              Tab(text: 'Grouped by Projects'),
            ],
          ),
        ),

        // Hamburger menu
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text(
                  'Time Tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Projects'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ProjectManagementScreen(),
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
                      builder: (context) =>
                          const TaskManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            TimeEntriesTab(),
            GroupedProjectsTab(),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTimeEntryScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TimeEntriesTab extends StatelessWidget {
  const TimeEntriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        final entries = provider.timeEntries;

        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'No time entries yet!',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first entry.',
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(entry.title),
                subtitle: Text(
                  '${entry.project} • ${entry.task}\n'
                  '${entry.date}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.hours} hrs',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        provider.deleteEntry(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class GroupedProjectsTab extends StatelessWidget {
  const GroupedProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        final entries = provider.timeEntries;

        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text('No time entries yet!'),
              ],
            ),
          );
        }

        final Map<String, double> grouped = {};

        for (final entry in entries) {
          grouped[entry.project] =
              (grouped[entry.project] ?? 0) + entry.hours;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: Text(entry.key),
                trailing: Text(
                  '${entry.value.toStringAsFixed(1)} hrs',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
