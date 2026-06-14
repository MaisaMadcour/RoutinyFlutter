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
  final String? articleKey; // care article to open for openCareArticle

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
    this.articleKey,
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
  final String? articleKey;
  const _Activity(this.title, this.description, this.emoji, this.action,
      [this.articleKey]);
}

/// A care article + a short framing line, chosen to fit the mood/feelings.
const _article = ReflectionActivityAction.openCareArticle;
_Activity _articleActivity(String title, String desc, String key) =>
    _Activity(title, desc, '📖', _article, key);

/// اختيار النشاط المقترح — أول قاعدة تتطابق هي الفائزة.
_Activity _pickActivity(
  String moodId,
  Set<String> feelings,
  Set<String> influences,
) {
  // each result opens a real care article that fits the feeling/mood
  if (feelings.contains('anxious') || feelings.contains('overwhelmed')) {
    return _articleActivity('مقال يهدّيكي',
        'كلمات بسيطة تفكّرك إن الراحة حقّك مش رفاهية.', 'care_talks_2');
  }
  if (feelings.contains('sad') || feelings.contains('lonely')) {
    return _articleActivity('مقال يلمس قلبك',
        'كلمات هتفكّرك إنّك مش لوحدك في الإحساس ده.', 'care_talks_2');
  }
  if (feelings.contains('angry') || feelings.contains('frustrated')) {
    return _articleActivity('مقال يهدّي أفكارك',
        'قبل ما تردّي على أي حاجة، اقري كلمات بتساعدك تهدي.',
        'care_self_1');
  }
  if (feelings.contains('guilty')) {
    return _articleActivity('مقال عن الشعور بالذنب',
        'مش كل ذنب حقيقي… اقري ده وكوني ألطف مع نفسك.', 'care_talks_3');
  }
  if (feelings.contains('unmotivated') || feelings.contains('bored')) {
    return _articleActivity('مقال يرجّعلك حماسك',
        'سر الاستمرار مش الحماس — اقري إزاي تكمّلي بهدوء.',
        'care_prod_4');
  }
  if (feelings.contains('confused')) {
    return _articleActivity('مقال ينظّم أفكارك',
        'مش لازم تلاقي إجابة دلوقتي. اقري إزاي تبني روتين يناسبك.',
        'care_prod_1');
  }
  if (feelings.contains('exhausted') || feelings.contains('tired')) {
    return _articleActivity('مقال يديكي راحة',
        'الراحة مش كسل — اقري ده وارتاحي من غير تأنيب.', 'care_talks_2');
  }
  if (feelings.contains('strong')) {
    return _articleActivity('مقال يكمّل قوّتك',
        'ازاي تكوني قوية وناعمة في نفس الوقت.', 'care_sleep_6');
  }
  if (feelings.contains('grateful') ||
      feelings.contains('hopeful') ||
      feelings.contains('proud')) {
    return _articleActivity('مقال يثبّت إحساسك الحلو',
        'اقري كلمات بتدعمك وتخليكي نسخة أفضل من نفسك.',
        'care_sleep_2');
  }
  if (feelings.contains('calm')) {
    return _articleActivity('مقال يكمّل هدوءك',
        'روتين بسيط لحياة أكثر هدوء وسكينة.', 'care_self_1');
  }

  // mood fallback
  switch (moodId) {
    case 'wonderful':
    case 'good':
      return _articleActivity('مقال يكمّل طاقتك',
          'قوة العادات الصغيرة في تغيير حياتك.', 'care_sleep_3');
    case 'okay':
      return _articleActivity('مقال يبدأ يومك',
          'ازاي تبني روتين يناسبك من غير ما يضغطك.', 'care_prod_1');
    case 'not_good':
      return _articleActivity('مقال يخفّف عنك',
          'الراحة حقّك — اقري ده وكوني لطيفة مع نفسك.', 'care_talks_2');
    case 'bad':
    default:
      return _articleActivity('مقال يحتويكي',
          'مش لازم تنجزي حاجة النهاردة. اقري كلمات بتطمّنك.',
          'care_talks_2');
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
    articleKey: activity.articleKey,
  );
}
