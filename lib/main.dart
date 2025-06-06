import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(onLogin: () {}),
        '/register': (_) => RegisterScreen(onRegistered: () {}),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
