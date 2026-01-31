import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../models/time_entry.dart';
import '../../state/projects_state.dart';
import '../../state/settings_controller.dart';
import '../../state/timer_controller.dart';
import '../../widgets/project_edit_sheet.dart';
import '../../widgets/time_entry_tile.dart';

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

    final Project currentProject = project;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final timerState = ref.watch(timerControllerProvider);
    final int precision = ref.watch(
      settingsControllerProvider.select((state) => state.precision),
    );
    final bool isRunningForProject = timerState.isRunning &&
        timerState.activeProjectId == currentProject.id;
    final List<TimeEntry> projectEntries = timerState.entries
        .where((TimeEntry entry) => entry.projectId == currentProject.id)
        .toList()
      ..sort(
        (TimeEntry a, TimeEntry b) =>
            _entrySortKey(b).compareTo(_entrySortKey(a)),
      );
    final TimeEntry? runningEntry = timerState.runningEntry;
    final List<TimeEntry> displayEntries = <TimeEntry>[
      if (runningEntry != null &&
          runningEntry.projectId == currentProject.id)
        runningEntry,
      ...projectEntries,
    ];
    final bool isArchived = currentProject.isArchived;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showEditSheet(context, currentProject),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            currentProject.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
           if (currentProject.tags.isEmpty)
             Text(
               'No tags',
               style: Theme.of(context).textTheme.bodySmall,
             )
           else
             Wrap(
               spacing: 8,
               runSpacing: 8,
               children: currentProject.tags
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
            _formatDate(currentProject.createdAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Text(
            'Time history',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (displayEntries.isEmpty)
            Text(
              'No entries yet.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Column(
              children: displayEntries
                  .map(
                    (TimeEntry entry) => TimeEntryTile(
                      entry: entry,
                      precision: precision,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _toggleArchive(
              context,
              ref,
              currentProject,
              isRunningForProject,
            ),
            icon: Icon(
              isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            label: Text(isArchived ? 'Restore project' : 'Archive project'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _confirmDelete(context, ref, currentProject),
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

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Project project,
    bool isRunningForProject,
  ) async {
    if (!project.isArchived && isRunningForProject) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stop the timer before archiving this project.'),
        ),
      );
      return;
    }

    try {
      final controller = ref.read(projectsControllerProvider.notifier);
      if (project.isArchived) {
        await controller.unarchiveProject(project.id);
      } else {
        await controller.archiveProject(project.id);
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            project.isArchived
                ? 'Could not restore project.'
                : 'Could not archive project.',
          ),
        ),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          project.isArchived ? 'Project restored.' : 'Project archived.',
        ),
      ),
    );

    if (!project.isArchived) {
      Navigator.of(context).pop();
    }
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

  DateTime _entrySortKey(TimeEntry entry) {
    return entry.end ?? entry.start;
  }
}
