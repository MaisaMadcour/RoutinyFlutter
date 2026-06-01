import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models.dart';

/// SQLite store — the Flutter equivalent of the Android Room database.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'routiny.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE routiny_tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            iconResName TEXT NOT NULL,
            colorHex TEXT NOT NULL,
            subTasks TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            hasReminder INTEGER NOT NULL,
            timeRange TEXT NOT NULL
          )''');
        await d.execute('''
          CREATE TABLE focus_sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskId INTEGER,
            taskTitle TEXT NOT NULL,
            startTime INTEGER NOT NULL,
            endTime INTEGER NOT NULL,
            durationSec INTEGER NOT NULL,
            plannedDurationSec INTEGER NOT NULL,
            type TEXT NOT NULL,
            completed INTEGER NOT NULL,
            pomodoroNumber INTEGER NOT NULL
          )''');
        await d.execute('''
          CREATE TABLE reflections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            mood TEXT NOT NULL,
            feelings TEXT NOT NULL,
            influences TEXT NOT NULL,
            journal TEXT
          )''');
      },
    );
  }

  // ---- Tasks ----
  Future<List<TaskEntity>> tasksByDate(String date) async {
    final d = await db;
    // Tasks with `date = ''` are "every day" (default starter tasks).
    final rows = await d.query('routiny_tasks',
        where: "date = ? OR date = ''",
        whereArgs: [date],
        orderBy: 'id ASC');
    return rows.map(TaskEntity.fromMap).toList();
  }

  Future<List<TaskEntity>> allTasks() async {
    final d = await db;
    final rows = await d.query('routiny_tasks', orderBy: 'id DESC');
    return rows.map(TaskEntity.fromMap).toList();
  }

  Future<int> taskCount() async {
    final d = await db;
    final r = await d.rawQuery('SELECT COUNT(*) c FROM routiny_tasks');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> insertTask(TaskEntity t) async {
    final d = await db;
    return d.insert('routiny_tasks', t.toMap());
  }

  Future<void> updateTask(TaskEntity t) async {
    final d = await db;
    await d.update('routiny_tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> deleteTask(int id) async {
    final d = await db;
    await d.delete('routiny_tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Focus sessions ----
  Future<int> insertFocusSession(FocusSessionEntity s) async {
    final d = await db;
    return d.insert('focus_sessions', s.toMap());
  }

  Future<List<FocusSessionEntity>> focusSessionsBetween(int from, int to) async {
    final d = await db;
    final rows = await d.query('focus_sessions',
        where: 'startTime >= ? AND startTime < ?', whereArgs: [from, to]);
    return rows.map(FocusSessionEntity.fromMap).toList();
  }

  Future<List<FocusSessionEntity>> allFocusSessions() async {
    final d = await db;
    final rows = await d.query('focus_sessions', orderBy: 'startTime DESC');
    return rows.map(FocusSessionEntity.fromMap).toList();
  }

  // ---- Reflections ----
  Future<int> insertReflection(ReflectionEntity r) async {
    final d = await db;
    return d.insert('reflections', r.toMap());
  }

  Future<List<ReflectionEntity>> reflectionsSince(int ts) async {
    final d = await db;
    final rows = await d.query('reflections',
        where: 'timestamp >= ?', whereArgs: [ts], orderBy: 'timestamp DESC');
    return rows.map(ReflectionEntity.fromMap).toList();
  }

  Future<List<ReflectionEntity>> allReflections() async {
    final d = await db;
    final rows = await d.query('reflections', orderBy: 'timestamp DESC');
    return rows.map(ReflectionEntity.fromMap).toList();
  }

  Future<void> clearAll() async {
    final d = await db;
    await d.delete('routiny_tasks');
    await d.delete('focus_sessions');
    await d.delete('reflections');
  }
}
