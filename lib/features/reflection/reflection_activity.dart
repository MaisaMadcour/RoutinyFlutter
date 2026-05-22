import 'package:flutter/material.dart';

import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_defaults.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import '../care/breathing_exercise_screen.dart';
import '../water/water_tracker_screen.dart';
import 'reflection_models.dart';
import 'reflection_response.dart';

class ReflectionActivity extends StatefulWidget {
  const ReflectionActivity({super.key});

  @override
  State<ReflectionActivity> createState() => _ReflectionActivityState();
}

class _ReflectionActivityState extends State<ReflectionActivity> {
  int _step = 0;
  String? _mood;
  final Set<String> _feelings = {};
  final Set<String> _influences = {};
  String _journal = '';
  bool _saved = false;

  static const _maxPicks = 3;

  void _next() {
    if (_step == 0 && _mood == null) return;
    if (_step == 2 && !_saved) {
      _save();
    }
    setState(() => _step = (_step + 1).clamp(0, 3));
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _save() async {
    _saved = true;
    await AppDatabase.instance.insertReflection(ReflectionEntity(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      mood: _mood ?? 'okay',
      feelings: _feelings.join(','),
      influences: _influences.join(','),
      journal: _journal.trim().isEmpty ? null : _journal.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _body()),
            if (_step != 3) _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              const Expanded(
                child: Text('حاسة بإيه النهاردة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close, color: AppColors.deepChocolate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: 22,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _step
                        ? AppColors.primary
                        : AppColors.calendarDayStroke,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _moodStep();
      case 1:
        return _feelingsStep();
      case 2:
        return _journalStep();
      default:
        return _responseStep();
    }
  }

  Widget _moodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('ما حالتك المزاجية اليوم؟',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 6),
          const Text('اختاري الأقرب لإحساسك',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final m in kMoods)
                GestureDetector(
                  onTap: () => setState(() {
                    _mood = m.id;
                    _feelings.clear();
                    _influences.clear();
                  }),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _mood == m.id
                              ? AppColors.secondary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _mood == m.id
                                ? AppColors.primary
                                : AppColors.calendarDayStroke,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(m.emoji,
                            style: const TextStyle(fontSize: 44)),
                      ),
                      const SizedBox(height: 6),
                      Text(m.label,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepChocolate)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chips<T>(
    List<T> items,
    String Function(T) id,
    String Function(T) emoji,
    String Function(T) label,
    Set<String> selected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final it in items)
          GestureDetector(
            onTap: () {
              final i = id(it);
              setState(() {
                if (selected.contains(i)) {
                  selected.remove(i);
                } else if (selected.length < _maxPicks) {
                  selected.add(i);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أقصى 3 اختيارات')));
                }
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected.contains(id(it))
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.calendarDayStroke),
              ),
              child: Text('${emoji(it)} ${label(it)}',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: selected.contains(id(it))
                          ? Colors.white
                          : AppColors.deepChocolate)),
            ),
          ),
      ],
    );
  }

  Widget _feelingsStep() {
    final feelings = feelingsForMood(_mood ?? 'okay');
    final influences = influencesForMood(_mood ?? 'okay');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('كيف تصفي شعورك اليوم؟',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const Text('اختاري حتى 3',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 12),
          _chips<Feeling>(feelings, (f) => f.id, (f) => f.emoji,
              (f) => f.label, _feelings),
          const SizedBox(height: 24),
          const Text('إيه اللي مؤثّر عليكي اليوم؟',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const Text('اختاري حتى 3',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 12),
          _chips<Influence>(influences, (f) => f.id, (f) => f.emoji,
              (f) => f.label, _influences),
        ],
      ),
    );
  }

  Widget _journalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('عايزة تزيحيها عن صدرك؟ ✍️',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 6),
          const Text('استرخي — ده اختياري لكنّه هيساعدك.',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 16),
          Container(
            height: 280,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.calendarDayStroke),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              onChanged: (v) => _journal = v,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 15,
                  color: AppColors.deepChocolate),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'ابدأي بتدوين مشاعرك...',
                hintStyle: TextStyle(
                    fontFamily: 'Raleway', color: AppColors.hintText),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('مش لازم — تقدري تتخطّى وتشوفي الرد',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Widget _responseStep() {
    final r = generateReflection(_mood ?? 'okay', _feelings, _influences);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _respCard(const Color(0xFFFBE3D9),
            child: Column(
              children: [
                const Text('🤍', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 8),
                Text(r.empathyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate)),
              ],
            )),
        _titledCard('✨ وصف يومك', r.dayDescription.join('\n')),
        _titledCard('💡 لمحة', r.insight),
        _titledCard('🌿 نصيحة', r.advice),
        _routineCard(r),
        _titledCard('💌 رسالة لك', r.supportMessage),
        _activityCard(r),
        const SizedBox(height: 8),
        const Center(
          child: Text('إحساسك النهاردة اتسجّل ✨',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('تمام 💗',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _respCard(Color color, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _titledCard(String title, String body) {
    return _respCard(AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 8),
            Text(body,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.deepChocolate)),
          ],
        ));
  }

  Widget _routineCard(ReflectionResponse r) {
    return _respCard(AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 روتين مقترح',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 8),
            for (final item in r.routine)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(color: AppColors.primary)),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.deepChocolate)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saved
                    ? null
                    : () async {
                        await RoutinyDefaults.clearIfActive();
                        await AppDatabase.instance.insertTask(TaskEntity(
                          title: 'روتين حاسة بإيه',
                          iconResName: 'ic_routiny_sparkles',
                          colorHex: '#C7745F',
                          subTasks: r.routine,
                          date: ymd(DateTime.now()),
                        ));
                        await RoutinyStats.recordTaskCreation();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'اتضافت كمهمة في صفحة الروتين 💗')));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('اعتمدي الروتين ✓',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ));
  }

  Widget _activityCard(ReflectionResponse r) {
    final rest = r.activityAction == ReflectionActivityAction.justRest;
    return _respCard(const Color(0xFFEFE3D6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${r.activityEmoji}  ${r.activityTitle}',
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 6),
            Text(r.activityDescription,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                switch (r.activityAction) {
                  case ReflectionActivityAction.openBreathing:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const BreathingExerciseScreen()));
                    break;
                  case ReflectionActivityAction.openWater:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WaterTrackerScreen()));
                    break;
                  default:
                    break;
                }
              },
              child: Text(rest ? 'تمام، خدي وقتك 💗' : 'ابدأي دلوقتي ←',
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ],
        ));
  }

  Widget _bottomBar() {
    final canNext = _step != 0 || _mood != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_step != 0)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: _back,
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: AppColors.calendarDayStroke),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('السابق',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          color: AppColors.deepChocolate)),
                ),
              ),
            ),
          if (_step != 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: canNext ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('التالي',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
