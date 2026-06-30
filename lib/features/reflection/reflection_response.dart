/// Builds the full reflection response (empathy + insight + advice + routine
/// + support message + suggested activity).
///
/// Ported verbatim from the Android Kotlin source
/// (`com.gpstracker.routiny.reflection.ReflectionResponseGenerator`).
/// All Arabic text is preserved exactly.
///
/// ignore_for_file: unused_import
import '../../core/app_strings.dart';
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
    case 'wonderful': return S.empathyWonderful;
    case 'good':      return S.empathyGood;
    case 'okay':      return S.empathyOkay;
    case 'not_good':  return S.empathyNotGood;
    case 'bad':       return S.empathyBad;
    default:          return '';
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
    return _articleActivity(S.actSoothingArticle, S.actSoothingDesc, 'care_talks_2');
  }
  if (feelings.contains('sad') || feelings.contains('lonely')) {
    return _articleActivity(S.actHeartArticle, S.actHeartDesc, 'care_talks_2');
  }
  if (feelings.contains('angry') || feelings.contains('frustrated')) {
    return _articleActivity(S.actThoughtsArticle, S.actThoughtsDesc, 'care_self_1');
  }
  if (feelings.contains('guilty')) {
    return _articleActivity(S.actGuiltArticle, S.actGuiltDesc, 'care_talks_3');
  }
  if (feelings.contains('unmotivated') || feelings.contains('bored')) {
    return _articleActivity(S.actMotivationArticle, S.actMotivationDesc, 'care_prod_4');
  }
  if (feelings.contains('confused')) {
    return _articleActivity(S.actOrganizeArticle, S.actOrganizeDesc, 'care_prod_1');
  }
  if (feelings.contains('exhausted') || feelings.contains('tired')) {
    return _articleActivity(S.actRestArticle, S.actRestDesc, 'care_talks_2');
  }
  if (feelings.contains('strong')) {
    return _articleActivity(S.actStrongArticle, S.actStrongDesc, 'care_sleep_6');
  }
  if (feelings.contains('grateful') ||
      feelings.contains('hopeful') ||
      feelings.contains('proud')) {
    return _articleActivity(S.actGratefulArticle, S.actGratefulDesc, 'care_sleep_2');
  }
  if (feelings.contains('calm')) {
    return _articleActivity(S.actCalmArticle, S.actCalmDesc, 'care_self_1');
  }

  // mood fallback
  switch (moodId) {
    case 'wonderful':
    case 'good':
      return _articleActivity(S.actEnergyArticle, S.actEnergyDesc, 'care_sleep_3');
    case 'okay':
      return _articleActivity(S.actStartArticle, S.actStartDesc, 'care_prod_1');
    case 'not_good':
      return _articleActivity(S.actLightenArticle, S.actLightenDesc, 'care_talks_2');
    case 'bad':
    default:
      return _articleActivity(S.actHoldArticle, S.actHoldDesc, 'care_talks_2');
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
  final useFusha = S.isFusha;
  return ReflectionResponse(
    empathyTitle: _empathyTitle(moodId),
    dayDescription: useFusha && scenario.dayDescriptionFusha.isNotEmpty
        ? scenario.dayDescriptionFusha
        : scenario.dayDescription,
    insight: S.localize(scenario.insight, scenario.insightFusha),
    advice: S.localize(scenario.advice, scenario.adviceFusha),
    routine: useFusha && scenario.routineFusha.isNotEmpty
        ? scenario.routineFusha
        : scenario.routine,
    supportMessage: S.localize(scenario.supportMessage, scenario.supportMessageFusha),
    activityTitle: activity.title,
    activityDescription: activity.description,
    activityEmoji: activity.emoji,
    activityAction: activity.action,
    articleKey: activity.articleKey,
  );
}
