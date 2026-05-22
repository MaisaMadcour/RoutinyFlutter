/// Builds the full reflection response (empathy + insight + advice + routine
/// + support message + suggested activity).
///
/// Ported verbatim from the Android Kotlin source
/// (`com.gpstracker.routiny.reflection.ReflectionResponseGenerator`).
/// All Arabic text is preserved exactly.
///
/// ignore_for_file: unused_import
import 'reflection_models.dart';
import 'reflection_scenarios.dart';

/// الإجراء المرتبط بالاقتراح (بيفتح شاشة معيّنة).
enum ReflectionActivityAction {
  openBreathing,
  openCareArticle,
  openWater,
  openFocus,
  justRest,
}

class ReflectionResponse {
  final String empathyTitle;
  final List<String> dayDescription;
  final String insight;
  final String advice;
  final List<String> routine;
  final String supportMessage;
  final String activityTitle;
  final String activityDescription;
  final String activityEmoji;
  final ReflectionActivityAction activityAction;

  const ReflectionResponse({
    required this.empathyTitle,
    required this.dayDescription,
    required this.insight,
    required this.advice,
    required this.routine,
    required this.supportMessage,
    required this.activityTitle,
    required this.activityDescription,
    required this.activityEmoji,
    required this.activityAction,
  });
}

/// عنوان الإمباثي حسب المزاج.
String _empathyTitle(String moodId) {
  switch (moodId) {
    case 'wonderful':
      return 'يومك حلو 💗';
    case 'good':
      return 'يبدو إنّك بخير 🤍';
    case 'okay':
      return 'يوم عادي… ومفيش غلط 🌿';
    case 'not_good':
      return 'يومك تقيل شوية 🫂';
    case 'bad':
      return 'اليوم كان صعب 💔';
    default:
      return '';
  }
}

class _Activity {
  final String title;
  final String description;
  final String emoji;
  final ReflectionActivityAction action;
  const _Activity(this.title, this.description, this.emoji, this.action);
}

/// اختيار النشاط المقترح — أول قاعدة تتطابق هي الفائزة.
_Activity _pickActivity(
  String moodId,
  Set<String> feelings,
  Set<String> influences,
) {
  if (feelings.contains('anxious') || feelings.contains('overwhelmed')) {
    return const _Activity(
      'تمرين تنفّس قصير',
      '5 دقايق تنفّس عميق هيهدّوا الجهاز العصبي ويفصلوكِ عن الضوضاء.',
      '🌬️',
      ReflectionActivityAction.openBreathing,
    );
  }
  if (feelings.contains('sad') || feelings.contains('lonely')) {
    return const _Activity(
      'مقال عناية يلمسك',
      'كلمات هتفكّرك إنّك مش لوحدك في الإحساس ده.',
      '📖',
      ReflectionActivityAction.openCareArticle,
    );
  }
  if (feelings.contains('angry') || feelings.contains('frustrated')) {
    return const _Activity(
      'تنفّس + سكتة قصيرة',
      'قبل ما تردّي على أي حاجة، خدي 5 دقايق تنفّس واهدي.',
      '🌬️',
      ReflectionActivityAction.openBreathing,
    );
  }
  if (feelings.contains('unmotivated') || feelings.contains('bored')) {
    return const _Activity(
      'خطوة صغيرة',
      'ابدأي بكاسة ميه دلوقتي. خطوة صغيرة بتفتح طاقة جديدة.',
      '💧',
      ReflectionActivityAction.openWater,
    );
  }
  if (feelings.contains('confused')) {
    return const _Activity(
      'خدي وقتك',
      'مش لازم تلاقي إجابة دلوقتي. اشربي ميه وفكّري ببطء.',
      '💧',
      ReflectionActivityAction.openWater,
    );
  }
  if (feelings.contains('exhausted') || feelings.contains('tired')) {
    return const _Activity(
      'ارتاحي شوية',
      'مش لازم تنجزي حاجة النهارده. اشربي ميه واستلقي بهدوء.',
      '🫂',
      ReflectionActivityAction.justRest,
    );
  }
  if (feelings.contains('grateful') ||
      feelings.contains('hopeful') ||
      feelings.contains('proud')) {
    return const _Activity(
      'مقال يوازن إحساسك',
      'اقري كلمات صغيرة بتدّعمك وتثبّت الإحساس الحلو ده.',
      '📖',
      ReflectionActivityAction.openCareArticle,
    );
  }
  if (feelings.contains('calm')) {
    return const _Activity(
      'تنفّس هادي',
      'دقايق تنفّس بسيطة هتثبّت الهدوء اللي حاسة بيه.',
      '🌬️',
      ReflectionActivityAction.openBreathing,
    );
  }

  if (influences.contains('health') || influences.contains('sleep')) {
    return const _Activity(
      'اشربي كاسة ميه',
      'تبدأي بحاجة بسيطة هتساعد جسمك يستعيد طاقته.',
      '💧',
      ReflectionActivityAction.openWater,
    );
  }

  switch (moodId) {
    case 'wonderful':
    case 'good':
      return const _Activity(
        'كاسة ميه دافية',
        'بداية صغيرة تخلّي يومك يكمّل بنفس الطاقة.',
        '💧',
        ReflectionActivityAction.openWater,
      );
    case 'okay':
      return const _Activity(
        'كاسة ميه + تنفّس',
        'بداية بسيطة تعيد للجسم توازنه.',
        '💧',
        ReflectionActivityAction.openWater,
      );
    case 'not_good':
      return const _Activity(
        'تمرين تنفّس قصير',
        'خدي 5 دقايق لنفسك. الجهاز العصبي محتاج break.',
        '🌬️',
        ReflectionActivityAction.openBreathing,
      );
    case 'bad':
    default:
      return const _Activity(
        'ارتاحي شوية',
        'مش لازم تنجزي حاجة النهارده. اشربي ميه واستلقي بهدوء.',
        '🫂',
        ReflectionActivityAction.justRest,
      );
  }
}

/// اختيار السيناريو الأقرب بناءً على التداخل في الـ feelings/influences.
ReflectionScenario _matchScenario(
  String moodId,
  Set<String> feelings,
  Set<String> influences,
) {
  final sameMood =
      reflectionScenarios.where((s) => s.moodId == moodId).toList();
  if (sameMood.isEmpty) {
    return reflectionScenarios.firstWhere((s) => s.moodId == moodId);
  }
  ReflectionScenario best = sameMood.first;
  int bestScore = -1;
  for (final s in sameMood) {
    final score = s.matchFeelings.intersection(feelings).length * 2 +
        s.matchInfluences.intersection(influences).length;
    if (score > bestScore) {
      bestScore = score;
      best = s;
    }
  }
  return best;
}

/// يبني الرد الكامل للانعكاس.
ReflectionResponse generateReflection(
  String moodId,
  Set<String> feelingIds,
  Set<String> influenceIds,
) {
  final scenario = _matchScenario(moodId, feelingIds, influenceIds);
  final activity = _pickActivity(moodId, feelingIds, influenceIds);
  return ReflectionResponse(
    empathyTitle: _empathyTitle(moodId),
    dayDescription: scenario.dayDescription,
    insight: scenario.insight,
    advice: scenario.advice,
    routine: scenario.routine,
    supportMessage: scenario.supportMessage,
    activityTitle: activity.title,
    activityDescription: activity.description,
    activityEmoji: activity.emoji,
    activityAction: activity.action,
  );
}
