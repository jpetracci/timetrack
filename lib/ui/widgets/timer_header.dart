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
    const Duration animationDuration = Duration(milliseconds: 200);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color headerColor = timerSnapshot.isRunning
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final Color timeColor =
        timerSnapshot.isRunning ? colors.primary : colors.onSurface;

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isCompact = constraints.maxHeight < 120;
            final EdgeInsets contentPadding = EdgeInsets.all(
              isCompact ? 12 : 16,
            );
            final TextStyle? nameStyle = isCompact
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.titleLarge;
            final TextStyle? timeStyle = isCompact
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.displaySmall;
            final ButtonStyle? buttonStyle = isCompact
                ? FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : null;

            return Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: nameStyle,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: animationDuration,
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.96, end: 1)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: timerSnapshot.isRunning
                            ? FilledButton.icon(
                                key: const ValueKey<String>('stop'),
                                style: buttonStyle,
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(timerControllerProvider.notifier)
                                        .stop();
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Could not stop timer.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop'),
                              )
                            : FilledButton.icon(
                                key: const ValueKey<String>('start'),
                                style: buttonStyle,
                                onPressed: canStart
                                    ? () async {
                                        try {
                                          await ref
                                              .read(
                                                timerControllerProvider.notifier,
                                              )
                                              .start(selectedProjectId);
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
                                    : null,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start'),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 6 : 12),
                  AnimatedSwitcher(
                    duration: animationDuration,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      timerSnapshot.isRunning ? 'Running' : 'Stopped',
                      key: ValueKey<bool>(timerSnapshot.isRunning),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: timerSnapshot.isRunning
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 2 : 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      displayTime,
                      style: timeStyle?.copyWith(color: timeColor),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
