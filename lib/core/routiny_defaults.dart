import 'database.dart';
import 'models.dart';
import 'prefs.dart';
import 'routiny_stats.dart';

/// Seeds 6 starter tasks on first launch; they vanish when the user
/// creates their first own task. Mirrors Android RoutinyDefaults.
class RoutinyDefaults {
  RoutinyDefaults._();

  static const _kSeeded = 'defaults_seeded';
  static const _kActive = 'defaults_active';
  static const _kIds = 'defaults_ids';

  static List<TaskEntity> _starters(String today) => [
        TaskEntity(
            title: 'اشرب ماء',
            iconResName: 'opacity',
            colorHex: '#9DCCE7',
            time: '08:00',
            date: today,
            subTasks: ['كوب الصباح', 'كوب الظهر', 'كوب المساء']),
        TaskEntity(
            title: 'تمارين',
            iconResName: 'fitness_center',
            colorHex: '#FFA464',
            time: '09:00',
            date: today,
            subTasks: ['إحماء', 'تمارين قوة', 'تمدد']),
        TaskEntity(
            title: 'قراءة',
            iconResName: 'menu_book',
            colorHex: '#5F4031',
            time: '10:30',
            date: today,
            subTasks: ['10 صفحات', 'تلخيص ما قرأت']),
        TaskEntity(
            title: 'تأمل',
            iconResName: 'self_improvement',
            colorHex: '#244E2C',
            time: '12:00',
            date: today,
            subTasks: ['تنفس عميق', 'تأمل 5 دقائق']),
        TaskEntity(
            title: 'مشي',
            iconResName: 'directions_walk',
            colorHex: '#9EB2BB',
            time: '17:00',
            date: today,
            subTasks: ['20 دقيقة في الهواء الطلق']),
        TaskEntity(
            title: 'نوم مبكر',
            iconResName: 'brightness_3',
            colorHex: '#BFB14B',
            time: '22:00',
            date: today,
            subTasks: ['اغلق الشاشات', 'حضّر السرير']),
      ];

  static Future<void> seedIfNeeded() async {
    if (Prefs.I.getBool(_kSeeded)) return;
    final today = ymd(DateTime.now());
    final ids = <String>[];
    for (final t in _starters(today)) {
      final id = await AppDatabase.instance.insertTask(t);
      ids.add('$id');
    }
    await Prefs.I.setBool(_kSeeded, true);
    await Prefs.I.setBool(_kActive, true);
    await Prefs.I.setList(_kIds, ids);
  }

  /// Called before inserting the user's first own task — removes the seeds.
  static Future<void> clearIfActive() async {
    if (!Prefs.I.getBool(_kActive)) return;
    for (final id in Prefs.I.getList(_kIds)) {
      final n = int.tryParse(id);
      if (n != null) await AppDatabase.instance.deleteTask(n);
    }
    await Prefs.I.setBool(_kActive, false);
    await Prefs.I.setList(_kIds, []);
  }
}
