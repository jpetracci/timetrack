import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/projects_state.dart';
import 'state/timer_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ProviderContainer container = ProviderContainer();

  await container.read(projectsControllerProvider.notifier).loadProjects();
  await container.read(timerControllerProvider.notifier).hydrate();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TimeTrackApp(),
    ),
  );
}

class TimeTrackApp extends StatelessWidget {
  const TimeTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('TimeTrack'),
        ),
      ),
    );
  }
}
