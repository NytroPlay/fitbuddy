import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class CommunityPrefs {
  static const _key = 'community_posts';

  static Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = posts.map((p) => p.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<Post>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    // Robustez: asegurarse que cada elemento es Map antes de pasar a fromJson
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((j) => Post.fromJson(j))
        .toList();
  }
}
