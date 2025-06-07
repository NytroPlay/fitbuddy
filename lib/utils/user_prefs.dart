import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserPrefs {
  static const _keyUsersList = 'users_list';
  static const _keyCurrentUserId = 'current_user_id';
  static const _keyAuthToken = 'auth_token';
  static const _keyProfileImage = 'profile_image';

  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  /// === Usuarios ===

  static Future<bool> registerUser(User user) async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyUsersList) ?? '[]';
    final list = jsonDecode(raw) as List;
    if (list.any(
      (u) => (u['email'] as String).toLowerCase() == user.email.toLowerCase(),
    )) {
      return false;
    }
    list.add(user.toJson());
    await prefs.setString(_keyUsersList, jsonEncode(list));
    return true;
  }

  static Future<List<User>> loadAllUsers() async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyUsersList) ?? '[]';
    return (jsonDecode(raw) as List)
        .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<User?> findUser(String email, String password) async {
    final users = await loadAllUsers();
    try {
      return users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUser(User user) async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyUsersList) ?? '[]';
    final list = jsonDecode(raw) as List;
    for (var i = 0; i < list.length; i++) {
      if (list[i]['id'] == user.id) {
        list[i] = user.toJson();
        break;
      }
    }
    await prefs.setString(_keyUsersList, jsonEncode(list));
  }

  /// Alias para tu código existente
  static Future<User?> loadUser() => loadCurrentUser();
  static Future<void> saveUser(User u) => updateUser(u);

  /// === Sesión ===

  static Future<void> setAuthenticated(User user) async {
    final prefs = await _instance;
    await prefs.setString(_keyAuthToken, 'user_authenticated');
    await prefs.setString(_keyCurrentUserId, user.id);
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await _instance;
    return prefs.getString(_keyAuthToken) == 'user_authenticated' &&
        prefs.containsKey(_keyCurrentUserId);
  }

  static Future<User?> loadCurrentUser() async {
    final prefs = await _instance;
    final id = prefs.getString(_keyCurrentUserId);
    if (id == null) return null;
    try {
      return (await loadAllUsers()).firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyCurrentUserId);
    await prefs.remove(_keyProfileImage);
    if (kDebugMode) print('Sesión cerrada, usuarios intactos');
  }

  /// === Perfil (avatar o ruta) ===

  static Future<void> saveProfileImage(String data) async {
    final prefs = await _instance;
    await prefs.setString(_keyProfileImage, data);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await _instance;
    return prefs.getString(_keyProfileImage);
  }

  static Future<void> clearProfileImage() async {
    final prefs = await _instance;
    await prefs.remove(_keyProfileImage);
  }
}
