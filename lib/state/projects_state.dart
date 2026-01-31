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

  Future<void> updateProject({
    required String projectId,
    required String name,
    required List<String> tags,
  }) async {
    bool found = false;
    final List<Project> updated = state.projects.map((Project project) {
      if (project.id == projectId) {
        found = true;
        return project.copyWith(name: name, tags: tags);
      }
      return project;
    }).toList();

    if (!found) {
      throw StateError('Project not found');
    }

    state = state.copyWith(projects: updated);
    await _storage.saveProjects(updated);
  }

  Future<void> deleteProject(String projectId) async {
    final List<Project> updated = state.projects
        .where((Project project) => project.id != projectId)
        .toList();
    final String? activeProjectId =
        state.activeProjectId == projectId ? null : state.activeProjectId;

    state = state.copyWith(
      projects: updated,
      activeProjectId: activeProjectId,
    );
    await _storage.saveProjects(updated);
  }

  void setActiveProject(String? projectId) {
    state = state.copyWith(activeProjectId: projectId);
  }
}

final projectsControllerProvider =
    NotifierProvider<ProjectsController, ProjectsState>(ProjectsController.new);
