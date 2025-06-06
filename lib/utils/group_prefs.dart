import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group.dart';

class GroupPrefs {
  static const _key = 'joined_groups';

  static Future<void> saveGroups(List<Group> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = groups.map((g) => g.toJson()).toList();
    prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<Group>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => Group.fromJson(j)).toList();
  }
}
