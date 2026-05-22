import 'dart:convert';

/// A routine task — mirrors Android's TaskEntity (Room table `routiny_tasks`).
class TaskEntity {
  int id;
  String title;
  String iconResName;
  String colorHex;
  List<String> subTasks;
  String date; // yyyy-MM-dd
  String time; // HH:mm
  bool hasReminder;
  String timeRange;

  TaskEntity({
    this.id = 0,
    required this.title,
    this.iconResName = 'star',
    this.colorHex = '#BC8A7B',
    List<String>? subTasks,
    this.date = '',
    this.time = '',
    this.hasReminder = false,
    this.timeRange = '',
  }) : subTasks = subTasks ?? [];

  Map<String, Object?> toMap() => {
        if (id != 0) 'id': id,
        'title': title,
        'iconResName': iconResName,
        'colorHex': colorHex,
        'subTasks': jsonEncode(subTasks),
        'date': date,
        'time': time,
        'hasReminder': hasReminder ? 1 : 0,
        'timeRange': timeRange,
      };

  factory TaskEntity.fromMap(Map<String, Object?> m) => TaskEntity(
        id: m['id'] as int? ?? 0,
        title: m['title'] as String? ?? '',
        iconResName: m['iconResName'] as String? ?? 'star',
        colorHex: m['colorHex'] as String? ?? '#BC8A7B',
        subTasks: _decodeList(m['subTasks']),
        date: m['date'] as String? ?? '',
        time: m['time'] as String? ?? '',
        hasReminder: (m['hasReminder'] as int? ?? 0) == 1,
        timeRange: m['timeRange'] as String? ?? '',
      );

  static List<String> _decodeList(Object? v) {
    if (v == null) return [];
    try {
      final d = jsonDecode(v as String);
      if (d is List) return d.map((e) => e.toString()).toList();
    } catch (_) {}
    return [];
  }
}

/// A completed focus / pomodoro session — mirrors FocusSessionEntity.
class FocusSessionEntity {
  int id;
  int? taskId;
  String taskTitle;
  int startTime;
  int endTime;
  int durationSec;
  int plannedDurationSec;
  String type; // focus / short_break / long_break
  bool completed;
  int pomodoroNumber;

  FocusSessionEntity({
    this.id = 0,
    this.taskId,
    this.taskTitle = 'تركيز',
    required this.startTime,
    required this.endTime,
    required this.durationSec,
    required this.plannedDurationSec,
    this.type = 'focus',
    this.completed = false,
    this.pomodoroNumber = 1,
  });

  Map<String, Object?> toMap() => {
        if (id != 0) 'id': id,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'startTime': startTime,
        'endTime': endTime,
        'durationSec': durationSec,
        'plannedDurationSec': plannedDurationSec,
        'type': type,
        'completed': completed ? 1 : 0,
        'pomodoroNumber': pomodoroNumber,
      };

  factory FocusSessionEntity.fromMap(Map<String, Object?> m) => FocusSessionEntity(
        id: m['id'] as int? ?? 0,
        taskId: m['taskId'] as int?,
        taskTitle: m['taskTitle'] as String? ?? 'تركيز',
        startTime: m['startTime'] as int? ?? 0,
        endTime: m['endTime'] as int? ?? 0,
        durationSec: m['durationSec'] as int? ?? 0,
        plannedDurationSec: m['plannedDurationSec'] as int? ?? 0,
        type: m['type'] as String? ?? 'focus',
        completed: (m['completed'] as int? ?? 0) == 1,
        pomodoroNumber: m['pomodoroNumber'] as int? ?? 1,
      );
}

/// A reflection entry — mirrors ReflectionEntity (Room table `reflections`).
class ReflectionEntity {
  int id;
  int timestamp;
  String mood;
  String feelings; // csv ids
  String influences; // csv ids
  String? journal;

  ReflectionEntity({
    this.id = 0,
    required this.timestamp,
    required this.mood,
    this.feelings = '',
    this.influences = '',
    this.journal,
  });

  Map<String, Object?> toMap() => {
        if (id != 0) 'id': id,
        'timestamp': timestamp,
        'mood': mood,
        'feelings': feelings,
        'influences': influences,
        'journal': journal,
      };

  factory ReflectionEntity.fromMap(Map<String, Object?> m) => ReflectionEntity(
        id: m['id'] as int? ?? 0,
        timestamp: m['timestamp'] as int? ?? 0,
        mood: m['mood'] as String? ?? 'okay',
        feelings: m['feelings'] as String? ?? '',
        influences: m['influences'] as String? ?? '',
        journal: m['journal'] as String?,
      );
}
