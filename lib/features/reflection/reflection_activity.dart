import 'package:flutter/material.dart';

import '../../core/ads/interstitial_manager.dart';
import '../../core/app_strings.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import '../care/breathing_exercise_screen.dart';
import '../care/care_article_screen.dart';
import '../care/care_data.dart';
import '../water/water_tracker_screen.dart';
import '../tests/share_result_card.dart';
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
  bool _keepJournal = false; // off by default → entry stays private
  bool _saved = false;
  bool _routineAdopted = false;

  static const _maxPicks = 3;

  void _next() {
    if (_step == 0 && _mood == null) return;
    if (_step == 2) {
      // moving from the journal step to the result → save + show an
      // interstitial (cap 5 min) before revealing the reflection result.
      if (!_saved) _save();
      InterstitialManager.instance.showIfReady(
        InterstitialManager.ctxReflectionResult,
        onDone: () {
          if (mounted) setState(() => _step = 3);
        },
      );
      return;
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
      // only keep the written text if the user opted in
      journal: (_keepJournal && _journal.trim().isNotEmpty)
          ? _journal.trim()
          : null,
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
              Expanded(
                child: Text(S.reflectionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
          Text(S.moodStateQuestion,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 6),
          Text(S.chooseMoodHint,
              style: const TextStyle(
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
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/moods/${m.imageAsset}.png',
                          fit: BoxFit.contain,
                        ),
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
                      SnackBar(content: Text(S.maxChoicesMsg)));
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
          Text(S.feelingsQuestion,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          Text(S.feelingsHint,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 12),
          _chips<Feeling>(feelings, (f) => f.id, (f) => f.emoji,
              (f) => S.localize(f.label, f.labelFusha), _feelings),
          const SizedBox(height: 24),
          Text(S.influencesQuestion,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          Text(S.influencesHint,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 12),
          _chips<Influence>(influences, (f) => f.id, (f) => f.emoji,
              (f) => S.localize(f.label, f.labelFusha), _influences),
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
          Text(S.journalQuestion,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 6),
          Text(S.journalSubtitle,
              style: const TextStyle(
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
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.journalHint,
                hintStyle: const TextStyle(
                    fontFamily: 'Raleway', color: AppColors.hintText),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // optional: keep this entry in "مذكراتي" (off by default = private)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.calendarDayStroke),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(S.keepJournalHint,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepChocolate)),
                ),
                Switch(
                  value: _keepJournal,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.navRipple,
                  inactiveThumbColor: AppColors.ribbonNeutral,
                  onChanged: (v) => setState(() => _keepJournal = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(S.journalSkipHint,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  // result-page palette (1:1 with the Kotlin card drawables)
  static const _darkBtn = Color(0xFF5C3D2E);

  Widget _gradCard({
    required List<Color> colors,
    required double radius,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x33C7745F), width: 1),
      ),
      child: child,
    );
  }

  // header on the right (RTL): emoji first, then the title
  Widget _cardHeader(String title, String emoji) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // start = right in RTL
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _darkBtn)),
      ],
    );
  }

  (String, String) _splitTrailingEmoji(String line) {
    final t = line.trim();
    if (t.isEmpty) return ('💭', t);
    final chars = t.runes.toList();
    // grab trailing non-letter symbol cluster as the emoji
    final last = String.fromCharCode(chars.last);
    final isLetter = RegExp(r'[؀-ۿ\w]').hasMatch(last);
    if (isLetter) return ('💭', t);
    final emoji = last;
    final text = String.fromCharCodes(chars.sublist(0, chars.length - 1)).trim();
    return (emoji, text);
  }

  void _shareReflection(ReflectionResponse r) {
    const moodEmoji = {
      'wonderful': '💗',
      'good': '🤍',
      'okay': '🌿',
      'not_good': '🫂',
      'bad': '💔',
    };
    const url = 'https://play.google.com/store/apps/details?id=com.routiny.app';
    final text = '${S.reflectionShareIntro}\n'
        '${r.empathyTitle}\n\n'
        '${r.insight}\n\n'
        '📲 حمّلي روتيني: $url';
    showShareResultSheet(
      context,
      headline: S.reflectionShareHeadline,
      resultTitle: r.empathyTitle,
      details: r.insight,
      emoji: moodEmoji[_mood] ?? '🌸',
      edge: const Color(0xFFE8A0A0),
      shareText: text,
    );
  }

  Widget _responseStep() {
    final r = generateReflection(_mood ?? 'okay', _feelings, _influences);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      children: [
        _heroCard(r),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // start = right in RTL
          children: [
            const Text('✨', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(S.describeDay,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkBtn)),
          ],
        ),
        const SizedBox(height: 8),
        _dayDescCard(r),
        const SizedBox(height: 14),
        // ── grid: لمحة + نصيحة ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _insightCard(r)),
              const SizedBox(width: 12),
              Expanded(child: _adviceCard(r)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ── grid: روتين + رسالة لك ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _routineCard(r)),
              const SizedBox(width: 12),
              Expanded(child: _supportCard(r)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _activityCard(r),
        const SizedBox(height: 18),
        Center(
          child: Text(S.responseRecorded,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
        ),
        const SizedBox(height: 14),
        // share as a story-size card
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _shareReflection(r),
            icon: const Icon(Icons.ios_share, size: 18, color: _darkBtn),
            label: Text(S.shareResultBtn,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkBtn)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _darkBtn, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkBtn,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            child: Text(S.okBtn,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── hero empathy card ──
  Widget _heroCard(ReflectionResponse r) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF5EB), Color(0xFFF5DCC9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33C7745F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: Text(r.empathyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _darkBtn)),
        ),
      ),
    );
  }

  // ── وصف يومك: emoji-bubble rows with hairline dividers ──
  Widget _dayDescCard(ReflectionResponse r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE0D6)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < r.dayDescription.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0x14000000)),
            Builder(builder: (_) {
              final (emoji, text) = _splitTrailingEmoji(r.dayDescription[i]);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    // emoji bubble on the right, before the text
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCEFE3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(text,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.deepChocolate)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _insightCard(ReflectionResponse r) {
    return _gradCard(
      colors: const [Color(0xFFFFF1E6), Color(0xFFF8E2D0)],
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader('لمحة', '💡'),
          const SizedBox(height: 8),
          Text(r.insight,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.deepChocolate)),
        ],
      ),
    );
  }

  Widget _adviceCard(ReflectionResponse r) {
    return _gradCard(
      colors: const [Color(0xFFEFF1E1), Color(0xFFE2E8D0)],
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader('نصيحة', '🌿'),
          const SizedBox(height: 8),
          Text(r.advice,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.deepChocolate)),
        ],
      ),
    );
  }

  Widget _supportCard(ReflectionResponse r) {
    return _gradCard(
      colors: const [Color(0xFFFFEFE3), Color(0xFFF5D8C6)],
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader('رسالة لك', '💌'),
          const SizedBox(height: 10),
          Text(r.supportMessage,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 6),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text('💗', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _routineCard(ReflectionResponse r) {
    return _gradCard(
      colors: const [Color(0xFFEBE2EE), Color(0xFFDDD0E5)],
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader('روتين مقترح', '📋'),
          const SizedBox(height: 10),
          for (final item in r.routine)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  const Text('• ',
                      style: TextStyle(color: _darkBtn, fontSize: 13)),
                  Expanded(
                    child: Text(item,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.deepChocolate)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: _routineAdopted
                  ? null
                  : () async {
                      await AppDatabase.instance.insertTask(TaskEntity(
                        title: 'روتين حاسة بإيه',
                        iconResName: 'ic_routiny_sparkles',
                        colorHex: '#C7745F',
                        subTasks: r.routine,
                        date: ymd(DateTime.now()),
                      ));
                      await RoutinyStats.recordTaskCreation();
                      if (!mounted) return;
                      setState(() => _routineAdopted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.routineAddedSnack)));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2818), // heavier
                disabledBackgroundColor:
                    const Color(0xFF3E2818).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Text(_routineAdopted ? 'تمت الإضافة ✓' : 'اعتمدي الروتين ✓',
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(ReflectionResponse r) {
    final rest = r.activityAction == ReflectionActivityAction.justRest;
    return _gradCard(
      colors: const [Color(0xFFFFF7EE), Color(0xFFF5E4D2)],
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(r.activityEmoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(r.activityTitle,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate)),
                const SizedBox(height: 4),
                Text(r.activityDescription,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.secondaryText)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
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
                                  builder: (_) =>
                                      const WaterTrackerScreen()));
                          break;
                        case ReflectionActivityAction.openCareArticle:
                          final card = r.articleKey == null
                              ? null
                              : careCardForArticle(r.articleKey!);
                          if (card != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CareArticleScreen(
                                          card: card,
                                          accent: const Color(0xFFE8A0A0),
                                          cardAspect: 280 / 220,
                                        )));
                          }
                          break;
                        default:
                          break;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // same family as the card, just a bit heavier
                      backgroundColor: const Color(0xFFE6C9A4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                      elevation: 0,
                    ),
                    child: Text(rest ? S.restBtn : S.startNowBtn,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5C3D2E))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _canNext {
    if (_step == 0) return _mood != null;
    if (_step == 1) return _feelings.length == 3 && _influences.length == 3;
    return true;
  }

  Widget _bottomBar() {
    final canNext = _canNext;
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
