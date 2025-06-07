import 'package:fitbudd/navigation/main_navigation.dart';
import 'package:fitbudd/screens/login_screen.dart';
import 'package:fitbudd/screens/profile_screen.dart';
import 'package:fitbudd/screens/register_screen.dart';
import 'package:fitbudd/utils/app_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitBuddy',
      theme: AppTheme.lightTheme, // Usa tu tema personalizado
      darkTheme: AppTheme.darkTheme, // Opcional: tema oscuro
      themeMode: ThemeMode.light, // Puedes cambiarlo según preferencias
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/main': (_) =>
            const MainNavigation(), // Ruta principal después de login
      },
      onGenerateRoute: (settings) {
        // Manejo de rutas no definidas
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
      },
    );
  }
}
