import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/projects_state.dart';
import '../../state/settings_controller.dart';
import '../../state/timer_controller.dart';
import '../../utils/decimal_time.dart';

class TimerHeader extends ConsumerWidget {
  const TimerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ({
      String? activeProjectId,
      String? lastActiveProjectId,
      bool isRunning,
      Duration elapsed
    }) timerSnapshot = ref.watch(
      timerControllerProvider.select(
        (state) => (
          activeProjectId: state.activeProjectId,
          lastActiveProjectId: state.lastActiveProjectId,
          isRunning: state.isRunning,
          elapsed: state.elapsed,
        ),
      ),
    );

    final String selectedProjectId = timerSnapshot.isRunning
        ? (timerSnapshot.activeProjectId ?? '')
        : (timerSnapshot.lastActiveProjectId ?? '');
    final String? lookupProjectId =
        selectedProjectId.isEmpty ? null : selectedProjectId;

    final String? projectName = ref.watch(
      projectsControllerProvider.select((state) {
        if (lookupProjectId == null) {
          return null;
        }
        for (final project in state.projects) {
          if (project.id == lookupProjectId) {
            return project.name;
          }
        }
        return null;
      }),
    );
    final int precision = ref.watch(
      settingsControllerProvider.select((state) => state.precision),
    );

    final String displayName = projectName ??
        (lookupProjectId == null ? 'No recent project' : 'Unknown project');
    final Duration displayDuration =
        timerSnapshot.isRunning ? timerSnapshot.elapsed : Duration.zero;
    final String displayTime =
        formatDecimalHours(displayDuration, precision);
    final bool canStart =
        !timerSnapshot.isRunning && lookupProjectId != null;

    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (timerSnapshot.isRunning)
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(timerControllerProvider.notifier).stop();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  )
                else
                  FilledButton.icon(
                    onPressed: canStart
                        ? () async {
                            await ref
                                .read(timerControllerProvider.notifier)
                                .start(selectedProjectId);
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              displayTime,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}
