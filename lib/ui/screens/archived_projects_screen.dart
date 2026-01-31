import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../state/projects_state.dart';
import 'project_details_screen.dart';

class ArchivedProjectsScreen extends ConsumerWidget {
  const ArchivedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Project> projects = ref.watch(
      projectsControllerProvider.select((state) => state.projects),
    );
    final List<Project> archivedProjects = projects
        .where((Project project) => project.isArchived)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Archived Projects')),
      body: archivedProjects.isEmpty
          ? const Center(child: Text('No archived projects.'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: archivedProjects.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (BuildContext context, int index) {
                final Project project = archivedProjects[index];
                return Card(
                  child: ListTile(
                    title: Text(project.name),
                    subtitle: Text(_tagsLabel(project)),
                    onTap: () => _openDetails(context, project.id),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => _restoreProject(context, ref, project),
                          child: const Text('Restore'),
                        ),
                        TextButton(
                          onPressed: () => _openDetails(context, project.id),
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _tagsLabel(Project project) {
    if (project.tags.isEmpty) {
      return 'No tags';
    }
    return project.tags.join(', ');
  }

  void _openDetails(BuildContext context, String projectId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectDetailsScreen(projectId: projectId),
      ),
    );
  }

  Future<void> _restoreProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    try {
      await ref
          .read(projectsControllerProvider.notifier)
          .unarchiveProject(project.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not restore project.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project restored.')),
    );
  }
}
