import 'package:flutter/material.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final user = await _authService.signIn(email, password);
    _isLoading = false;

    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    } else {
      _error = 'Email o contraseña incorrectos';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(User newUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final user = await _authService.signUp(newUser);
    _isLoading = false;

    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    } else {
      _error = 'El email ya está registrado';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Para inicializar (en AuthWrapper)
  Future<void> setUser(User user) async {
    _currentUser = user;
    notifyListeners();
  }
}
