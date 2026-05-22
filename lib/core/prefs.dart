import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences. All Routiny preference namespaces
/// (stats, water, notifications, focus settings) live here behind prefixes.
class Prefs {
  Prefs._();
  static final Prefs I = Prefs._();

  late SharedPreferences _sp;

  Future<void> init() async {
    _sp = await SharedPreferences.getInstance();
  }

  bool getBool(String k, [bool def = false]) => _sp.getBool(k) ?? def;
  int getInt(String k, [int def = 0]) => _sp.getInt(k) ?? def;
  String? getString(String k) => _sp.getString(k);
  List<String> getList(String k) => _sp.getStringList(k) ?? [];

  Future<void> setBool(String k, bool v) => _sp.setBool(k, v);
  Future<void> setInt(String k, int v) => _sp.setInt(k, v);
  Future<void> setString(String k, String v) => _sp.setString(k, v);
  Future<void> setList(String k, List<String> v) => _sp.setStringList(k, v);
  Future<void> remove(String k) => _sp.remove(k);

  Future<void> addToSet(String k, String value) async {
    final s = getList(k).toSet()..add(value);
    await setList(k, s.toList());
  }

  Future<void> removeFromSet(String k, String value) async {
    final s = getList(k).toSet()..remove(value);
    await setList(k, s.toList());
  }

  bool setContains(String k, String value) => getList(k).contains(value);

  Future<void> clearAll() async => _sp.clear();
}
