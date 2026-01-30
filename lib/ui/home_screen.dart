import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../state/projects_state.dart';
import '../state/timer_controller.dart';
import '../utils/decimal_time.dart';
import '../widgets/new_project_sheet.dart';
import '../widgets/project_card.dart';

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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double maxWidth =
                constraints.maxWidth < 720 ? constraints.maxWidth : 720;
            const double outerPadding = 16;
            const double cardPadding = 16;
            const double sectionSpacing = 16;
            const double smallSpacing = 8;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.all(outerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      activeProject?.name ??
                                          'No active project',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  if (timerState.isRunning)
                                    TextButton.icon(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              timerControllerProvider.notifier,
                                            )
                                            .stop();
                                      },
                                      icon: const Icon(Icons.stop),
                                      label: const Text('Stop'),
                                    ),
                                ],
                              ),
                              SizedBox(height: smallSpacing),
                              Text(
                                '${formatDecimalHours(timerState.elapsed, 2)}h',
                                style:
                                    Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: smallSpacing),
                      Expanded(
                        child: projectsState.projects.isEmpty
                            ? const Center(
                                child:
                                    Text('No projects yet. Add your first one.'),
                              )
                            : ListView.builder(
                                itemCount: projectsState.projects.length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  final Project project =
                                      projectsState.projects[index];
                                  final bool isActive =
                                      timerState.activeProjectId == project.id;
                                  final bool isRunning =
                                      isActive && timerState.isRunning;
                                  final Duration elapsed = isRunning
                                      ? timerState.elapsed
                                      : Duration.zero;

                                  return ProjectCard(
                                    project: project,
                                    isActive: isActive,
                                    isRunning: isRunning,
                                    elapsed: elapsed,
                                    onTap: () async {
                                      final timerController = ref.read(
                                        timerControllerProvider.notifier,
                                      );
                                      if (isRunning) {
                                        await timerController.stop();
                                      } else {
                                        await timerController.start(project.id);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
