import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserPrefs {
  static const _key = 'user_data';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;
    return User.fromJson(jsonDecode(data));
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
  }
}
