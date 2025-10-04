import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>(
      (ref) => TaskListNotifier(DatabaseService()),
    );

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final DatabaseService _db;

  TaskListNotifier(this._db) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final tasks = await _db.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> addTask(Task task) async {
    // Do not clear state; write then refresh from DB
    try {
      await _db.insertTask(task);
      final fresh = await _db.getAllTasks();
      state = AsyncValue.data(fresh);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _db.deleteTask(id);
      final fresh = await _db.getAllTasks();
      state = AsyncValue.data(fresh);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
