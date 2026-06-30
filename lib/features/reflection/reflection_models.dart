/// Data models for the Reflection feature.
///
/// Ported verbatim from the Android Kotlin source
/// (`com.gpstracker.routiny.reflection.ReflectionModels`).
/// All Arabic text is preserved exactly.
// ignore_for_file: unused_import

/// المزاج العام لليوم.
class Mood {
  final String id; // wonderful/good/okay/not_good/bad
  final String emoji;
  final String label;
  final String imageAsset; // drawable name, e.g. mood_wonderful
  const Mood(this.id, this.emoji, this.label, this.imageAsset);
}

const kMoods = <Mood>[
  Mood('wonderful', '😄', 'رائعة', 'mood_wonderful'),
  Mood('good', '🙂', 'جيدة', 'mood_good'),
  Mood('okay', '😐', 'متوسطة', 'mood_okay'),
  Mood('not_good', '😔', 'ليست جيدة', 'mood_not_good'),
  Mood('bad', '😢', 'سيئة', 'mood_bad'),
];

Mood? moodById(String? id) {
  for (final m in kMoods) {
    if (m.id == id) return m;
  }
  return null;
}

/// المشاعر اللي ممكن المستخدمة تختار منها.
class Feeling {
  final String id;
  final String emoji;
  final String label;
  final String labelFusha;
  const Feeling(this.id, this.emoji, this.label, {this.labelFusha = ''});
}

const kFeelings = <Feeling>[
  // إيجابية
  Feeling('happy', '😊', 'سعيدة'),
  Feeling('grateful', '🤍', 'ممتنّة'),
  Feeling('proud', '✨', 'فخورة'),
  Feeling('hopeful', '🌱', 'متفائلة'),
  Feeling('excited', '🤩', 'متحمّسة'),
  Feeling('loved', '🥰', 'محبوبة'),
  Feeling('calm', '😌', 'هادئة'),
  Feeling('inspired', '💡', 'مُلهَمة'),
  Feeling('content', '🙂', 'مرتاحة'),
  Feeling('strong', '💪', 'قوية'),

  // حيادية
  Feeling('neutral', '😶', 'محايدة'),
  Feeling('tired', '😴', 'متعَبة'),
  Feeling('bored', '😒', 'ضجِرة'),
  Feeling('confused', '😕', 'حائرة'),
  Feeling('unmotivated', '🥱', 'غير متحمّسة'),

  // سلبية
  Feeling('anxious', '😟', 'قلقانة'),
  Feeling('lonely', '💔', 'وحيدة'),
  Feeling('sad', '😢', 'حزينة'),
  Feeling('overwhelmed', '🤯', 'مرهَقة'),
  Feeling('angry', '😠', 'غاضبة'),
  Feeling('frustrated', '😤', 'محبَطة'),
  Feeling('hopeless', '😞', 'مكسورة'),
  Feeling('exhausted', '🥵', 'منهَكة'),
  Feeling('scared', '😨', 'خايفة', labelFusha: 'خائفة'),
  Feeling('guilty', '😔', 'بالومني نفسي', labelFusha: 'مذنبة'),
];

Feeling? feelingById(String? id) {
  for (final f in kFeelings) {
    if (f.id == id) return f;
  }
  return null;
}

/// المشاعر المتاحة حسب المزاج. ابورت من `Feeling.forMood`.
List<Feeling> feelingsForMood(String moodId) {
  List<String> ids;
  switch (moodId) {
    case 'wonderful':
      ids = const [
        'happy', 'grateful', 'proud', 'excited', 'loved', 'inspired',
        'hopeful', 'content', 'calm', 'strong',
      ];
      break;
    case 'good':
      ids = const [
        'content', 'calm', 'grateful', 'hopeful', 'happy', 'proud',
        'inspired', 'loved', 'neutral', 'strong', 'excited',
      ];
      break;
    case 'okay':
      ids = const [
        'neutral', 'calm', 'tired', 'bored', 'confused', 'unmotivated',
        'content', 'hopeful', 'grateful', 'loved', 'overwhelmed',
      ];
      break;
    case 'not_good':
      ids = const [
        'anxious', 'tired', 'overwhelmed', 'sad', 'frustrated', 'confused',
        'unmotivated', 'lonely', 'bored', 'guilty', 'scared', 'calm',
        'hopeless', 'exhausted', 'angry',
      ];
      break;
    case 'bad':
      ids = const [
        'sad', 'lonely', 'overwhelmed', 'anxious', 'angry', 'hopeless',
        'exhausted', 'frustrated', 'scared', 'guilty',
      ];
      break;
    default:
      ids = const [];
  }
  return ids.map((id) => feelingById(id)!).toList();
}

