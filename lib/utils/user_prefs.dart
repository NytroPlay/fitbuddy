import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserPrefs {
  // Claves para SharedPreferences
  static const _keyUser = 'user_data';
  static const _keyProfileImage = 'profile_image';
  static const _keyAuthToken = 'auth_token';
  static const _keyRememberMe = 'remember_me';

  // Instancia de SharedPreferences
  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  /* ========== Métodos para el Usuario ========== */

  /// Guarda los datos del usuario en SharedPreferences
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await _instance;
      await prefs.setString(
        _keyUser,
        jsonEncode({
          'name': user.name,
          'email': user.email.toLowerCase(), // Normaliza el email
          'password': user.password,
          'phone': user.phone,
          'age': user.age,
          'height': user.height,
          'weight': user.weight,
        }),
      );
      if (kDebugMode) {
        print('Usuario guardado correctamente');
      }
    } catch (e) {
      debugPrint('Error al guardar usuario: $e');
      throw Exception('Error al guardar los datos del usuario');
    }
  }

  /// Carga los datos del usuario desde SharedPreferences
  static Future<User?> loadUser() async {
    try {
      final prefs = await _instance;
      final userData = prefs.getString(_keyUser);

      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      debugPrint('Error al cargar usuario: $e');
      return null;
    }
  }

  /// Valida las credenciales del usuario
  static Future<bool> validateCredentials(String email, String password) async {
    final user = await loadUser();
    return user != null &&
        user.email.toLowerCase() == email.toLowerCase() &&
        user.password == password;
  }

  /// Elimina los datos del usuario (logout)
  static Future<void> clearUser() async {
    try {
      final prefs = await _instance;
      await prefs.remove(_keyUser);
      await prefs.remove(_keyAuthToken); // Limpiar token también
      if (kDebugMode) {
        print('Datos de usuario eliminados');
      }
    } catch (e) {
      debugPrint('Error al limpiar datos de usuario: $e');
      throw Exception('Error al cerrar sesión');
    }
  }

  /* ========== Métodos para la Imagen de Perfil ========== */

  /// Guarda la imagen de perfil (puede ser path de archivo o avatar emoji)
  static Future<void> saveProfileImage(String imageData) async {
    try {
      final prefs = await _instance;
      await prefs.setString(_keyProfileImage, imageData);
    } catch (e) {
      debugPrint('Error al guardar imagen de perfil: $e');
      throw Exception('Error al guardar imagen de perfil');
    }
  }

  /// Obtiene la imagen de perfil guardada
  static Future<String?> getProfileImage() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_keyProfileImage);
    } catch (e) {
      debugPrint('Error al obtener imagen de perfil: $e');
      return null;
    }
  }

  /// Elimina la imagen de perfil
  static Future<void> clearProfileImage() async {
    try {
      final prefs = await _instance;
      await prefs.remove(_keyProfileImage);
    } catch (e) {
      debugPrint('Error al eliminar imagen de perfil: $e');
      throw Exception('Error al eliminar imagen de perfil');
    }
  }

  /* ========== Métodos Adicionales ========== */

  /// Guarda el token de autenticación (para APIs)
  static Future<void> setAuthToken(String token) async {
    try {
      final prefs = await _instance;
      await prefs.setString(_keyAuthToken, token);
    } catch (e) {
      debugPrint('Error al guardar token: $e');
      throw Exception('Error al guardar token de autenticación');
    }
  }

  /// Obtiene el token de autenticación
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_keyAuthToken);
    } catch (e) {
      debugPrint('Error al obtener token: $e');
      return null;
    }
  }

  /// Configura la preferencia "Recordarme"
  static Future<void> setRememberMe(bool value) async {
    try {
      final prefs = await _instance;
      await prefs.setBool(_keyRememberMe, value);
    } catch (e) {
      debugPrint('Error al guardar preferencia Recordarme: $e');
      throw Exception('Error al guardar preferencia');
    }
  }

  /// Obtiene la preferencia "Recordarme"
  static Future<bool> getRememberMe() async {
    try {
      final prefs = await _instance;
      return prefs.getBool(_keyRememberMe) ?? false;
    } catch (e) {
      debugPrint('Error al obtener preferencia Recordarme: $e');
      return false;
    }
  }

  /// Verifica si hay un usuario registrado
  static Future<bool> isUserRegistered() async {
    try {
      final prefs = await _instance;
      return prefs.containsKey(_keyUser);
    } catch (e) {
      debugPrint('Error al verificar usuario registrado: $e');
      return false;
    }
  }
}
