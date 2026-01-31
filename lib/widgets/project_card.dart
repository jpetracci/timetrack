import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../state/settings_controller.dart';
import '../utils/decimal_time.dart';

class ProjectCard extends ConsumerWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.isActive,
    required this.isRunning,
    required this.elapsed,
    required this.onTap,
  });

  final Project project;
  final bool isActive;
  final bool isRunning;
  final Duration elapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int precision = ref.watch(
      settingsControllerProvider.select((state) => state.precision),
    );
    final ColorScheme colors = Theme.of(context).colorScheme;
    const Duration animationDuration = Duration(milliseconds: 200);
    final bool isEmphasized = isActive || isRunning;
    final Color background =
        isEmphasized ? colors.primaryContainer : colors.surface;
    final Color borderColor =
        isEmphasized ? colors.primary : colors.outlineVariant;
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final List<BoxShadow> shadows = isEmphasized
        ? <BoxShadow>[
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
        : const <BoxShadow>[];

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (project.tags.isEmpty)
                        Text(
                          'No tags',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: project.tags
                              .map(
                                (String tag) => Chip(
                                  label: Text(tag),
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      formatDecimalHours(elapsed, precision),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: animationDuration,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: Text(
                        isRunning ? 'Running' : 'Stopped',
                        key: ValueKey<bool>(isRunning),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isRunning
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
