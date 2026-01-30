import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../services/local_storage.dart';

class ProjectsState {
  static const Object _unset = Object();
  const ProjectsState({
    required this.projects,
    required this.activeProjectId,
  });

  final List<Project> projects;
  final String? activeProjectId;

  factory ProjectsState.initial() {
    return const ProjectsState(
      projects: [],
      activeProjectId: null,
    );
  }

  ProjectsState copyWith({
    List<Project>? projects,
    Object? activeProjectId = _unset,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      activeProjectId: activeProjectId == _unset
          ? this.activeProjectId
          : activeProjectId as String?,
    );
  }
}

class ProjectsController extends Notifier<ProjectsState> {
  final Uuid _uuid = const Uuid();

  LocalStorage get _storage => ref.read(localStorageProvider);

  @override
  ProjectsState build() {
    return ProjectsState.initial();
  }

  Future<void> loadProjects() async {
    final List<Project> projects = await _storage.loadProjects();
    state = state.copyWith(projects: projects);
  }

  Future<Project> addProject({
    required String name,
    List<String> tags = const [],
  }) async {
    final Project project = Project(
      id: _uuid.v4(),
      name: name,
      tags: tags,
      createdAt: DateTime.now(),
    );
    final List<Project> updated = [...state.projects, project];
    state = state.copyWith(projects: updated);
    await _storage.saveProjects(updated);
    return project;
  }

  void setActiveProject(String? projectId) {
    state = state.copyWith(activeProjectId: projectId);
  }
}

final projectsControllerProvider =
    NotifierProvider<ProjectsController, ProjectsState>(ProjectsController.new);
