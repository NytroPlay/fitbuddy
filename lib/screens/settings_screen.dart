// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

import '../screens/achievements_screen.dart';
import '../screens/feedback_screen.dart';
import '../utils/user_prefs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _isPrivate = false;
  String _language = 'es';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await UserPrefs.loadSettings();
    setState(() {
      _notifications = prefs['notifications'] ?? true;
      _isPrivate = prefs['private'] ?? false;
      _language = prefs['language'] ?? 'es';
    });
  }

  Future<void> _savePrefs() async {
    await UserPrefs.saveSettings({
      'notifications': _notifications,
      'private': _isPrivate,
      'language': _language,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        children: [
          SwitchListTile(
            title: const Text('Notificaciones de motivación'),
            value: _notifications,
            onChanged: (val) {
              setState(() => _notifications = val);
              _savePrefs();
            },
          ),
          SwitchListTile(
            title: const Text('Perfil privado'),
            value: _isPrivate,
            onChanged: (val) {
              setState(() => _isPrivate = val);
              _savePrefs();
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Idioma'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('Inglés')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _language = val);
                  _savePrefs();
                }
              },
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: Icon(Icons.feedback_outlined),
            title: Text('Enviar Feedback'),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_events_outlined),
            title: Text('Logros'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AchievementsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            trailing: const Icon(Icons.logout),
            onTap: () async {
              await UserPrefs.clearSession();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (r) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
