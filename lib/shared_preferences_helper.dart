// shared_preferences_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserData(String userId, String role,
      {String? coachId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_role', role);
    if (coachId != null) {
      await prefs.setString('coach_id', coachId);
    }
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getCoachId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('coach_id');
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('coach_id');
  }
}
