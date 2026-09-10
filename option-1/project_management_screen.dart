import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectProvider extends ChangeNotifier {
  final List<String> _projects = [];

  List<String> get projects =>
      List.unmodifiable(_projects);

  void addProject(String project) {
    if (project.trim().isEmpty) {
      return;
    }

    _projects.add(project.trim());
    notifyListeners();
  }

  void removeProject(int index) {
    if (index < 0 ||
        index >= _projects.length) {
      return;
    }

    _projects.removeAt(index);
    notifyListeners();
  }
}

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  void _showAddProjectDialog(
    BuildContext context,
  ) {
    final controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Project name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name =
                    controller.text.trim();

                if (name.isNotEmpty) {
                  context
                      .read<ProjectProvider>()
                      .addProject(name);
                }

                controller.dispose();
                Navigator.pop(dialogContext);
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
        title: const Text(
          'Project Management',
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.projects.isEmpty) {
            return const Center(
              child: Text(
                'No projects available',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                provider.projects.length,
            itemBuilder: (
              context,
              index,
            ) {
              final project =
                  provider.projects[index];

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.folder,
                  ),
                  title: Text(project),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),
                    onPressed: () {
                      provider.removeProject(
                        index,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          _showAddProjectDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
