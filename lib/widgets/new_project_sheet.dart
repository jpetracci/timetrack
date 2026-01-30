import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/projects_state.dart';

class NewProjectSheet extends ConsumerStatefulWidget {
  const NewProjectSheet({super.key});

  @override
  ConsumerState<NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends ConsumerState<NewProjectSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'Project name is required.';
      });
      return;
    }

    final List<String> tags = _tagsController.text
        .split(',')
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .toList();

    await ref
        .read(projectsControllerProvider.notifier)
        .addProject(name: name, tags: tags);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'New Project',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Project name',
              errorText: _error,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (comma-separated)',
              hintText: 'client, admin, research',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
}
