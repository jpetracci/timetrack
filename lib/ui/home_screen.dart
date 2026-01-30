import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../state/projects_state.dart';
import '../state/timer_controller.dart';
import '../widgets/new_project_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProjectsState projectsState = ref.watch(projectsControllerProvider);
    final timerState = ref.watch(timerControllerProvider);
    Project? activeProject;
    for (final Project project in projectsState.projects) {
      if (project.id == timerState.activeProjectId) {
        activeProject = project;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeTrack'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return const NewProjectSheet();
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        activeProject?.name ?? 'No active project',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatDecimalHours(timerState.elapsed, 2)}h',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Projects',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: projectsState.projects.isEmpty
                    ? const Center(
                        child: Text('No projects yet. Add your first one.'),
                      )
                    : ListView.builder(
                        itemCount: projectsState.projects.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Project project =
                              projectsState.projects[index];
                          final bool isActive =
                              timerState.activeProjectId == project.id &&
                                  timerState.isRunning;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () async {
                                final timerController =
                                    ref.read(timerControllerProvider.notifier);
                                if (isActive) {
                                  await timerController.stop();
                                } else {
                                  await timerController.start(project.id);
                                }
                              },
                              title: Text(project.name),
                              subtitle: Text(
                                project.tags.isEmpty
                                    ? 'No tags'
                                    : project.tags.join(', '),
                              ),
                              trailing: Icon(
                                isActive ? Icons.pause_circle : Icons.play_circle,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDecimalHours(Duration duration, int precision) {
    final double hours = duration.inSeconds / 3600;
    return hours.toStringAsFixed(precision);
  }
}
