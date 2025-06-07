// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_provider.dart';
import 'auth/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; // <-- Importa el registro
import 'navigation/main_navigation.dart';
import 'utils/app_theme.dart';
import 'utils/user_prefs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const FitBuddyApp(),
    ),
  );
}

class FitBuddyApp extends StatelessWidget {
  const FitBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Arrancamos siempre en el AuthWrapper
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(), // <-- Ruta al registro
        '/main': (_) => const MainNavigation(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 1) ¿Hay token / credenciales guardadas?
    final isAuth = await UserPrefs.isAuthenticated();
    if (isAuth) {
      // 2) Intentamos recuperar el usuario desde el servicio
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        // 3) Guardamos el usuario en el provider
        // ignore: use_build_context_synchronously
        Provider.of<AuthProvider>(context, listen: false).setUser(user);
        _authed = true;
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Mientras comprobamos la sesión, mostramos un loader
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Si está autenticado, vamos a toda la app, sino al login
    return _authed ? const MainNavigation() : const LoginScreen();
  }
}
