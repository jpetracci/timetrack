import 'package:flutter/material.dart';

import '../models/project.dart';
import '../utils/decimal_time.dart';

class ProjectCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final Color? background = isActive
        ? Theme.of(context).colorScheme.primaryContainer
        : null;

    return Card(
      color: background,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    '${formatDecimalHours(elapsed, 2)}h',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRunning ? 'Running' : 'Stopped',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
