import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class SharedPrefs {
  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  static Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConfig.keyAuthToken);
  }

  static Future<void> setToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConfig.keyAuthToken, token);
  }

  static Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
  }
  
  static Future<String?> getUserId() async {
    final prefs = await _instance;
    return prefs.getString(AppConfig.keyUserId);
  }
}
