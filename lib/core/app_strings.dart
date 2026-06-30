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
  static String get feelingsHint => 'اختاري 3';
  static String get influencesQuestion =>
      isFusha ? 'ما الذي يؤثر فيكِ اليوم؟' : 'إيه اللي مؤثّر عليكي اليوم؟';
  static String get influencesHint => 'اختاري 3';
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
  static String get navTimer => 'تايمر';
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

  // Settings dialogs
  static String get rateDialogTitle => 'هل استمتعتِ بـ Routiny؟';
  static String get rateDialogBody =>
      isFusha
          ? 'ساعدينا على التحسّن من خلال تقييمنا، وسنبذل قصارى جهدنا لجعل تجربتكِ أفضل.'
          : 'ساعدينا نتحسّن بتقييمنا، هنبذل أقصى جهدنا علشان تجربتك تبقى أحسن.';
  static String get rateBtn => isFusha ? 'أعطنا ٥ نجوم' : 'اعطينا ٥ نجوم';
  static String get maybeLater => isFusha ? 'ربما لاحقاً' : 'يمكن بعدين';
  static String get clearDataConfirmTitle =>
      isFusha
          ? 'هل أنتِ متأكدة من مسح جميع البيانات؟'
          : 'متأكدة إنك عايزة تمسحي كل البيانات؟';
  static String get clearDataConfirmBody =>
      isFusha
          ? 'سيتم حذف كل المهام، الإحصائيات، الصورة الشخصية، الاسم وسجل الإشعارات. لا يمكن استرجاعها.'
          : 'هيتم حذف كل المهام، الإحصائيات، الصورة الشخصية، الاسم وسجل الإشعارات. مش هتقدري ترجّعيها.';
  static String get yes => isFusha ? 'نعم' : 'أيوه';
  static String get no => isFusha ? 'لا' : 'لأ';
  static String get dataClearedMsg =>
      isFusha ? 'تم مسح كل البيانات' : 'اتمسح كل البيانات';

  // Notifications settings page
  static String get notifSettingsTitle =>
      isFusha ? 'إعدادات الإشعارات' : 'اعدادات الاشعارات';
  static String get notifAllLabel => 'جميع الإشعارات';
  static String get notifQuotesLabel =>
      isFusha ? 'الاقتباسات اليومية' : 'الكوتات اليومية';
  static String get notifQuotesDesc =>
      isFusha ? 'اقتباس يومي لطيف' : 'كوتة لطيفة';
  static String get notifHabitLabel => 'تذكير العادة';
  static String get notifHabitDesc =>
      isFusha
          ? 'احصلي على تذكيرات لإتمام عاداتكِ'
          : 'احصلي على تذكيرات لإكمال عاداتكِ';
  static String get notifFocusRunningLabel => 'جلسة التركيز';
  static String get notifFocusRunningDesc =>
      isFusha
          ? 'إشعار نشط أثناء جلسة البومودورو يعرض الوقت المتبقي'
          : 'إشعار شغّال أثناء جلسة البومودورو يعرض الوقت المتبقي';
  static String get notifFocusCompleteLabel => 'انتهاء الجلسة';
  static String get notifFocusCompleteDesc =>
      isFusha
          ? 'تنبيه عند انتهاء جلسة التركيز'
          : 'تنبيه لما جلسة التركيز تخلص';
  static String get notifInactivityLabel => 'تذكير العودة';
  static String get notifInactivityDesc =>
      isFusha
          ? 'إشعار لطيف للتذكير بفتح التطبيق'
          : 'اشعار لطيف للتذكير بفتح الابلكيشن';
  static String get batteryOptTitle =>
      isFusha
          ? 'وضع توفير البطارية مُفعَّل'
          : 'وضعية توفير البطارية قيد التشغيل';
  static String get batteryOptDesc =>
      'تم تمكين تحسين البطارية الآن. قد لا تتلقّي إشعارات عند تمكين هذا الإعداد.';
  static String get batteryOptLink => 'اذهبي إلى إعدادات الجهاز ←';
  static String get testNotifLabel => 'إرسال إشعار تجريبي';
  static String get testNotifBtn => 'جرّبي';
  static String get latestNotifsTitle => 'أحدث الإشعارات';
  static String get noNotifsYet =>
      isFusha ? 'لا توجد إشعارات حتى الآن' : 'لا توجد إشعارات بعد';
  static String get clearAllBtn => 'مسح الكل';

  // Routine page
  static String get routineToday => 'روتيني اليوم';
  static String get noTasksToday => 'لا توجد مهام لهذا اليوم';
  static String get todayBtn => 'اليوم';

  // Profile page
  static String get profileTitle => 'الملف الشخصي';
  static String get editNameLabel => 'تعديل الاسم';
  static String get taskStatsTitle =>
      isFusha ? 'إحصائيات أيام إنجاز المهام' : 'احصائيات ايام انجاز المهام';
  static String get breathingStatsTitle => 'إحصائيات التنفس';
  static String get moodStatsTitle =>
      isFusha ? 'إحصائيات مشاعرك' : 'احصائيات احساسك';
  static String get openJournalBtn =>
      isFusha ? 'افتحي مذكّراتي 🔓' : 'افتحي مذكراتي 🔓';
  static String get notNow => isFusha ? 'ليس الآن' : 'مش دلوقتي';
  static String get watchAdBtn =>
      isFusha ? 'شاهدي إعلاناً وافتحي' : 'شوفي إعلان وافتحي';
  static String get journalTitleLabel => isFusha ? 'مذكّراتي' : 'مذكراتي';
  static String get deleteJournalTitle =>
      isFusha ? 'هل تريدين حذف هذه المذكرة؟' : 'مسح المذكرة دي؟';
  static String get deleteJournalConfirm =>
      isFusha ? 'نعم، احذفيها' : 'نعم، امسحيها';
  static String get goBack => 'رجوع';
  static String get editPhotoTitle =>
      isFusha ? 'تعديل الصورة' : 'عدّلي الصورة';
  static String get pinchHint => 'قرّبي بإصبعين أو حرّكي الصورة';
  static String get savePhoto => 'حفظ الصورة';
  static String get adNotAvailable =>
      isFusha
          ? 'لا يوجد إعلان متاح الآن، حاولي مرة أخرى لاحقاً 🙏'
          : 'مفيش إعلان متاح دلوقتي، جربي تاني بعدين 🙏';

  // Timer
  static String get focusStatsTitle => 'إحصائيات التركيز';
  static String get focusTimeChart =>
      isFusha ? 'مخطط وقت التركيز' : 'جدول التركيز الزمني';
  static String get confirmBtn => 'تأكيد';
  static String get minuteLabel => 'دقيقة';
  static String get focusTaskDefault => 'تركيز';

  // Reflection
  static String get moodStateQuestion => 'ما حالتك المزاجية اليوم؟';
  static String get chooseMoodHint =>
      isFusha ? 'اختاري الأقرب إلى مشاعرك' : 'اختاري الأقرب لإحساسك';
  static String get maxChoicesMsg =>
      isFusha ? 'الحد الأقصى ٣ اختيارات' : 'أقصى 3 اختيارات';
  static String get keepJournalHint =>
      isFusha
          ? 'احتفظي بمذكرتي لمراجعتها لاحقاً 🤍'
          : 'احتفظي بمذكراتي عشان أرجعلها بعدين 🤍';
  static String get describeDay =>
      isFusha ? 'وصفي يومك' : 'وصف يومك';
  static String get shareResultBtn => 'شاركي نتيجتك 📸';

  // Icon picker
  static String get chooseIcon =>
      isFusha ? 'اختاري أيقونة' : 'اختر أيقونة';

  // Settings rows
  static String get dailyQuoteRow => isFusha ? 'اقتباس اليوم' : 'كوتة اليوم';

  // Profile – journal ad dialog
  static String get watchAdDialogBody =>
      isFusha
          ? 'شاهدي إعلاناً قصيراً وافتحي مذكراتكِ 🌸'
          : 'شوفي إعلان قصير وافتحي مذكراتك 🌸';
  static String get adUnavailableMsg =>
      isFusha
          ? 'تحتاجين اتصالاً بالإنترنت لمشاهدة إعلان وفتح مذكراتكِ 🌐'
          : 'محتاجة اتصال بالإنترنت عشان تشوفي إعلان وتفتحي مذكراتك 🌐';

  // Profile – mood counts
  static String moodTotal(int n) {
    if (n == 0) return isFusha ? 'لا توجد مشاعر' : 'مفيش إحساسات';
    if (n == 1) return isFusha ? 'شعور واحد' : 'إحساس واحد';
    if (n == 2) return isFusha ? 'شعوران' : 'إحساسين';
    if (n <= 10) return isFusha ? '$n مشاعر' : '$n إحساسات';
    return isFusha ? '$n شعور' : '$n إحساس';
  }

  static String get moodStatsEmpty =>
      isFusha
          ? 'لا توجد مشاعر مسجّلة في هذا الشهر — جرّبي تسجيل مشاعرك من صفحة العناية 🤍'
          : 'مفيش إحساسات في الشهر ده — جربي تسجلي إحساسك من صفحة العناية 🤍';

  /// Returns [fusha] when fusha mode is active and it's non-empty; else [masri].
  static String localize(String masri, [String? fusha]) =>
      isFusha && fusha != null && fusha.isNotEmpty ? fusha : masri;

  // ── Care page ──
  static String get careHeader => 'عناية';
  static String get reflectionCardTitle =>
      isFusha ? 'كيف حالكِ اليوم؟' : 'حاسة بإيه النهاردة؟';
  static String get reflectionCardSubtitle =>
      isFusha
          ? 'خصّصي دقيقتين لتأمّل مشاعركِ اليوم'
          : 'خدي دقيقتين تشوفي شعورك إزاي النهارده';

  // ── Tests page ──
  static String get testsHeader =>
      isFusha ? 'اختبري نفسكِ واكتشفيها' : 'اختبري نفسك واكتشفيها';
  static String get testsSubheader =>
      isFusha ? 'ماذا يقول قلبكِ' : 'قلبك بيقول إيه';
  static String get startTestBtn => 'ابدأ الاختبار الآن';

  // ── Reflection empathy titles ──
  static String get empathyWonderful =>
      isFusha ? 'يومكِ جميل 💗' : 'يومك حلو 💗';
  static String get empathyGood =>
      isFusha ? 'يبدو أنكِ بخير 🤍' : 'يبدو إنّك بخير 🤍';
  static String get empathyOkay =>
      isFusha ? 'يومٌ عادي… ولا بأس بذلك 🌿' : 'يوم عادي… ومفيش غلط 🌿';
  static String get empathyNotGood =>
      isFusha ? 'كان يومكِ ثقيلاً 🫂' : 'يومك تقيل شوية 🫂';
  static String get empathyBad =>
      isFusha ? 'كان اليوم صعباً 💔' : 'اليوم كان صعب 💔';

  // ── Reflection activity titles/descs (used in _pickActivity) ──
  static String get actSoothingArticle =>
      isFusha ? 'مقال يهدّئكِ' : 'مقال يهدّيكي';
  static String get actSoothingDesc =>
      isFusha
          ? 'كلمات بسيطة تُذكّركِ أن الراحة حقّكِ وليست رفاهية.'
          : 'كلمات بسيطة تفكّرك إن الراحة حقّك مش رفاهية.';
  static String get actHeartArticle =>
      isFusha ? 'مقال يلمس قلبكِ' : 'مقال يلمس قلبك';
  static String get actHeartDesc =>
      isFusha
          ? 'كلمات ستُذكّركِ أنكِ لستِ وحيدة في هذا الشعور.'
          : 'كلمات هتفكّرك إنّك مش لوحدك في الإحساس ده.';
  static String get actThoughtsArticle =>
      isFusha ? 'مقال يُهدّئ أفكاركِ' : 'مقال يهدّي أفكارك';
  static String get actThoughtsDesc =>
      isFusha
          ? 'قبل الردّ على أي شيء، اقرئي كلمات تساعدكِ على الهدوء.'
          : 'قبل ما تردّي على أي حاجة، اقري كلمات بتساعدك تهدي.';
  static String get actGuiltArticle =>
      isFusha ? 'مقال عن الشعور بالذنب' : 'مقال عن الشعور بالذنب';
  static String get actGuiltDesc =>
      isFusha
          ? 'ليس كل ذنب حقيقياً… اقرئيه وكوني أرفق مع نفسكِ.'
          : 'مش كل ذنب حقيقي… اقري ده وكوني ألطف مع نفسك.';
  static String get actMotivationArticle =>
      isFusha ? 'مقال يُعيد إليكِ حماسكِ' : 'مقال يرجّعلك حماسك';
  static String get actMotivationDesc =>
      isFusha
          ? 'سرّ الاستمرار ليس الحماس — اقرئي كيف تكملين بهدوء.'
          : 'سر الاستمرار مش الحماس — اقري إزاي تكمّلي بهدوء.';
  static String get actOrganizeArticle =>
      isFusha ? 'مقال يُنظّم أفكاركِ' : 'مقال ينظّم أفكارك';
  static String get actOrganizeDesc =>
      isFusha
          ? 'لا داعي لإجابة الآن. اقرئي كيف تبنين روتيناً يناسبكِ.'
          : 'مش لازم تلاقي إجابة دلوقتي. اقري إزاي تبني روتين يناسبك.';
  static String get actRestArticle =>
      isFusha ? 'مقال يمنحكِ الراحة' : 'مقال يديكي راحة';
  static String get actRestDesc =>
      isFusha
          ? 'الراحة ليست كسلاً — اقرئيه واسترخي دون لومٍ للنفس.'
          : 'الراحة مش كسل — اقري ده وارتاحي من غير تأنيب.';
  static String get actStrongArticle =>
      isFusha ? 'مقال يُكمّل قوّتكِ' : 'مقال يكمّل قوّتك';
  static String get actStrongDesc =>
      isFusha
          ? 'كيف تكونين قوية ورقيقة في الوقت ذاته.'
          : 'ازاي تكوني قوية وناعمة في نفس الوقت.';
  static String get actGratefulArticle =>
      isFusha ? 'مقال يُثبّت إحساسكِ الجميل' : 'مقال يثبّت إحساسك الحلو';
  static String get actGratefulDesc =>
      isFusha
          ? 'اقرئي كلمات تدعمكِ وتجعلكِ نسخةً أفضل من نفسكِ.'
          : 'اقري كلمات بتدعمك وتخليكي نسخة أفضل من نفسك.';
  static String get actCalmArticle =>
      isFusha ? 'مقال يُكمّل هدوءكِ' : 'مقال يكمّل هدوءك';
  static String get actCalmDesc =>
      isFusha
          ? 'روتين بسيط لحياة أكثر هدوءاً وسكينةً.'
          : 'روتين بسيط لحياة أكثر هدوء وسكينة.';
  static String get actEnergyArticle =>
      isFusha ? 'مقال يُكمّل طاقتكِ' : 'مقال يكمّل طاقتك';
  static String get actEnergyDesc =>
      isFusha
          ? 'قوة العادات الصغيرة في تغيير حياتكِ.'
          : 'قوة العادات الصغيرة في تغيير حياتك.';
  static String get actStartArticle =>
      isFusha ? 'مقال يبدأ يومكِ' : 'مقال يبدأ يومك';
  static String get actStartDesc =>
      isFusha
          ? 'كيف تبنين روتيناً يناسبكِ دون ضغط.'
          : 'ازاي تبني روتين يناسبك من غير ما يضغطك.';
  static String get actLightenArticle =>
      isFusha ? 'مقال يُخفّف عنكِ' : 'مقال يخفّف عنك';
  static String get actLightenDesc =>
      isFusha
          ? 'الراحة حقّكِ — اقرئيه وكوني لطيفة مع نفسكِ.'
          : 'الراحة حقّك — اقري ده وكوني لطيفة مع نفسك.';
  static String get actHoldArticle =>
      isFusha ? 'مقال يحتويكِ' : 'مقال يحتويكي';
  static String get actHoldDesc =>
      isFusha
          ? 'لا يلزمكِ إنجاز شيء اليوم. اقرئي كلمات تطمئنكِ.'
          : 'مش لازم تنجزي حاجة النهاردة. اقري كلمات بتطمّنك.';

  // ── Reflection share / OK button ──
  static String get reflectionShareIntro =>
      isFusha
          ? 'انعكاسي اليوم في روتيني 🌸'
          : 'انعكاسي النهاردة على روتيني 🌸';
  static String get reflectionShareHeadline =>
      isFusha ? 'كيف أشعر اليوم 🌸' : 'حاسة بإيه النهاردة 🌸';
  static String get okBtn => isFusha ? 'حسناً 💗' : 'تمام 💗';

  // ── Feelings / Influences fusha labels (used in reflection chips) ──
  static String get feelingScaredLabel =>
      isFusha ? 'خائفة' : 'خايفة';
  static String get feelingGuiltyLabel =>
      isFusha ? 'مذنبة' : 'بالومني نفسي';
  static String get influenceWorkLabel =>
      isFusha ? 'العمل/الدراسة' : 'الشغل/الدراسة';
  static String get influenceFamilyLabel =>
      isFusha ? 'العائلة' : 'العيلة';
  static String get influenceFriendsLabel =>
      isFusha ? 'الأصدقاء' : 'الأصحاب';
}
