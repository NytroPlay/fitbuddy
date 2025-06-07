import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_provider.dart';
import 'auth/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; // <-- ¡IMPORTANTE!
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
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(), // <-- AGREGA ESTA LÍNEA
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = await UserPrefs.isAuthenticated();
    if (isAuth) {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        authProvider.setUser(user);
        _authed = true;
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _authed ? const MainNavigation() : const LoginScreen();
  }
}
