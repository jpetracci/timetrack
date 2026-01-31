import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/project.dart';
import '../models/time_entry.dart';

enum ExportFormat { json, csv }

class ReportExportService {
  static const String _currentSchemaVersion = '1.0';

  static Future<void> exportAll({
    required ExportFormat format,
    required List<Project> projects,
    required List<TimeEntry> entries,
  }) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '').replaceAll('-', '').replaceAll('T', '_').split('.')[0];
    final baseFileName = 'timetrack_export_$timestamp';

    final List<XFile> files;

    if (format == ExportFormat.json) {
      files = await _generateJsonExport(baseFileName, projects, entries);
    } else {
      files = await _generateCsvExport(baseFileName, projects, entries);
    }

    if (files.isNotEmpty) {
      await SharePlus.instance.share(ShareParams(files: files));
    }
  }

  static Future<List<XFile>> _generateJsonExport(
    String baseFileName,
    List<Project> projects,
    List<TimeEntry> entries,
  ) async {
    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'schemaVersion': _currentSchemaVersion,
      'projects': projects.map((p) => p.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };

    final jsonString = jsonEncode(exportData);
    final fileName = '$baseFileName.json';

    if (kIsWeb) {
      // For web, create XFile from data directly
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
      return [XFile.fromData(bytes, name: fileName)];
    } else {
      // For mobile/desktop, write to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      return [XFile(file.path)];
    }
  }

  static Future<List<XFile>> _generateCsvExport(
    String baseFileName,
    List<Project> projects,
    List<TimeEntry> entries,
  ) async {
    // Generate projects CSV
    final projectsData = [
      ['ID', 'Name', 'Tags', 'Created At', 'Is Archived'],
      ...projects.map((p) => [
        p.id,
        p.name,
        p.tags.join(';'),
        p.createdAt.toIso8601String(),
        p.isArchived.toString(),
      ]),
    ];

    final projectsCsv = const ListToCsvConverter().convert(projectsData);

    // Generate entries CSV
    final entriesData = [
      ['ID', 'Project ID', 'Start Time', 'End Time', 'Duration (hours)'],
      ...entries.map((e) => [
        e.id,
        e.projectId,
        e.start.toIso8601String(),
        e.end?.toIso8601String() ?? '',
        e.durationHours.toStringAsFixed(6),
      ]),
    ];

    final entriesCsv = const ListToCsvConverter().convert(entriesData);

    final List<XFile> files = [];

    if (kIsWeb) {
      // For web, create XFile from data directly
      final projectsBytes = Uint8List.fromList(utf8.encode(projectsCsv));
      final entriesBytes = Uint8List.fromList(utf8.encode(entriesCsv));
      
      files.addAll([
        XFile.fromData(projectsBytes, name: '${baseFileName}_projects.csv'),
        XFile.fromData(entriesBytes, name: '${baseFileName}_entries.csv'),
      ]);
    } else {
      // For mobile/desktop, write to documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      final projectsFile = File('${directory.path}/${baseFileName}_projects.csv');
      await projectsFile.writeAsString(projectsCsv);
      files.add(XFile(projectsFile.path));

      final entriesFile = File('${directory.path}/${baseFileName}_entries.csv');
      await entriesFile.writeAsString(entriesCsv);
      files.add(XFile(entriesFile.path));
    }

    return files;
  }
}