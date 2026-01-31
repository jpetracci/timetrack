import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../state/projects_state.dart';
import '../../state/timer_controller.dart';
import '../../widgets/project_card.dart';
import '../widgets/timer_header.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Project> projects = ref.watch(
      projectsControllerProvider.select((state) => state.projects),
    );

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double maxWidth = width < 720 ? width : 720;
          final double horizontalPadding = width < 360 ? 12 : 16;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TimerHeaderDelegate(
                      horizontalPadding: horizontalPadding,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        8,
                      ),
                      child: Text(
                        'Projects',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  if (projects.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No projects yet. Add your first one.'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final Project project = projects[index];
                            return Consumer(
                              builder: (
                                BuildContext context,
                                WidgetRef ref,
                                Widget? child,
                              ) {
                                final bool isActive = ref.watch(
                                  timerControllerProvider.select(
                                    (state) =>
                                        state.activeProjectId == project.id,
                                  ),
                                );
                                final bool isRunning = ref.watch(
                                  timerControllerProvider.select(
                                    (state) => state.isRunning &&
                                        state.activeProjectId == project.id,
                                  ),
                                );
                                final Duration elapsed = ref.watch(
                                  timerControllerProvider.select(
                                    (state) => state.isRunning &&
                                            state.activeProjectId == project.id
                                        ? state.elapsed
                                        : Duration.zero,
                                  ),
                                );

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
                                      try {
                                        await timerController.stop();
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not stop timer.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      try {
                                        await timerController.start(project.id);
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not start timer.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                );
                              },
                            );
                          },
                          childCount: projects.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimerHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TimerHeaderDelegate({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  double get minExtent => 140;

  @override
  double get maxExtent => 140;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        12,
      ),
      child: const TimerHeader(),
    );
  }

  @override
  bool shouldRebuild(covariant _TimerHeaderDelegate oldDelegate) {
    return oldDelegate.horizontalPadding != horizontalPadding;
  }
}
