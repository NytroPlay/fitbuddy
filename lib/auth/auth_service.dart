import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../utils/user_prefs.dart';

class AuthService {
  /// Registra un usuario. Devuelve null si el email ya existe.
  Future<User?> signUp(User newUser) async {
    try {
      final created = await UserPrefs.registerUser(newUser);
      if (!created) return null;
      await UserPrefs.setAuthenticated(newUser);
      return newUser;
    } catch (e) {
      debugPrint('Error en signUp: $e');
      return null;
    }
  }

  /// Busca en la lista y, si coincide, lo marca como autenticado
  Future<User?> signIn(String email, String password) async {
    try {
      final user = await UserPrefs.findUser(email, password);
      if (user == null) return null;
      await UserPrefs.setAuthenticated(user);
      return user;
    } catch (e) {
      debugPrint('Error en signIn: $e');
      return null;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await UserPrefs.clearSession();
    } catch (e) {
      debugPrint('Error en signOut: $e');
    }
  }

  /// Carga el usuario logueado
  Future<User?> getCurrentUser() async {
    try {
      return await UserPrefs.loadCurrentUser();
    } catch (e) {
      debugPrint('Error en getCurrentUser: $e');
      return null;
    }
  }
}