/// المؤثرات اللي ممكن تكون السبب.
class Influence {
  final String id;
  final String emoji;
  final String label;
  final String labelFusha;
  const Influence(this.id, this.emoji, this.label, {this.labelFusha = ''});
}

const kInfluences = <Influence>[
  Influence('work', '💼', 'الشغل/الدراسة', labelFusha: 'العمل/الدراسة'),
  Influence('family', '👨‍👩‍👧', 'العيلة', labelFusha: 'العائلة'),
  Influence('friends', '👯', 'الأصحاب', labelFusha: 'الأصدقاء'),
  Influence('money', '💵', 'أمور مالية'),
  Influence('health', '🩺', 'الصحّة'),
  Influence('body', '🧘', 'الجسم'),
  Influence('news', '📰', 'الأخبار'),
  Influence('social_media', '📱', 'السوشيال ميديا'),
  Influence('sleep', '😴', 'النوم'),
  Influence('eating', '🍽️', 'الأكل'),
  Influence('period', '🌸', 'الدورة الشهرية'),
  Influence('inner_voice', '🧠', 'صوت عقلي'),
  Influence('relationships', '💕', 'العلاقات'),
  Influence('conflict', '⚡', 'خلاف'),
  Influence('weather', '🌧️', 'الجو'),
  Influence('routine', '📋', 'الروتين'),
  Influence('achievement', '🏆', 'إنجاز'),
  Influence('hobby', '🎨', 'هواية'),
  Influence('exercise', '🏃', 'رياضة'),
  Influence('nature', '🌿', 'طبيعة'),
  Influence('learning', '📚', 'تعلّم'),
  Influence('gratitude', '🤍', 'امتنان'),
  Influence('travel', '✈️', 'سفر'),
  Influence('future', '🌍', 'المستقبل'),
  Influence('isolation', '🌑', 'العزلة'),
  Influence('other', '❓', 'أخرى'),
];

Influence? influenceById(String? id) {
  for (final i in kInfluences) {
    if (i.id == id) return i;
  }
  return null;
}

/// المؤثرات المتاحة حسب المزاج. ابورت من `Influence.forMood`.
List<Influence> influencesForMood(String moodId) {
  List<String> ids;
  switch (moodId) {
    case 'wonderful':
      ids = const [
        'achievement', 'gratitude', 'friends', 'family', 'hobby', 'exercise',
        'nature', 'travel', 'learning', 'routine', 'relationships', 'weather',
        'other',
      ];
      break;
    case 'good':
      ids = const [
        'routine', 'family', 'friends', 'hobby', 'exercise', 'nature',
        'learning', 'achievement', 'gratitude', 'relationships', 'weather',
        'sleep', 'other',
      ];
      break;
    case 'okay':
      ids = const [
        'work', 'routine', 'weather', 'sleep', 'body', 'news', 'eating',
        'hobby', 'family', 'friends', 'social_media', 'period', 'other',
      ];
      break;
    case 'not_good':
      ids = const [
        'work', 'money', 'family', 'relationships', 'sleep', 'body', 'health',
        'news', 'inner_voice', 'social_media', 'eating', 'conflict', 'period',
        'weather', 'future', 'routine', 'other',
      ];
      break;
    case 'bad':
      ids = const [
        'work', 'money', 'family', 'relationships', 'health', 'sleep',
        'inner_voice', 'conflict', 'news', 'body', 'period', 'social_media',
        'future', 'isolation', 'other',
      ];
      break;
    default:
      ids = const [];
  }
  return ids.map((id) => influenceById(id)!).toList();
}
