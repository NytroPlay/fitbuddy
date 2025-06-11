// lib/utils/user_prefs.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserPrefs {
  static const _keyUsersList = 'users_list';
  static const _keyCurrentUserId = 'current_user_id';
  static const _keyAuthToken = 'auth_token';

  static const _keySettings = 'settings';
  // ==== SETTINGS / CONFIGURACIÓN ====
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await _instance;
    await prefs.setString(_keySettings, jsonEncode(settings));
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await _instance;
    final raw = prefs.getString(_keySettings);
    if (raw == null) {
      // Defaults si nunca se guardó
      return {'notifications': true, 'private': false, 'language': 'es'};
    }
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  /// === Usuarios ===

  /// Registra un nuevo usuario (si no existe ya)
  static Future<bool> registerUser(User user) async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyUsersList) ?? '[]';
    final list = jsonDecode(raw) as List<dynamic>;

    // No duplicados por email
    if (list.any(
      (u) =>
          (u as Map<String, dynamic>)['email'].toString().toLowerCase() ==
          user.email.toLowerCase(),
    )) {
      return false;
    }

    list.add(user.toJson());
    await prefs.setString(_keyUsersList, jsonEncode(list));
    return true;
  }

  /// Carga todos los usuarios registrados
  static Future<List<User>> loadAllUsers() async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyUsersList) ?? '[]';
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Busca un usuario por email+password
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

  /// Actualiza datos (incluido avatar) de un usuario ya registrado
  static Future<void> updateUser(User user) async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyUsersList) ?? '[]';
    final list = jsonDecode(raw) as List<dynamic>;

    for (var i = 0; i < list.length; i++) {
      final m = (list[i] as Map<String, dynamic>);
      if (m['id'] == user.id) {
        list[i] = user.toJson();
        break;
      }
    }

    await prefs.setString(_keyUsersList, jsonEncode(list));
  }

  /// Alias para loadCurrentUser()
  static Future<User?> loadUser() => loadCurrentUser();

  /// Alias para updateUser()
  static Future<void> saveUser(User u) => updateUser(u);

  /// === Sesión ===

  /// Marca sesión como iniciada para `user.id`
  static Future<void> setAuthenticated(User user) async {
    final prefs = await _instance;
    await prefs.setString(_keyAuthToken, 'user_authenticated');
    await prefs.setString(_keyCurrentUserId, user.id);
  }

  /// Comprueba si hay sesión activa
  static Future<bool> isAuthenticated() async {
    final prefs = await _instance;
    return prefs.getString(_keyAuthToken) == 'user_authenticated' &&
        prefs.containsKey(_keyCurrentUserId);
  }

  /// Carga el usuario actualmente logueado (o null)
  static Future<User?> loadCurrentUser() async {
    final prefs = await _instance;
    final id = prefs.getString(_keyCurrentUserId);
    if (id == null) return null;
    final all = await loadAllUsers();
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Cierra la sesión, pero mantiene la lista de usuarios
  static Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyCurrentUserId);
    if (kDebugMode) {
      print('Sesión cerrada, usuarios guardados en memoria.');
    }
  }

  // === LOGROS / ACHIEVEMENTS ===
  static const _keyAchievements = 'achievements';

  static Future<void> saveAchievements(Map<String, bool> achievements) async {
    final prefs = await _instance;
    await prefs.setString(_keyAchievements, jsonEncode(achievements));
  }

  static Future<Map<String, bool>> loadAchievements() async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyAchievements);
    if (raw == null) {
      return {};
    }
    final decoded = Map<String, dynamic>.from(jsonDecode(raw));
    return decoded.map((k, v) => MapEntry(k, v as bool));
  }

  static Future<void> unlockAchievement(String key) async {
    final achievements = await loadAchievements();
    if (!(achievements[key] ?? false)) {
      achievements[key] = true;
      await saveAchievements(achievements);
    }
  }

  static Future getProfileImage() async {}

  static Future<void> saveProfileImage(String newAvatarUrl) async {}

  static Future<void> clearProfileImage() async {}
}
