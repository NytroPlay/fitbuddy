import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroupPrefs {
  static const _key = 'joined_groups';

  static Future<void> saveGroups(List<String> groups) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(groups));
  }

  static Future<List<String>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.cast<String>();
  }
}
