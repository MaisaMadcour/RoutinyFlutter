import 'database.dart';
import 'models.dart';
import 'prefs.dart';

/// Seeds 6 starter tasks on first launch. They appear only on the
/// installation day (specific date) so they don't clutter every future day.
class RoutinyDefaults {
  RoutinyDefaults._();

  static const _kSeeded = 'defaults_seeded';
  static const _kSeededV2 = 'defaults_seeded_v2';
  static const _kSeededV3 = 'defaults_seeded_v3';
  static const _kV1Ids = 'defaults_ids';

  // The exact titles of the 6 seed tasks — used for the V3 migration.
  static const _seedTitles = [
    'اشرب ماء', 'تمارين', 'قراءة', 'تأمل', 'مشي', 'نوم مبكر',
  ];

  static String _todayYmd() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static List<TaskEntity> _build() {
    final today = _todayYmd();
    return [
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
  }

  static Future<void> seedIfNeeded() async {
    // ── V2: first-ever seed ─────────────────────────────────────────────────
    if (!Prefs.I.getBool(_kSeededV2)) {
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
      // Mark V3 done too so the migration below doesn't run on a fresh install.
      await Prefs.I.setBool(_kSeededV3, true);
      return;
    }

    // ── V3: fix existing installs where seed tasks had date='' (every day) ──
    // Matches by title so only the known defaults are touched, leaving any
    // user-created "يومياً" tasks with date='' untouched.
    if (!Prefs.I.getBool(_kSeededV3)) {
      final today = _todayYmd();
      final all = await AppDatabase.instance.allTasks();
      for (final task in all) {
        if (task.date == '' && _seedTitles.contains(task.title)) {
          task.date = today;
          await AppDatabase.instance.updateTask(task);
        }
      }
      await Prefs.I.setBool(_kSeededV3, true);
    }
  }

  // Kept for backwards source compatibility; defaults are no longer cleared.
  static Future<void> clearIfActive() async {}
}
