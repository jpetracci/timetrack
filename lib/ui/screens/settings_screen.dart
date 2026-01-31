import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/settings_controller.dart';
import '../../state/settings_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int precision = ref.watch(
      settingsControllerProvider.select((state) => state.precision),
    );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Choose how many decimal places to show for hours.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Decimal precision',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$precision decimals',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  min: SettingsState.minPrecision.toDouble(),
                  max: SettingsState.maxPrecision.toDouble(),
                  divisions: SettingsState.maxPrecision -
                      SettingsState.minPrecision,
                  value: precision.toDouble(),
                  label: '$precision',
                  onChanged: (double value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setPrecision(value.round());
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '1 decimal gives a compact view. 4 decimals is most precise.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
