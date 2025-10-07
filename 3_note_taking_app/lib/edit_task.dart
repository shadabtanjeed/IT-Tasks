import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  final int? taskId;
  const EditTaskPage({super.key, this.taskId});

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<Task?> _loadTask() async {
    if (widget.taskId == null) return null;
    return await ref
        .read(taskListProvider.notifier)
        .getTaskById(widget.taskId!);
  }

  Future<void> _saveChanges(Task task) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    setState(() => _isSaving = true);

    final updated = task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(taskListProvider.notifier).updateTask(updated);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Task?>(
        future: _loadTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final task = snapshot.data;

          if (task == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Task not found'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          _titleController.text = task.title;
          _descriptionController.text = task.description;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 30),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Edit task',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        left: 8,
                        child: IconButton(
                          onPressed: () {
                            context.go('/');
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _titleController,
                    enabled: !_isSaving,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    cursorColor: Theme.of(context).colorScheme.primary,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _descriptionController,
                    enabled: !_isSaving,
                    maxLines: 5,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    cursorColor: Theme.of(context).colorScheme.primary,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveChanges(task),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF134686),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Changes',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
