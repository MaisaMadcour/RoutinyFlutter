class S {
  static String _lang = 'masri'; // 'masri' | 'fusha'
  static void setLang(String l) => _lang = l;
  static bool get isFusha => _lang == 'fusha';

  // Greetings
  static String get greetingMorning => 'صباح الخير';
  static String get greetingEvening => 'مساء الخير';

  // Routine
  static String get noTasksYet => isFusha ? 'لا توجد مهام' : 'لا يوجد مهام';
  static String get oneTask => 'مهمة واحدة';
  static String get twoTasks => 'مهمتان';
  static String tasksCount(int n) =>
      n <= 10 ? '$n مهام' : '$n مهمة';
  static String get addTask => isFusha ? 'إضافة مهمة' : 'أضيفي مهمة';
  static String get addRoutine => isFusha ? 'إضافة روتين' : 'أضيفي روتين';
  static String get supportUs => 'ادعمينا 💗';

  // Task creation
  static String get taskTitleHint => 'عنوان المهمة';
  static String get taskTitleEmpty =>
      isFusha ? 'يرجى إدخال عنوان المهمة' : 'الرجاء إدخال عنوان المهمة';
  static String get taskTitleTooLong =>
      isFusha ? 'الحد الأقصى ١٥ حرفاً' : 'الحد الأقصى 15 حرف';
  static String get subtaskHint => isFusha ? 'خطوة فرعية...' : 'خطوة..';
  static String get addSubtask => isFusha ? 'إضافة خطوة' : 'أضيفي خطوة';
  static String get timeLabel => 'الوقت';
  static String get anyTime => 'في أي وقت';
  static String get reminderLabel => 'التذكير';
  static String get recurrenceLabel => 'التكرار';
  static String get recurrenceNone => 'لا يوجد';
  static String get recurrenceDaily => 'يومياً';
  static String get recurrenceWeekly => 'أسبوعياً';
  static String get chooseTimeFirst =>
      isFusha
          ? 'اختاري وقتاً أولاً من خانة الوقت'
          : 'اختر وقتًا أولًا من خانة الوقت';
  static String get save => 'حفظ';

  // Timer
  static String get startTimer => isFusha ? 'ابدأي التايم' : 'ابدأ التايم';
  static String get startFocus => isFusha ? 'ابدأي التركيز' : 'ابدأ التركيز';
  static String get timerDurationTitle =>
      isFusha ? 'اضبطي مدة التايم' : 'اضبط مدة التايم';
  static String get pomodoroDurationTitle =>
      isFusha ? 'اضبطي مدة البومودورو' : 'اضبط مدة البومودورو';
  static String get timerTab => 'تايم';
  static String get pomodoroTab => 'بومودورو';
  static String get focusTimeLabel => 'وقت التركيز';
  static String get breakTimeLabel => 'وقت الراحة';
  static String get holdToStop => 'اضغطي مطوّلاً للإيقاف';

  // Reflection
  static String get reflectionTitle =>
      isFusha ? 'كيف تشعرين اليوم' : 'حاسة بإيه النهاردة';
  static String get feelingsQuestion =>
      isFusha ? 'كيف تصفين شعورك اليوم؟' : 'كيف تصفي شعورك اليوم؟';
  static String get feelingsHint =>
      isFusha ? 'اختاري واحداً على الأقل (حتى 3)' : 'اختاري واحد على الأقل (حتى 3)';
  static String get influencesQuestion =>
      isFusha ? 'ما الذي يؤثر فيكِ اليوم؟' : 'إيه اللي مؤثّر عليكي اليوم؟';
  static String get influencesHint =>
      isFusha ? 'اختاري واحداً على الأقل (حتى 3)' : 'اختاري واحد على الأقل (حتى 3)';
  static String get journalQuestion =>
      isFusha ? 'هل تريدين التعبير عن مشاعرك؟ ✍️' : 'عايزة تزيحيها عن صدرك؟ ✍️';
  static String get journalSubtitle =>
      isFusha
          ? 'استرخي — هذا اختياري لكنه سيساعدك.'
          : 'استرخي — ده اختياري لكنّه هيساعدك.';
  static String get journalHint =>
      isFusha ? 'ابدئي بتدوين مشاعرك...' : 'ابدأي بتدوين مشاعرك...';
  static String get journalSkipHint =>
      isFusha
          ? 'ليس ضرورياً — يمكنكِ التخطي ورؤية الرد'
          : 'مش لازم — تقدري تتخطّى وتشوفي الرد';
  static String get nextBtn => 'التالي';
  static String get backBtn => 'السابق';
  static String get doneBtn => 'تمام 💗';
  static String get adoptRoutineBtn => 'اعتمدي الروتين ✓';
  static String get routineAddedSnack =>
      isFusha
          ? 'أُضيفت كمهمة في صفحة الروتين 💗'
          : 'اتضافت كمهمة في صفحة الروتين 💗';
  static String get responseRecorded =>
      isFusha ? 'تم تسجيل شعورك اليوم ✨' : 'إحساسك النهاردة اتسجّل ✨';
  static String get startNowBtn =>
      isFusha ? 'ابدئي الآن ←' : 'ابدأي دلوقتي ←';
  static String get restBtn =>
      isFusha ? 'تمام، خذي وقتك 💗' : 'تمام، خدي وقتك 💗';

  // Water tracker
  static String get waterGoalLabel => 'هدف اليوم';
  static String get waterAddCup => isFusha ? 'إضافة كوب' : 'أضيفي كوب';
  static String get waterNothingToUndo =>
      isFusha ? 'لا يوجد شيء للتراجع عنه' : 'مفيش حاجة للتراجع';
  static String get waterGoalReached =>
      isFusha ? '🎉 أكملتِ الهدف! تستحقين 💗' : '🎉 كمّلتي الهدف! تستاهلي 💗';
  static String get waterReminderLabel =>
      isFusha ? 'تذكير شرب الماء' : 'تذكير شرب الميّة';

  // Settings
  static String get settingsTitle => 'الإعدادات';
  static String get settingsAccount => 'الحساب';
  static String get settingsApp => 'التطبيق';
  static String get settingsHelp => 'المساعدة والتعليقات';
  static String get editProfile => 'تعديل الملف الشخصي';
  static String get notificationsLabel => 'الإشعارات';
  static String get languageLabel => 'اللغة';
  static String get quoteTodayLabel =>
      isFusha ? 'اقتباس اليوم' : 'كوتة اليوم';
  static String get breathingExercise =>
      isFusha ? 'تمرين التنفس' : 'تمرين تنفّس';
  static String get rateUs => 'قيّمينا';
  static String get clearData => 'مسح جميع البيانات';
  static String get currentLanguage => isFusha ? 'عربية فصحى' : 'مصري';

  // Nav labels
  static String get navSettings => 'الإعدادات';
  static String get navCare => isFusha ? 'العناية' : 'عناية';
  static String get navRoutine => 'روتيني';
  static String get navTimer => 'تايم';
  static String get navTests => isFusha ? 'اختبارات' : 'اختبار';

  // Care
  static String get carePageTitle => 'بالعناية بنفسك';
  static String get relatedArticles => 'مقالات ذات صلة';
  static String get readMore => 'اقرئي المزيد';

  // Notifications text in receivers
  static String get notifInactivityTitle =>
      isFusha ? 'اشتقنا إليكِ 💗' : 'وحشتينا 💗';
  static String get notifQuoteTitle =>
      isFusha ? 'لكِ أيتها الجميلة 💗' : 'لكِ يا جميلة 💗';

  // Language picker
  static String get languagePickerTitle => 'اختاري اللغة';
  static String get langMasri => 'مصري';
  static String get langFusha => 'عربية فصحى';
}
