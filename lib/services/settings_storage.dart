import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _precisionKey = 'settings_precision';

  Future<int?> loadPrecision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_precisionKey);
  }

  Future<void> savePrecision(int precision) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_precisionKey, precision);
  }
}

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  return SettingsStorage();
});
