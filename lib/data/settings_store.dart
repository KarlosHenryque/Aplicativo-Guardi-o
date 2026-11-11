import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore._(this._prefs);
  final SharedPreferences _prefs;

  static Future<SettingsStore> load() async =>
      SettingsStore._(await SharedPreferences.getInstance());

  String get phone => _prefs.getString('phone') ?? '';

  Future<void> setPhone(String value) async {
    await _prefs.setString('phone', value.trim());
    notifyListeners();
  }
}
