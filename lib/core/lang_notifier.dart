import 'package:flutter/foundation.dart';
import 'prefs.dart';
import 'app_strings.dart';

class LangNotifier extends ValueNotifier<String> {
  LangNotifier._() : super(_load());

  static LangNotifier? _instance;
  static LangNotifier get instance => _instance ??= LangNotifier._();

  static const _key = 'app_language';

  static String _load() {
    return Prefs.I.getString(_key) ?? 'masri';
  }

  void setLang(String lang) {
    Prefs.I.setString(_key, lang);
    S.setLang(lang);
    value = lang;
  }

  static void init() {
    final lang = _load();
    S.setLang(lang);
    instance.value = lang;
  }
}
