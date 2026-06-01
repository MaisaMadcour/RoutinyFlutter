import 'database.dart';
import 'models.dart';
import 'prefs.dart';

/// Seeds 6 starter tasks on first launch. They live on every day
/// (`date = ''`) and stay around until the user manually deletes them —
/// adding new tasks does NOT wipe them.
class RoutinyDefaults {
  RoutinyDefaults._();

  static const _kSeeded = 'defaults_seeded';
  static const _kSeededV2 = 'defaults_seeded_v2';
  static const _kV1Ids = 'defaults_ids';

  static List<TaskEntity> _build() => [
        TaskEntity(
            title: 'اشرب ماء',
            iconResName: 'opacity',
            colorHex: '#9DCCE7',
            time: '08:00',
            subTasks: ['كوب الصباح', 'كوب الظهر', 'كوب المساء']),
        TaskEntity(
            title: 'تمارين',
            iconResName: 'fitness_center',
            colorHex: '#FFA464',
            time: '09:00',
            subTasks: ['إحماء', 'تمارين قوة', 'تمدد']),
        TaskEntity(
            title: 'قراءة',
            iconResName: 'menu_book',
            colorHex: '#5F4031',
            time: '10:30',
            subTasks: ['10 صفحات', 'تلخيص ما قرأت']),
        TaskEntity(
            title: 'تأمل',
            iconResName: 'self_improvement',
            colorHex: '#244E2C',
            time: '12:00',
            subTasks: ['تنفس عميق', 'تأمل 5 دقائق']),
        TaskEntity(
            title: 'مشي',
            iconResName: 'directions_walk',
            colorHex: '#9EB2BB',
            time: '17:00',
            subTasks: ['20 دقيقة في الهواء الطلق']),
        TaskEntity(
            title: 'نوم مبكر',
            iconResName: 'brightness_3',
            colorHex: '#BFB14B',
            time: '22:00',
            subTasks: ['اغلق الشاشات', 'حضّر السرير']),
      ];

  static Future<void> seedIfNeeded() async {
    if (Prefs.I.getBool(_kSeededV2)) return;
    // Migrate any V1 defaults: their ids were stored under 'defaults_ids'.
    // Delete them so they don't linger with a stale specific date.
    for (final id in Prefs.I.getList(_kV1Ids)) {
      final n = int.tryParse(id);
      if (n != null) await AppDatabase.instance.deleteTask(n);
    }
    for (final t in _build()) {
      await AppDatabase.instance.insertTask(t);
    }
    await Prefs.I.setBool(_kSeeded, true);
    await Prefs.I.setBool(_kSeededV2, true);
    await Prefs.I.setList(_kV1Ids, []);
  }

  // Kept for backwards source compatibility; defaults are no longer cleared.
  static Future<void> clearIfActive() async {}
}
