import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  final _store = intMapStoreFactory.store('tasks');

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Use IndexedDB for web
      return await databaseFactoryWeb.openDatabase('tasks_database.db');
    } else {
      // Use native file system for mobile/desktop
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dbPath = join(dir.path, 'tasks_database.db');
      return await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  // CRUD methods
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await _store.add(db, task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final snapshots = await _store.find(db);
    return snapshots
        .map((snapshot) => Task.fromMap(snapshot.value, snapshot.key))
        .toList();
  }

  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final snapshot = await _store.record(id).get(db);
    if (snapshot == null) return null;
    return Task.fromMap(snapshot, id);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await _store.record(task.id!).update(db, task.toMap());
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await _store.record(id).delete(db);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
