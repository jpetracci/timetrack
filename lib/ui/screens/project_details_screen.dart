import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../state/projects_state.dart';
import '../../state/timer_controller.dart';
import '../../widgets/project_edit_sheet.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProjectsState projectsState = ref.watch(projectsControllerProvider);
    Project? project;
    for (final Project candidate in projectsState.projects) {
      if (candidate.id == projectId) {
        project = candidate;
        break;
      }
    }

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: const Center(child: Text('Project not found.')),
      );
    }

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showEditSheet(context, project!),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            project.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (project.tags.isEmpty)
            Text(
              'No tags',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.tags
                  .map(
                    (String tag) => Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          Text(
            'Created',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(project.createdAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => _confirmDelete(context, ref, project!),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete project'),
            style: TextButton.styleFrom(foregroundColor: colors.error),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, Project project) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => ProjectEditSheet(project: project),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete project?'),
          content: const Text(
            'This removes the project and its saved entries. This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final timerController = ref.read(timerControllerProvider.notifier);
    final timerState = ref.read(timerControllerProvider);

    try {
      if (timerState.isRunning && timerState.activeProjectId == project.id) {
        await timerController.stop();
      }
      await timerController.removeEntriesForProject(project.id);
      await ref
          .read(projectsControllerProvider.notifier)
          .deleteProject(project.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete project.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project deleted.')),
    );
  }

  String _formatDate(DateTime value) {
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
